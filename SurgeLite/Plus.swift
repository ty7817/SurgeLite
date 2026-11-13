import Foundation

// MARK: - 订阅导出（交给有 VPN 权限的客户端使用）

extension Exporter {
    /// 可导出的原始节点行（Clash 来源的节点没有原始 URI，跳过）
    private static func exportableLines(_ state: AppState) -> [String] {
        var seen = Set<String>()
        var lines: [String] = []
        for node in state.nodes {
            let raw = node.raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if raw.isEmpty || raw.hasPrefix("clash:") { continue }
            if seen.contains(raw) { continue }
            seen.insert(raw)
            lines.append(raw)
        }
        return lines
    }

    /// 标准 Base64 订阅（粘进 Karing / sing-box / Stash / Shadowrocket 可直接导入）
    static func base64Subscription(_ state: AppState) -> String {
        let lines = exportableLines(state)
        guard !lines.isEmpty else { return "" }
        let text = lines.joined(separator: "\n")
        guard let data = text.data(using: .utf8) else { return "" }
        return data.base64EncodedString()
    }

    /// 逐行 URI 清单（纯文本，方便自己改）
    static func plainSubscription(_ state: AppState) -> String {
        let lines = exportableLines(state)
        guard !lines.isEmpty else { return "" }
        return lines.joined(separator: "\n")
    }

    /// 导出摘要，用于界面提示
    static func subscriptionSummary(_ state: AppState) -> String {
        let count = exportableLines(state).count
        let clash = state.nodes.filter { $0.raw.hasPrefix("clash:") }.count
        if count == 0 && clash == 0 { return "没有可导出的节点" }
        if clash == 0 { return "已整理 \(count) 个节点" }
        return "已整理 \(count) 个节点，另有 \(clash) 个 Clash 节点无原始 URI 已跳过"
    }
}
