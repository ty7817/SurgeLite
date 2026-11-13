import SwiftUI

// MARK: - 入口

@main
struct SurgeLiteApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

@MainActor
struct RootView: View {
    @ObservedObject var store = Store.shared

    var body: some View {
        TabView {
            OverviewView(store: store)
                .tabItem { Label("概览", systemImage: "gauge.with.needle") }
            SubscriptionsView(store: store)
                .tabItem { Label("订阅", systemImage: "link") }
            NodesView(store: store)
                .tabItem { Label("节点", systemImage: "server.rack") }
            RulesView(store: store)
                .tabItem { Label("规则", systemImage: "arrow.triangle.branch") }
            ModulesView(store: store)
                .tabItem { Label("模组", systemImage: "shippingbox") }
        }
        .tint(.orange)
    }
}

// MARK: - 通用样式

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

extension View {
    func card() -> some View { modifier(CardBackground()) }
}

func latencyText(_ value: Int?) -> String {
    guard let value = value else { return "未测" }
    return value < 0 ? "超时" : "\(value) ms"
}

func latencyColor(_ value: Int?) -> Color {
    guard let value = value else { return .secondary }
    if value < 0 { return .red }
    if value <= 300 { return .green }
    if value <= 800 { return .orange }
    return .red
}

// MARK: - 概览

struct OverviewView: View {
    @ObservedObject var store: Store
    @State private var showSettings = false
    @State private var showExport = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    configCard
                    speedCard
                    actionCard
                    rankingCard
                    footnote
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("概览")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "slider.horizontal.3") }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button { showExport = true } label: { Image(systemName: "square.and.arrow.up") }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView(store: store) }
            .sheet(isPresented: $showExport) { ExportView(store: store) }
        }
    }

    private var configCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(store.state.configName).font(.title3.weight(.semibold))
            HStack(spacing: 18) {
                metric("节点", "\(store.state.nodes.count)")
                metric("订阅", "\(store.state.subscriptions.count)")
                metric("规则", "\(store.state.rules.filter { $0.enabled }.count)")
                metric("模组", "\(store.state.modules.filter { $0.enabled }.count)")
            }
            HStack(spacing: 6) {
                Circle()
                    .fill(store.state.settings.proxyType == .none ? Color.secondary : Color.green)
                    .frame(width: 7, height: 7)
                Text(store.state.settings.proxyType == .none
                     ? "本地代理：未启用（App 内请求直连）"
                     : "本地代理：\(store.state.settings.proxyType.rawValue) \(store.state.settings.proxyHost):\(store.state.settings.proxyPort)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .card()
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.system(.title3, design: .rounded)).fontWeight(.semibold)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }

    private var speedCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Twitter / Telegram 出口测速").font(.subheadline.weight(.semibold))
                Spacer()
                if let s = store.state.lastSpeed {
                    Text(s.time.formatted(date: .omitted, time: .standard))
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
            HStack(spacing: 10) {
                targetTile("X", store.state.lastSpeed?.xLatency, store.state.lastSpeed?.okX ?? false)
                targetTile("TG", store.state.lastSpeed?.tgLatency, store.state.lastSpeed?.okTG ?? false)
                VStack(alignment: .leading, spacing: 4) {
                    Text("下载").font(.caption).foregroundStyle(.secondary)
                    Text(store.state.lastSpeed == nil ? "—" : String(format: "%.1f Mbps", store.state.lastSpeed?.mbps ?? 0))
                        .font(.system(.subheadline, design: .rounded)).fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button {
                runTargetSpeed()
            } label: {
                HStack {
                    if store.busy { ProgressView().controlSize(.small) }
                    Text(store.busy ? "测速中…" : "开始测速")
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
            }
            .buttonStyle(.borderedProminent)
            .disabled(store.busy)
        }
        .card()
    }

    private func targetTile(_ title: String, _ value: Int?, _ ok: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value == nil ? "—" : (value! < 0 ? "超时" : "\(value!) ms"))
                .font(.system(.subheadline, design: .rounded)).fontWeight(.semibold)
                .foregroundStyle(value == nil ? Color.secondary : (ok ? Color.green : Color.red))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionCard: some View {
        VStack(spacing: 0) {
            Button {
                testAllNodes()
            } label: {
                row(icon: "bolt.horizontal", title: "测试全部节点", detail: "对每个节点服务器做 TCP 建连延迟")
            }
            Divider().padding(.leading, 38)
            Button { showSettings = true } label: {
                row(icon: "network", title: "代理设置", detail: "App 内请求走 HTTP / SOCKS5 代理")
            }
            Divider().padding(.leading, 38)
            Button { showExport = true } label: {
                row(icon: "doc.text", title: "导出配置", detail: "生成可粘贴进 Surge 的规则片段")
            }
        }
        .card()
    }

    private func row(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).frame(width: 24).foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.medium)).foregroundStyle(.primary)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private var rankingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("节点延迟排名").font(.subheadline.weight(.semibold))
                Spacer()
                if !store.state.lastRanking.isEmpty {
                    Button("清除") {
                        store.state.lastRanking.removeAll()
                    }
                    .font(.caption)
                }
            }
            if store.state.lastRanking.isEmpty {
                Text("还没有排名，点上方「测试全部节点」跑一轮。")
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                ForEach(0..<min(10, store.state.lastRanking.count), id: \.self) { index in
                    let item = store.state.lastRanking[index]
                    HStack(spacing: 10) {
                        Text("\(index + 1)")
                            .font(.system(.caption, design: .rounded)).fontWeight(.bold)
                            .frame(width: 22, height: 22)
                            .background(medalColor(index), in: Circle())
                            .foregroundStyle(index < 3 ? Color.white : Color.secondary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.name).font(.caption).lineLimit(1)
                            Text(item.region).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(latencyText(item.latency))
                            .font(.system(.caption, design: .rounded)).fontWeight(.semibold)
                            .foregroundStyle(latencyColor(item.latency))
                    }
                }
            }
        }
        .card()
    }

    private func medalColor(_ index: Int) -> Color {
        if index == 0 { return .orange }
        if index == 1 { return .gray }
        if index == 2 { return .brown }
        return Color(.tertiarySystemFill)
    }

    private var footnote: some View {
        Text("说明：节点排名基于服务器 TCP 建连延迟，真实可用性取决于协议与线路。系统级流量接管需要 Network Extension 权限，本 App 不做全局代理。")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
    }

    private func runTargetSpeed() {
        store.busy = true
        let settings = store.state.settings
        Task {
            let result = await Speed.testTargets(settings: settings)
            store.state.lastSpeed = result
            store.busy = false
        }
    }

    private func testAllNodes() {
        guard !store.state.nodes.isEmpty else {
            store.message = "还没有节点，先到订阅页导入"
            return
        }
        store.busy = true
        let nodes = store.state.nodes
        Task {
            let result = await Speed.testNodes(nodes)
            for i in store.state.nodes.indices {
                if let r = result[store.state.nodes[i].id] {
                    store.state.nodes[i].latency = r.0
                    store.state.nodes[i].alive = r.1
                }
            }
            let ranking = store.state.nodes
                .filter { ($0.latency ?? -1) >= 0 }
                .sorted { ($0.latency ?? Int.max) < ($1.latency ?? Int.max) }
                .map { RankRow(name: $0.name, region: $0.region, latency: $0.latency ?? -1) }
            store.state.lastRanking = ranking
            store.busy = false
            if ranking.isEmpty { store.message = "全部节点都没有建连成功，检查订阅是否可用" }
        }
    }
}

