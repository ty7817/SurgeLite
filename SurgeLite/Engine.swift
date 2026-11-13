import Foundation
import Network

// MARK: - 网络请求

enum Fetcher {
    static func session(_ settings: AppSettings) -> URLSession {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 40
        cfg.requestCachePolicy = .reloadIgnoringLocalCacheData
        if settings.proxyType != .none, settings.proxyPort > 0 {
            var dict: [AnyHashable: Any] = [:]
            if settings.proxyType == .http {
                dict["HTTPEnable"] = 1
                dict["HTTPProxy"] = settings.proxyHost
                dict["HTTPPort"] = settings.proxyPort
                dict["HTTPSEnable"] = 1
                dict["HTTPSProxy"] = settings.proxyHost
                dict["HTTPSPort"] = settings.proxyPort
            } else {
                dict["SOCKSEnable"] = 1
                dict["SOCKSProxy"] = settings.proxyHost
                dict["SOCKSPort"] = settings.proxyPort
            }
            cfg.connectionProxyDictionary = dict
        }
        return URLSession(configuration: cfg)
    }

    enum FetchError: LocalizedError {
        case badURL, badBody, http(Int)

        var errorDescription: String? {
            switch self {
            case .badURL: return "链接格式不正确"
            case .badBody: return "内容不是文本，可能是链接失效"
            case .http(let code): return "HTTP \(code)"
            }
        }
    }

    static func fetch(_ urlString: String, settings: AppSettings) async throws -> String {
        var raw = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !raw.lowercased().hasPrefix("http") { raw = "https://" + raw }
        guard let url = URL(string: raw) else { throw FetchError.badURL }
        var req = URLRequest(url: url)
        req.setValue("SurgeLite/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
        let (data, resp) = try await session(settings).data(for: req)
        if let http = resp as? HTTPURLResponse, !(200...399).contains(http.statusCode) {
            throw FetchError.http(http.statusCode)
        }
        guard let text = String(data: data, encoding: .utf8) else { throw FetchError.badBody }
        return text
    }
}

// MARK: - 订阅解析

enum SubParser {
    static func decodeBase64(_ s: String) -> String? {
        var t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        guard !t.isEmpty else { return nil }
        while t.count % 4 != 0 { t += "=" }
        guard let data = Data(base64Encoded: t) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func parse(_ text: String) -> [ProxyNode] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let clash = parseClash(trimmed), !clash.isEmpty { return clash }
        var body = trimmed
        if !body.contains("://"), let decoded = decodeBase64(body) { body = decoded }
        return parseLines(body)
    }

    static func parseLines(_ body: String) -> [ProxyNode] {
        var nodes: [ProxyNode] = []
        let lines = body.replacingOccurrences(of: "\r", with: "\n").split(separator: "\n")
        for line in lines {
            let t = String(line).trimmingCharacters(in: .whitespaces)
            if t.isEmpty || t.hasPrefix("#") || t.hasPrefix(";") || t.hasPrefix("//") { continue }
            if let node = parseURI(t) { nodes.append(node) }
        }
        return nodes
    }

    private static func stripQuery(_ s: String) -> String {
        if let q = s.firstIndex(of: "?") { return String(s[s.startIndex..<q]) }
        return s
    }

    private static func splitName(_ s: String) -> (String, String) {
        if let r = s.range(of: "#", options: .backwards) {
            let tail = String(s[r.upperBound...])
            let name = tail.removingPercentEncoding ?? tail
            return (String(s[s.startIndex..<r.lowerBound]), name)
        }
        return (s, "")
    }

    static func parseHostPort(_ s: String) -> (String, Int)? {
        var body = s
        if let slash = body.firstIndex(of: "/") { body = String(body[body.startIndex..<slash]) }
        if body.hasPrefix("[") {
            guard let close = body.firstIndex(of: "]") else { return nil }
            let host = String(body[body.index(after: body.startIndex)..<close])
            let rest = body[body.index(after: close)...]
            let portStr = rest.hasPrefix(":") ? String(rest.dropFirst()) : "443"
            return (host, Int(portStr) ?? 443)
        }
        guard let colon = body.lastIndex(of: ":") else { return nil }
        let host = String(body[body.startIndex..<colon])
        let portStr = String(body[body.index(after: colon)...])
        guard !host.isEmpty, let port = Int(portStr) else { return nil }
        return (host, port)
    }

