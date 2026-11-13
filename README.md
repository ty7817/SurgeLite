# SurgeLite

一个 iOS 上的 Surge 风格**配置管理器**：管订阅、管节点、管分流规则、管模组，并能导出 Surge 兼容的规则片段。

> 定位说明：这是「配置 / 订阅 / 规则 / 模组」的管理与编辑工具，**不接管系统流量**。真正的全局代理需要 Network Extension 权限 + 付费开发者账号 + VPN 内核，本工程不包含。

## 功能

- **订阅管理**：支持 Clash / Mihomo YAML、Base64 编码订阅、`ss` / `ssr` / `vmess` / `vless` / `trojan` / `hysteria2` / `tuic` 链接；自动识别格式、去重合并、记录更新时间和错误。
- **节点管理**：按地区识别（HK / TW / JP / SG / US / KR / UK / DE 等）、搜索、区域筛选、滑动手势删除、单节点测速。
- **节点测速与排名**：对每个节点服务器做 TCP 建连延迟测试，并发 8 路，输出延迟排名（金 / 银 / 铜）。
- **出口测速**：对 `x.com`、`t.me` 实测响应延迟，并从 `speed.cloudflare.com` 拉 2 MB 计算下载速率。
- **分流规则**：可视化增删改、拖拽排序、开关；支持 `DOMAIN` / `DOMAIN-SUFFIX` / `DOMAIN-KEYWORD` / `IP-CIDR` / `IP-CIDR6` / `GEOIP` / `RULE-SET` / `FINAL`；内置「输入域名→命中的规则和策略」测试器。
- **模组管理**：导入 `.sgmodule`，解析 `[Script]` / `[Panel]` / `[Rule]` / `[URL Rewrite]` / `[MITM]` 条目数，可启用停用。
- **导出**：生成可直接粘贴进 Surge 的 `[Rule]` 片段（含启用模组原文）、节点 URI 清单，走系统分享。
- **App 内代理**：拉订阅 / 测速时可走 HTTP 或 SOCKS5 代理（只作用于本 App 的请求）。

## 构建

### 方式一：GitHub Actions（推荐，不需要 Mac）

仓库已带 `.github/workflows/build-ipa.yml`，push 到 `main` 后自动：

1. 装 XcodeGen → 生成 `SurgeLite.xcodeproj`
2. `xcodebuild` 编译 Release（不签名）
3. 打包成 `SurgeLite-unsigned.ipa`
4. 上传 artifact，并自动发一个 Release

到 Actions 页面或 Releases 里下载 IPA，再用 Sideloadly / ESign / AltStore / TrollStore 签名安装即可。

### 方式二：本地 Xcode

```bash
brew install xcodegen
xcodegen generate
open SurgeLite.xcodeproj
```

选自己的 Team 和 Bundle ID 后直接 Run 到真机或 Archive。

## 系统要求

- Deployment target：iOS 17.0，可正常安装运行在 **iOS 26** 设备上。
- 用最新 Xcode（iOS 26 SDK）构建时可获得完整的新系统适配。
