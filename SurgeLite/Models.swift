import Foundation
import Combine

// MARK: - 节点

enum ProxyKind: String, Codable, CaseIterable, Hashable {
    case ss, ssr, vmess, vless, trojan, hysteria2, tuic, other

    var label: String {
        switch self {
        case .ss: return "SS"
        case .ssr: return "SSR"
        case .vmess: return "VMess"
        case .vless: return "VLESS"
        case .trojan: return "Trojan"
        case .hysteria2: return "Hy2"
        case .tuic: return "TUIC"
        case .other: return "未知"
        }
    }

    static func from(scheme: String) -> ProxyKind {
        switch scheme.lowercased() {
        case "ss": return .ss
        case "ssr": return .ssr
        case "vmess": return .vmess
        case "vless": return .vless
        case "trojan": return .trojan
        case "hysteria2", "hy2": return .hysteria2
        case "tuic": return .tuic
        default: return .other
        }
    }
}

struct ProxyNode: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var kind: ProxyKind
    var server: String
    var port: Int
    var raw: String = ""
    var region: String = "其他"
    var latency: Int? = nil
    var alive: Bool? = nil

    var endpoint: String { "\(server):\(port)" }
}

// MARK: - 规则

struct RuleItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var type: String
    var value: String
    var policy: String
    var enabled: Bool = true

    var text: String {
        type == "FINAL" ? "FINAL,\(policy)" : "\(type),\(value),\(policy)"
    }

    static let types = [
        "DOMAIN", "DOMAIN-SUFFIX", "DOMAIN-KEYWORD", "IP-CIDR", "IP-CIDR6",
        "GEOIP", "RULE-SET", "PROCESS-NAME", "USER-AGENT", "FINAL"
    ]
}

// MARK: - 模组

struct ModuleItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var url: String
    var enabled: Bool = true
    var scriptCount: Int = 0
    var panelCount: Int = 0
    var ruleCount: Int = 0
    var rewriteCount: Int = 0
    var mitmCount: Int = 0
    var raw: String = ""
    var lastError: String = ""

    var summary: String {
        "脚本 \(scriptCount) · 面板 \(panelCount) · 规则 \(ruleCount) · 重写 \(rewriteCount) · MITM \(mitmCount)"
    }
}

// MARK: - 订阅

struct Subscription: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var url: String
    var updatedAt: Date = Date()
    var nodeCount: Int = 0
    var autoUpdate: Bool = true
    var lastError: String = ""
}

// MARK: - 设置

enum LocalProxyType: String, Codable, CaseIterable {
    case none = "不使用"
    case http = "HTTP"
    case socks5 = "SOCKS5"
}

struct AppSettings: Codable {
    var proxyType: LocalProxyType = .none
    var proxyHost: String = "127.0.0.1"
    var proxyPort: Int = 6152
    var proxyUser: String = ""
    var proxyPass: String = ""
}

// MARK: - 测速结果

struct RankRow: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var region: String
    var latency: Int
}

struct SpeedResult: Codable, Hashable {
    var xLatency: Int = -1
    var tgLatency: Int = -1
    var mbps: Double = 0
    var okX: Bool = false
    var okTG: Bool = false
    var time: Date = Date()

    var average: Int {
        if okX && okTG { return (xLatency + tgLatency) / 2 }
        if okX { return xLatency }
        if okTG { return tgLatency }
        return -1
    }
}

// MARK: - 全局状态

struct AppState: Codable {
    var configName: String = "我的配置"
    var nodes: [ProxyNode] = []
    var subscriptions: [Subscription] = []
    var rules: [RuleItem] = []
    var modules: [ModuleItem] = []
    var settings: AppSettings = AppSettings()
    var lastRanking: [RankRow] = []
    var lastSpeed: SpeedResult? = nil
}

// MARK: - 存储

@MainActor
final class Store: ObservableObject {
    static let shared = Store()

    @Published var state: AppState = AppState() {
        didSet { save() }
    }

    @Published var busy: Bool = false
    @Published var message: String = ""

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("surgelite-state.json")
    }

    init() {
        load()
        if state.rules.isEmpty { state.rules = Store.defaultRules() }
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode(AppState.self, from: data) {
            state = decoded
        }
    }

    func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(state) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func defaultRules() -> [RuleItem] {
        [
            RuleItem(type: "DOMAIN-SUFFIX", value: "x.com", policy: "推特X"),
            RuleItem(type: "DOMAIN-SUFFIX", value: "twitter.com", policy: "推特X"),
            RuleItem(type: "DOMAIN-SUFFIX", value: "t.me", policy: "电报信息"),
            RuleItem(type: "DOMAIN-SUFFIX", value: "telegram.org", policy: "电报信息"),
            RuleItem(type: "DOMAIN-KEYWORD", value: "google", policy: "谷歌服务"),
            RuleItem(type: "DOMAIN-SUFFIX", value: "github.com", policy: "GitHub"),
            RuleItem(type: "GEOIP", value: "CN", policy: "DIRECT"),
            RuleItem(type: "FINAL", value: "", policy: "主节点")
        ]
    }

    // MARK: 节点操作

    func merge(nodes: [ProxyNode], subscription: Subscription?) {
        let existing = Set(state.nodes.map { $0.raw.isEmpty ? "\($0.server):\($0.port)" : $0.raw })
        var added: [ProxyNode] = []
        for n in nodes {
            let key = n.raw.isEmpty ? "\(n.server):\(n.port)" : n.raw
            if existing.contains(key) { continue }
            added.append(n)
        }
        state.nodes.append(contentsOf: added)

        if var sub = subscription {
            sub.nodeCount = nodes.count
            sub.updatedAt = Date()
            sub.lastError = ""
            if let idx = state.subscriptions.firstIndex(where: { $0.id == sub.id }) {
                state.subscriptions[idx] = sub
            } else {
                state.subscriptions.append(sub)
            }
        }
    }

    func removeNode(_ node: ProxyNode) {
        state.nodes.removeAll { $0.id == node.id }
    }

    func sortNodesByLatency() {
        state.nodes.sort { a, b in
            let la = a.latency ?? Int.max
            let lb = b.latency ?? Int.max
            if la == lb { return a.name < b.name }
            return la < lb
        }
    }

    func clearNodes() {
        state.nodes.removeAll()
        state.lastRanking.removeAll()
    }
}