// MARK: - 订阅

struct SubscriptionsView: View {
    @ObservedObject var store: Store
    @State private var showAdd = false
    @State private var busySub: UUID? = nil

    var body: some View {
        NavigationStack {
            List {
                if store.state.subscriptions.isEmpty {
                    Section {
                        Text("还没有订阅。点右上角 + 添加订阅链接，会自动识别 Clash / Base64 / URI 列表。")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
                ForEach($store.state.subscriptions) { $sub in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(sub.name).font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("\(sub.nodeCount) 节点").font(.caption).foregroundStyle(.secondary)
                        }
                        Text(sub.url).font(.caption2).foregroundStyle(.secondary).lineLimit(2)
                        HStack(spacing: 8) {
                            Text(sub.updatedAt.formatted(date: .numeric, time: .shortened))
                                .font(.caption2).foregroundStyle(.tertiary)
                            Spacer()
                            if busySub == sub.id {
                                ProgressView().controlSize(.mini)
                            } else {
                                Button("更新") { refresh(sub) }
                                    .buttonStyle(.bordered)
                                    .controlSize(.mini)
                            }
                        }
                        if !sub.lastError.isEmpty {
                            Text(sub.lastError).font(.caption2).foregroundStyle(.red)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onDelete { offsets in
                    store.state.subscriptions.remove(atOffsets: offsets)
                }

                if !store.state.nodes.isEmpty {
                    Section("节点管理") {
                        Button("清空全部节点", role: .destructive) { store.clearNodes() }
                    }
                }
            }
            .navigationTitle("订阅")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddSubscriptionView(store: store) }
            .alert("提示", isPresented: Binding(
                get: { !store.message.isEmpty },
                set: { if !$0 { store.message = "" } }
            )) {
                Button("好") { store.message = "" }
            } message: { Text(store.message) }
        }
    }

    private func refresh(_ sub: Subscription) {
        busySub = sub.id
        let settings = store.state.settings
        Task {
            do {
                let text = try await Fetcher.fetch(sub.url, settings: settings)
                let nodes = SubParser.parse(text)
                guard !nodes.isEmpty else {
                    markError(sub, "没有解析出节点，格式可能不支持")
                    busySub = nil
                    return
                }
                store.merge(nodes: nodes, subscription: sub)
            } catch {
                markError(sub, error.localizedDescription)
            }
            busySub = nil
        }
    }

    private func markError(_ sub: Subscription, _ msg: String) {
        if let idx = store.state.subscriptions.firstIndex(where: { $0.id == sub.id }) {
            store.state.subscriptions[idx].lastError = msg
            store.state.subscriptions[idx].updatedAt = Date()
        }
    }
}

struct AddSubscriptionView: View {
    @ObservedObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var url = ""
    @State private var loading = false
    @State private var error = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("订阅信息") {
                    TextField("名称（可留空）", text: $name)
                    TextField("https://…/subscribe?token=…", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                if !error.isEmpty {
                    Section { Text(error).font(.footnote).foregroundStyle(.red) }
                }
                Section {
                    Button {
                        submit()
                    } label: {
                        HStack {
                            if loading { ProgressView().controlSize(.small) }
                            Text(loading ? "拉取中…" : "拉取并导入")
                        }
                    }
                    .disabled(loading || url.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("添加订阅")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    private func submit() {
        error = ""
        loading = true
        let settings = store.state.settings
        let rawURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        let subName = name.trimmingCharacters(in: .whitespaces).isEmpty ? "订阅 \(store.state.subscriptions.count + 1)" : name
        Task {
            do {
                let text = try await Fetcher.fetch(rawURL, settings: settings)
                let nodes = SubParser.parse(text)
                guard !nodes.isEmpty else {
                    error = "没有解析出节点。支持 Clash YAML、Base64 订阅和 ss/vmess/vless/trojan/hysteria2 链接。"
                    loading = false
                    return
                }
                let sub = Subscription(name: subName, url: rawURL, nodeCount: nodes.count)
                store.merge(nodes: nodes, subscription: sub)
                loading = false
                dismiss()
            } catch let err {
                error = err.localizedDescription
                loading = false
            }
        }
    }
}

// MARK: - 节点

struct NodesView: View {
    @ObservedObject var store: Store
    @State private var keyword = ""
    @State private var region = "全部"
    @State private var testing = false

    private var regions: [String] {
        var set = Set(store.state.nodes.map { $0.region })
        set.insert("全部")
        return Array(set).sorted()
    }

    private var filtered: [ProxyNode] {
        store.state.nodes.filter { node in
            (region == "全部" || node.region == region) &&
            (keyword.isEmpty || node.name.localizedCaseInsensitiveContains(keyword) || node.server.contains(keyword))
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("搜索节点", text: $keyword)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 9))
                    Menu {
                        ForEach(regions, id: \.self) { r in
                            Button(r) { region = r }
                        }
                    } label: {
                        Text(region)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 9))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if store.state.nodes.isEmpty {
                    ContentUnavailableView("暂无节点", systemImage: "server.rack",
                                           description: Text("先到订阅页添加订阅链接"))
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filtered) { node in
                            HStack(spacing: 10) {
                                Text(node.region)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color(.tertiarySystemFill), in: Capsule())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(node.name).font(.subheadline).lineLimit(1)
                                    Text("\(node.kind.label) · \(node.endpoint)")
                                        .font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                                }
                                Spacer()
                                Text(latencyText(node.latency))
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(latencyColor(node.latency))
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.removeNode(node)
                                } label: { Label("删除", systemImage: "trash") }
                                Button {
                                    testSingle(node)
                                } label: { Label("测速", systemImage: "bolt") }
                                    .tint(.orange)
                            }
                        }
                        .onDelete { offsets in
                            let targets = offsets.map { filtered[$0] }
                            for t in targets { store.removeNode(t) }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("节点")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("测试全部节点") { testAll() }
                        Button("按延迟排序") { store.sortNodesByLatency() }
                        Button("清除测速结果") {
                            for i in store.state.nodes.indices { store.state.nodes[i].latency = nil }
                        }
                    } label: {
                        if testing { ProgressView().controlSize(.small) }
                        else { Image(systemName: "ellipsis.circle") }
                    }
                }
            }
        }
    }

    private func testSingle(_ node: ProxyNode) {
        Task {
            let r = await Speed.tcpPing(host: node.server, port: node.port)
            if let idx = store.state.nodes.firstIndex(where: { $0.id == node.id }) {
                store.state.nodes[idx].latency = r.0
                store.state.nodes[idx].alive = r.1
            }
        }
    }

    private func testAll() {
        guard !store.state.nodes.isEmpty else { return }
        testing = true
        let nodes = store.state.nodes
        Task {
            let result = await Speed.testNodes(nodes)
            for i in store.state.nodes.indices {
                if let r = result[store.state.nodes[i].id] {
                    store.state.nodes[i].latency = r.0
                    store.state.nodes[i].alive = r.1
                }
            }
            store.state.lastRanking = store.state.nodes
                .filter { ($0.latency ?? -1) >= 0 }
                .sorted { ($0.latency ?? Int.max) < ($1.latency ?? Int.max) }
                .map { RankRow(name: $0.name, region: $0.region, latency: $0.latency ?? -1) }
            testing = false
        }
    }
}
