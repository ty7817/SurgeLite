import SwiftUI

// MARK: - 规则

struct RulesView: View {
    @ObservedObject var store: Store
    @State private var showAdd = false
    @State private var testInput = ""
    @State private var matchText: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 8) {
                        TextField("输入域名或 IP 试匹配", text: $testInput)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.callout)
                        Button("匹配") {
                            let r = RuleEngine.match(testInput, rules: store.state.rules)
                            matchText = "\(r.policy)（\(r.note)）" + (r.rule == nil ? "" : " · \(r.rule!.text)")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    if !matchText.isEmpty {
                        Text(matchText).font(.caption).foregroundStyle(.secondary)
                    }
                } header: { Text("命中测试") }

                Section {
                    ForEach($store.state.rules) { $rule in
                        HStack(spacing: 10) {
                            Toggle("", isOn: $rule.enabled).labelsHidden()
                            VStack(alignment: .leading, spacing: 2) {
                                Text(rule.type).font(.caption2).foregroundStyle(.secondary)
                                Text(rule.type == "FINAL" ? "FINAL" : rule.value)
                                    .font(.subheadline).lineLimit(1)
                            }
                            Spacer()
                            Text(rule.policy)
                                .font(.caption)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color(.tertiarySystemFill), in: Capsule())
                        }
                    }
                    .onMove { from, to in store.state.rules.move(fromOffsets: from, toOffset: to) }
                    .onDelete { offsets in store.state.rules.remove(atOffsets: offsets) }
                } header: {
                    HStack {
                        Text("分流规则（按顺序命中）")
                        Spacer()
                        Text("\(store.state.rules.count) 条").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("规则")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddRuleView(store: store) }
        }
    }
}

struct AddRuleView: View {
    @ObservedObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var type = "DOMAIN-SUFFIX"
    @State private var value = ""
    @State private var policy = "主节点"

    private let policies = ["主节点", "全网最优", "香港节点", "日本节点", "美国节点",
                            "新加坡节点", "台湾节点", "推特X", "电报信息", "谷歌服务",
                            "GitHub", "DIRECT", "REJECT"]

    var body: some View {
        NavigationStack {
            Form {
                Section("规则") {
                    Picker("类型", selection: $type) {
                        ForEach(RuleItem.types, id: \.self) { Text($0) }
                    }
                    if type != "FINAL" {
                        TextField("匹配值，如 x.com 或 10.0.0.0/8", text: $value)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    Picker("策略", selection: $policy) {
                        ForEach(policies, id: \.self) { Text($0) }
                    }
                }
                Section {
                    Button("添加") {
                        store.state.rules.append(RuleItem(type: type,
                                                          value: type == "FINAL" ? "" : value.trimmingCharacters(in: .whitespaces),
                                                          policy: policy))
                        dismiss()
                    }
                    .disabled(type != "FINAL" && value.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("新增规则")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("取消") { dismiss() } }
            }
        }
    }
}

// MARK: - 模组

struct ModulesView: View {
    @ObservedObject var store: Store
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                if store.state.modules.isEmpty {
                    Section {
                        Text("添加 .sgmodule 链接后，会解析里面的脚本、面板、规则、重写与 MITM 条目。")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
                ForEach($store.state.modules) { $module in
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle(isOn: $module.enabled) {
                            Text(module.name).font(.subheadline.weight(.semibold))
                        }
                        Text(module.url).font(.caption2).foregroundStyle(.secondary).lineLimit(2)
                        Text(module.summary).font(.caption2).foregroundStyle(.secondary)
                        if !module.lastError.isEmpty {
                            Text(module.lastError).font(.caption2).foregroundStyle(.red)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onDelete { offsets in store.state.modules.remove(atOffsets: offsets) }
            }
            .navigationTitle("模组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddModuleView(store: store) }
        }
    }
}

struct AddModuleView: View {
    @ObservedObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var url = ""
    @State private var loading = false
    @State private var error = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("模组链接") {
                    TextField("https://…/xxx.sgmodule", text: $url)
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
                            Text(loading ? "解析中…" : "导入模组")
                        }
                    }
                    .disabled(loading || url.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("添加模组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("取消") { dismiss() } }
            }
        }
    }

    private func submit() {
        error = ""
        loading = true
        let settings = store.state.settings
        let rawURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        Task {
            do {
                let text = try await Fetcher.fetch(rawURL, settings: settings)
                let parsed = ModuleParser.parse(text, fallbackName: "模组 \(store.state.modules.count + 1)")
                var item = ModuleItem(name: parsed.name, url: rawURL)
                item.scriptCount = parsed.script
                item.panelCount = parsed.panel
                item.ruleCount = parsed.rule
                item.rewriteCount = parsed.rewrite
                item.mitmCount = parsed.mitm
                item.raw = text
                if parsed.script + parsed.panel + parsed.rule + parsed.rewrite == 0 {
                    item.lastError = "没有解析到有效段落，确认是 .sgmodule 文件"
                }
                store.state.modules.append(item)
                loading = false
                dismiss()
            } catch let err {
                error = err.localizedDescription
                loading = false
            }
        }
    }
}

// MARK: - 设置

struct SettingsView: View {
    @ObservedObject var store: Store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("配置名称", text: $store.state.configName)
                } header: { Text("配置") }

                Section {
                    Picker("类型", selection: $store.state.settings.proxyType) {
                        ForEach(LocalProxyType.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    if store.state.settings.proxyType != .none {
                        TextField("主机", text: $store.state.settings.proxyHost)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        TextField("端口", value: $store.state.settings.proxyPort, format: .number)
                            .keyboardType(.numberPad)
                    }
                } header: { Text("本地代理（仅 App 内请求）") } footer: {
                    Text("用于拉订阅、测速时的出口。不做系统级接管。")
                        .font(.caption2)
                }

                Section {
                    Button("恢复默认规则") {
                        store.state.rules = Store.defaultRules()
                    }
                } header: { Text("维护") }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SurgeLite 1.0").font(.caption)
                        Text("配置 / 订阅 / 规则 / 模组管理器，兼容 Surge 规则语法。")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                } header: { Text("关于") }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() } }
            }
        }
    }
}

// MARK: - 导出

struct ExportView: View {
    @ObservedObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var mode = 0
    @State private var fileURL: URL? = nil

    private let fileName = "SurgeLite-export.txt"

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("内容", selection: $mode) {
                    Text("规则片段").tag(0)
                    Text("节点清单").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                ScrollView {
                    Text(preview)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                }
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)

                if let fileURL = fileURL {
                    ShareLink(item: fileURL) {
                        Label("导出文件", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
            .navigationTitle("导出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("关闭") { dismiss() } }
            }
            .onAppear { writeFile() }
            .onChange(of: mode) { _, _ in writeFile() }
        }
    }

    private var preview: String {
        mode == 0 ? Exporter.surgeText(state: store.state) : Exporter.nodeListText(state: store.state)
    }

    private func writeFile() {
        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent(fileName)
        try? preview.write(to: url, atomically: true, encoding: .utf8)
        fileURL = url
    }
}