    static func parseURI(_ line: String) -> ProxyNode? {
        guard let mark = line.range(of: "://") else { return nil }
        let scheme = String(line[line.startIndex..<mark.lowerBound]).lowercased()
        let rest = String(line[mark.upperBound...])
        let kind = ProxyKind.from(scheme: scheme)

        if scheme == "ssr" {
            guard let decoded = decodeBase64(stripQuery(rest)) else { return nil }
            let parts = decoded.split(separator: ":", maxSplits: 5, omittingEmptySubsequences: false)
            guard parts.count >= 6, let port = Int(parts[1]) else { return nil }
            let host = String(parts[0])
            let label = decodeBase64(String(parts[5])) ?? host
            let name = label.isEmpty ? host : label
            return ProxyNode(name: name, kind: .ssr, server: host, port: port,
                             raw: line, region: detectRegion(name))
        }

        if scheme == "vmess" {
            guard let decoded = decodeBase64(rest),
                  let json = try? JSONSerialization.jsonObject(with: Data(decoded.utf8)),
                  let obj = json as? [String: Any] else { return nil }
            let server = (obj["add"] as? String) ?? ""
            var port = 0
            if let p = obj["port"] as? Int { port = p }
            else if let p = obj["port"] as? String { port = Int(p) ?? 0 }
            let name = (obj["ps"] as? String) ?? server
            guard !server.isEmpty, port > 0 else { return nil }
            return ProxyNode(name: name, kind: .vmess, server: server, port: port,
                             raw: line, region: detectRegion(name))
        }

        let split = splitName(rest)
        let name = split.1
        let core = stripQuery(split.0)

        if kind == .ss {
            var hostPart = ""
            if let at = core.lastIndex(of: "@") {
                hostPart = String(core[core.index(after: at)...])
            } else if let decoded = decodeBase64(core), let at = decoded.lastIndex(of: "@") {
                hostPart = String(decoded[decoded.index(after: at)...])
            } else {
                return nil
            }
            guard let (host, port) = parseHostPort(hostPart) else { return nil }
            let label = name.isEmpty ? host : name
            return ProxyNode(name: label, kind: .ss, server: host, port: port,
                             raw: line, region: detectRegion(label))
        }

        guard [ProxyKind.vless, ProxyKind.trojan, ProxyKind.hysteria2, ProxyKind.tuic].contains(kind) else { return nil }
        if let at = core.lastIndex(of: "@") {
            let hostPart = String(core[core.index(after: at)...])
            guard let (host, port) = parseHostPort(hostPart) else { return nil }
            let label = name.isEmpty ? host : name
            return ProxyNode(name: label, kind: kind, server: host, port: port,
                             raw: line, region: detectRegion(label))
        }
        guard let (host, port) = parseHostPort(core) else { return nil }
        let label = name.isEmpty ? host : name
        return ProxyNode(name: label, kind: kind, server: host, port: port,
                         raw: line, region: detectRegion(label))
    }

    // MARK: Clash / Mihomo YAML

    static func parseClash(_ text: String) -> [ProxyNode]? {
        guard text.contains("proxies:") else { return nil }
        var blocks: [[String: String]] = []
        var current: [String: String]? = nil
        var inProxies = false
        var started = false

        func flush() {
            if let c = current, !c.isEmpty { blocks.append(c) }
            current = nil
        }

        for raw in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(raw)
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

            if trimmed.hasPrefix("proxies:") {
                inProxies = true
                continue
            }
            guard inProxies else { continue }

            let indented = line.hasPrefix(" ") || line.hasPrefix("\t")
            if !indented && trimmed.contains(":") && !trimmed.hasPrefix("-") {
                break
            }

            if trimmed.hasPrefix("- ") {
                started = true
                flush()
                current = [:]
                let tail = String(trimmed.dropFirst(2))
                if tail.hasPrefix("{") {
                    var inner = tail
                    if inner.hasPrefix("{") { inner.removeFirst() }
                    if inner.hasSuffix("}") { inner.removeLast() }
                    for pair in inner.split(separator: ",") {
                        let kv = pair.split(separator: ":", maxSplits: 1)
                        guard kv.count == 2 else { continue }
                        let k = String(kv[0]).trimmingCharacters(in: .whitespaces)
                        var v = String(kv[1]).trimmingCharacters(in: .whitespaces)
                        if v.hasPrefix("\"") && v.hasSuffix("\"") && v.count > 1 {
                            v = String(v.dropFirst().dropLast())
                        }
                        current?[k] = v
                    }
                } else if let idx = tail.firstIndex(of: ":") {
                    let k = String(tail[tail.startIndex..<idx]).trimmingCharacters(in: .whitespaces)
                    var v = String(tail[tail.index(after: idx)...]).trimmingCharacters(in: .whitespaces)
                    if v.hasPrefix("\"") && v.hasSuffix("\"") && v.count > 1 {
                        v = String(v.dropFirst().dropLast())
                    }
                    current?[k] = v
                }
                continue
            }
            guard started, current != nil, let idx = trimmed.firstIndex(of: ":") else { continue }
            let k = String(trimmed[trimmed.startIndex..<idx]).trimmingCharacters(in: .whitespaces)
            var v = String(trimmed[trimmed.index(after: idx)...]).trimmingCharacters(in: .whitespaces)
            if v.hasPrefix("\"") && v.hasSuffix("\"") && v.count > 1 {
                v = String(v.dropFirst().dropLast())
            }
            current?[k] = v
        }
        flush()

