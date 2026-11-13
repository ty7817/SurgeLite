# Build report

时间：Fri Nov 13 09:03:10 UTC 2026

```
290:/Users/runner/work/SurgeLite/SurgeLite/SurgeLite/Engine.swift:710:18: warning: concurrently-executed local function 'finish' must be marked as '@Sendable'; this is an error in the Swift 6 language mode
345:2026-11-13 09:03:09.766 appintentsmetadataprocessor[2307:10661] warning: Metadata extraction skipped. No AppIntents.framework dependency found.
370:** BUILD SUCCEEDED **
372:EXIT_CODE=0
```

## 日志尾部
```
    cd /Users/runner/work/SurgeLite/SurgeLite
    builtin-infoPlistUtility /Users/runner/work/SurgeLite/SurgeLite/SurgeLite/Info.plist -producttype com.apple.product-type.application -genpkginfo /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/PkgInfo -expandbuildsettings -format binary -platform iphoneos -additionalcontentfile /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/assetcatalog_generated_info.plist -requiredArchitecture arm64 -o /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Info.plist

CopySwiftLibs /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    builtin-swiftStdLibTool --copy --verbose --scan-executable /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SurgeLite --scan-folder /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Frameworks --scan-folder /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/PlugIns --scan-folder /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SystemExtensions --scan-folder /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Extensions --platform iphoneos --toolchain /var/run/com.apple.security.cryptexd/mnt/com.apple.MobileAsset.MetalToolchain-v17.6.109.0.QxbefN/Metal.xctoolchain --toolchain /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain --destination /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Frameworks --strip-bitcode --strip-bitcode-tool /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/bitcode_strip --emit-dependency-info /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/SwiftStdLibToolInputDependencies.dep --filter-for-swift-os --back-deploy-swift-span
Ignoring --strip-bitcode because --sign was not passed

ExtractAppIntentsMetadata (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/appintentsmetadataprocessor --toolchain-dir /var/run/com.apple.security.cryptexd/mnt/com.apple.MobileAsset.MetalToolchain-v17.6.109.0.QxbefN/Metal.xctoolchain --module-name SurgeLite --sdk-root /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk --xcode-version 17F113 --platform-family iOS --deployment-target 17.0 --bundle-identifier com.ty7817.surgelite --output /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app --target-triple arm64-apple-ios17.0 --binary-file /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SurgeLite --dependency-file /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite_dependency_info.dat --stringsdata-file /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/ExtractedAppShortcutsMetadata.stringsdata --source-file-list /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite.SwiftFileList --metadata-file-list /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/SurgeLite.DependencyMetadataFileList --static-metadata-file-list /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/SurgeLite.DependencyStaticMetadataFileList --swift-const-vals-list /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite.SwiftConstValuesFileList --compile-time-extraction --deployment-aware-processing --validate-assistant-intents --no-app-shortcuts-localization
2026-11-13 09:03:09.744 appintentsmetadataprocessor[2307:10661] Starting appintentsmetadataprocessor export
2026-11-13 09:03:09.766 appintentsmetadataprocessor[2307:10661] warning: Metadata extraction skipped. No AppIntents.framework dependency found.

GenerateDSYMFile /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app.dSYM /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SurgeLite (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dsymutil /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SurgeLite -o /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app.dSYM

AppIntentsSSUTraining (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/appintentsnltrainingprocessor --infoplist-path /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Info.plist --temp-dir-path /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/ssu --bundle-id com.ty7817.surgelite --product-path /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app --extracted-metadata-path /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Metadata.appintents --metadata-file-list /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/SurgeLite.DependencyMetadataFileList --source-file /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Info.plist --archive-ssu-assets
2026-11-13 09:03:09.831 appintentsnltrainingprocessor[2312:10684] Parsing options for appintentsnltrainingprocessor
2026-11-13 09:03:09.832 appintentsnltrainingprocessor[2312:10684] Starting AppIntents SSU YAML Generation
2026-11-13 09:03:09.836 appintentsnltrainingprocessor[2312:10684] No AppShortcuts found - Skipping.

RegisterExecutionPolicyException /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    builtin-RegisterExecutionPolicyException /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app

Validate /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    builtin-validationUtility /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app -shallow-bundle -infoplist-subpath Info.plist

Touch /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    /usr/bin/touch -c /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app

** BUILD SUCCEEDED **

EXIT_CODE=0
```