        var nodes: [ProxyNode] = []
        for b in blocks {
            guard let server = b["server"], !server.isEmpty,
                  let portStr = b["port"], let port = Int(portStr) else { continue }
            let name = b["name"] ?? server
            let type = (b["type"] ?? "").lowercased()
            let kind: ProxyKind
            switch type {
            case "ss": kind = .ss
            case "ssr": kind = .ssr
            case "vmess": kind = .vmess
            case "vless": kind = .vless
            case "trojan": kind = .trojan
            case "hysteria2", "hy2": kind = .hysteria2
            case "tuic": kind = .tuic
            default: kind = .other
            }
            nodes.append(ProxyNode(name: name, kind: kind, server: server, port: port,
                                   raw: "clash:\(name)", region: detectRegion(name)))
        }
        return nodes.isEmpty ? nil : nodes
    }

    // MARK: 地区识别

    static func detectRegion(_ name: String) -> String {
        let map: [(String, [String])] = [
            ("香港", ["香港", "🇭🇰", "hongkong", "hong kong", "hk", "港"]),
            ("台湾", ["台湾", "台灣", "🇹🇼", "taiwan", "tw", "臺"]),
            ("日本", ["日本", "🇯🇵", "japan", "jp", "东京", "大阪", "東京"]),
            ("新加坡", ["新加坡", "🇸🇬", "singapore", "sg", "狮城"]),
            ("美国", ["美国", "🇺🇸", "united states", "america", "usa", "us", "美"]),
            ("韩国", ["韩国", "韓國", "🇰🇷", "korea", "kr", "首尔"]),
            ("英国", ["英国", "🇬🇧", "united kingdom", "uk", "britain", "伦敦"]),
            ("德国", ["德国", "🇩🇪", "germany", "de", "法兰克福"]),
            ("法国", ["法国", "🇫🇷", "france", "fr", "巴黎"]),
            ("荷兰", ["荷兰", "🇳🇱", "netherlands", "nl", "阿姆斯特丹"]),
            ("加拿大", ["加拿大", "🇨🇦", "canada", "ca", "多伦多"]),
            ("澳大利亚", ["澳大利亚", "澳洲", "🇦🇺", "australia", "au", "悉尼"]),
            ("俄罗斯", ["俄罗斯", "🇷🇺", "russia", "ru", "莫斯科"]),
            ("印度", ["印度", "🇮🇳", "india", "in", "孟买"]),
            ("土耳其", ["土耳其", "🇹🇷", "turkey", "tr", "伊斯坦布尔"]),
            ("巴西", ["巴西", "🇧🇷", "brazil", "br", "圣保罗"]),
            ("阿联酋", ["阿联酋", "🇦🇪", "uae", "ae", "迪拜"]),
            ("马来西亚", ["马来西亚", "🇲🇾", "malaysia", "my", "吉隆坡"]),
            ("泰国", ["泰国", "🇹🇭", "thailand", "th", "曼谷"]),
            ("越南", ["越南", "🇻🇳", "vietnam", "vn", "河内"]),
            ("菲律宾", ["菲律宾", "🇵🇭", "philippines", "ph", "马尼拉"]),
            ("印尼", ["印尼", "🇮🇩", "indonesia", "id", "雅加达"])
        ]
        let lower = name.lowercased()
        for (region, keys) in map {
            for key in keys where lower.contains(key.lowercased()) {
                return region
            }
        }
        return "其他"
    }
}

// MARK: - 模组解析

struct ModuleParseResult {
    var name: String
    var script: Int
    var panel: Int
    var rule: Int
    var rewrite: Int
    var mitm: Int
}

enum ModuleParser {
    static func parse(_ text: String, fallbackName: String) -> ModuleParseResult {
        var name = fallbackName
        var section = ""
        var script = 0, panel = 0, rule = 0, rewrite = 0, mitm = 0

        for raw in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = String(raw).trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            if trimmed.hasPrefix("#!name=") {
                let v = String(trimmed.dropFirst("#!name=".count)).trimmingCharacters(in: .whitespaces)
                if !v.isEmpty { name = v }
                continue
            }
            if trimmed.hasPrefix("#") || trimmed.hasPrefix(";") || trimmed.hasPrefix("//") { continue }
            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                section = trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                continue
            }
            switch section {
            case "Script": script += 1
            case "Panel": panel += 1
            case "Rule": rule += 1
            case "URL Rewrite": rewrite += 1
            case "MITM":
                if trimmed.hasPrefix("hostname") {
                    if let eq = trimmed.firstIndex(of: "=") {
                        let hosts = trimmed[trimmed.index(after: eq)...]
                        mitm += hosts.split(separator: ",")
                            .filter { !String($0).trimmingCharacters(in: .whitespaces).isEmpty }
                            .count
                    }
                } else if trimmed.contains("%APPEND%") {
                    mitm += 1
                }
            default: break
            }
        }
        return ModuleParseResult(name: name, script: script, panel: panel, rule: rule, rewrite: rewrite, mitm: mitm)
    }
}

// MARK: - 规则匹配

enum RuleEngine {
    struct MatchResult {
        var rule: RuleItem?
        var policy: String
        var note: String
    }

    static func match(_ input: String, rules: [RuleItem]) -> MatchResult {
        let host = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !host.isEmpty else { return MatchResult(rule: nil, policy: "-", note: "请输入域名或 IP") }
        let isIP = CharacterSet(charactersIn: "0123456789.").isSuperset(of: CharacterSet(charactersIn: host))

        for rule in rules where rule.enabled {
            switch rule.type {
            case "DOMAIN":
                if host == rule.value.lowercased() {
                    return MatchResult(rule: rule, policy: rule.policy, note: "精确匹配")
                }
            case "DOMAIN-SUFFIX":
                let suffix = rule.value.lowercased()
                if host == suffix || host.hasSuffix("." + suffix) {
                    return MatchResult(rule: rule, policy: rule.policy, note: "后缀匹配")
                }
            case "DOMAIN-KEYWORD":
                if host.contains(rule.value.lowercased()) {
                    return MatchResult(rule: rule, policy: rule.policy, note: "关键词匹配")
                }
            case "IP-CIDR":
                if isIP, ipInCIDR(host, rule.value) {
                    return MatchResult(rule: rule, policy: rule.policy, note: "IP 段匹配")
                }
            case "IP-CIDR6":
                if isIP, host.contains(":") {
                    return MatchResult(rule: rule, policy: rule.policy, note: "IPv6 段匹配")
                }
            case "GEOIP", "RULE-SET", "PROCESS-NAME", "USER-AGENT":
                continue
            case "FINAL":
                return MatchResult(rule: rule, policy: rule.policy, note: "兜底规则")
            default:
                continue
            }
        }
        return MatchResult(rule: nil, policy: "未命中", note: "会继续向下匹配或走 FINAL")
    }

    static func ipInCIDR(_ ip: String, _ cidr: String) -> Bool {
        let parts = cidr.split(separator: "/")
        guard parts.count == 2, let bits = Int(parts[1]),
              let base = ipToUInt(String(parts[0]), ip) else { return false }
        guard bits >= 0, bits <= 32 else { return false }
        let mask: UInt32 = bits == 0 ? 0 : UInt32.max << (32 - UInt32(bits))
        return (base.0 & mask) == (base.1 & mask)
    }

    static func ipToUInt(_ ip: String, _ target: String) -> (UInt32, UInt32)? {
        let a = ip.split(separator: ".")
        let b = target.split(separator: ".")
        guard a.count == 4, b.count == 4 else { return nil }
        guard let x = composeUInt32(a), let y = composeUInt32(b) else { return nil }
        return (x, y)
    }

    static func composeUInt32(_ parts: [Substring]) -> UInt32? {
        var value: UInt32 = 0
        for p in parts {
            guard let n = UInt32(p), n <= 255 else { return nil }
            value = value << 8 | n
        }
        return value
    }
}

// MARK: - 导出

enum Exporter {
    static func surgeText(state: AppState) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var text = "# SurgeLite 导出\n# 生成时间：\(df.string(from: Date()))\n# 节点 \(state.nodes.count) 个 · 规则 \(state.rules.count) 条 · 模组 \(state.modules.count) 个\n\n"

        text += "[Rule]\n"
        for rule in state.rules where rule.enabled {
            text += rule.text + "\n"
        }

        let enabledModules = state.modules.filter { $0.enabled && !$0.raw.isEmpty }
        if !enabledModules.isEmpty {
            text += "\n# ===== 以下模组内容需要 Surge 内核执行，仅作整合备份 =====\n"
            for m in enabledModules {
                text += "\n# ==== 模组：\(m.name) ====\n# 来源：\(m.url)\n"
                text += m.raw.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
            }
        }
        return text
    }

    static func nodeListText(state: AppState) -> String {
        var lines: [String] = ["# SurgeLite 节点清单（URI 形式，可导入 Surge / Shadowrocket）"]
        for node in state.nodes {
            if node.raw.hasPrefix("clash:") {
                lines.append("# \(node.name)  [\(node.kind.label)] \(node.server):\(node.port)  （来自 Clash 配置，请使用原 YAML）")
            } else if !node.raw.isEmpty {
                lines.append(node.raw)
            } else {
                lines.append("# \(node.name)  [\(node.kind.label)] \(node.server):\(node.port)")
            }
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - 测速

struct NodePing: Sendable {
    let id: UUID
    let latency: Int
    let ok: Bool
}

enum Speed {
    static func ping(_ urlString: String, settings: AppSettings, timeout: Double = 10) async -> (Int, Bool) {
        guard let url = URL(string: urlString) else { return (-1, false) }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = timeout
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15",
                     forHTTPHeaderField: "User-Agent")
        let start = Date()
        do {
            _ = try await Fetcher.session(settings).data(for: req)
            return (Int(Date().timeIntervalSince(start) * 1000), true)
        } catch {
            return (-1, false)
        }
    }

    static func download(_ urlString: String, settings: AppSettings) async -> (Double, Int) {
        guard let url = URL(string: urlString) else { return (0, 0) }
        var req = URLRequest(url: url)
        req.timeoutInterval = 20
        let start = Date()
        do {
            let (data, _) = try await Fetcher.session(settings).data(for: req)
            let seconds = max(Date().timeIntervalSince(start), 0.05)
            let mbps = Double(data.count) * 8 / 1_000_000 / seconds
            return (mbps, data.count)
        } catch {
            return (0, 0)
        }
    }

    static func testTargets(settings: AppSettings) async -> SpeedResult {
        async let x = ping("https://x.com/", settings: settings, timeout: 10)
        async let t = ping("https://t.me/", settings: settings, timeout: 10)
        let (xRes, tgRes) = await (x, t)
        let down = await download("https://speed.cloudflare.com/__down?bytes=2000000", settings: settings)
        return SpeedResult(xLatency: xRes.0, tgLatency: tgRes.0,
                           mbps: down.0, okX: xRes.1, okTG: tgRes.1, time: Date())
    }

    // 节点服务器 TCP 建连延迟（真实可测，不需要内核）
    static func tcpPing(host: String, port: Int, timeout: TimeInterval = 4) async -> (Int, Bool) {
        await withCheckedContinuation { (cont: CheckedContinuation<(Int, Bool), Never>) in
            guard let nwPort = NWEndpoint.Port(rawValue: UInt16(clamping: port)) else {
                cont.resume(returning: (-1, false)); return
            }
            let queue = DispatchQueue(label: "surgelite.tcpPing")
            let conn = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: .tcp)
            var finished = false
            let start = Date()

            func finish(_ ms: Int, _ ok: Bool) {
                if finished { return }
                finished = true
                conn.stateUpdateHandler = nil
                conn.cancel()
                cont.resume(returning: (ms, ok))
            }

            conn.stateUpdateHandler = { st in
                switch st {
                case .ready:
                    finish(Int(Date().timeIntervalSince(start) * 1000), true)
                case .failed, .waiting:
                    finish(-1, false)
                default:
                    break
                }
            }
            conn.start(queue: queue)
            queue.asyncAfter(deadline: .now() + timeout) { finish(-1, false) }
        }
    }

    static func testNodes(_ nodes: [ProxyNode], limit: Int = 8) async -> [UUID: (Int, Bool)] {
        var result: [UUID: (Int, Bool)] = [:]
        var index = 0
        while index < nodes.count {
            let end = min(index + limit, nodes.count)
            let slice = Array(nodes[index..<end])
            await withTaskGroup(of: NodePing.self) { group in
                for node in slice {
                    group.addTask {
                        let r = await tcpPing(host: node.server, port: node.port)
                        return NodePing(id: node.id, latency: r.0, ok: r.1)
                    }
                }
                for await item in group {
                    result[item.id] = (item.latency, item.ok)
                }
            }
            index = end
        }
        return result
    }
}
