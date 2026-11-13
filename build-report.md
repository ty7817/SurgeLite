# Build report

时间：Fri Nov 13 08:20:37 UTC 2026

```
263:/Users/runner/work/SurgeLite/SurgeLite/SurgeLite/Engine.swift:541:18: warning: concurrently-executed local function 'finish' must be marked as '@Sendable'; this is an error in the Swift 6 language mode
306:2026-11-13 08:20:36.093 appintentsmetadataprocessor[2762:12448] warning: Metadata extraction skipped. No AppIntents.framework dependency found.
327:warning: All interface orientations must be supported unless the app requires full screen. (in target 'SurgeLite' from project 'SurgeLite')
333:** BUILD SUCCEEDED **
335:EXIT_CODE=0
```

## 日志尾部
```
    /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -Xlinker -reproducible -target arm64-apple-ios17.0 -isysroot /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk -Os -L/Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/EagerLinkingTBDs/Release-iphoneos -L/Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos -F/Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/EagerLinkingTBDs/Release-iphoneos -F/Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos -filelist /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite.LinkFileList -Xlinker -rpath -Xlinker /usr/lib/swift -Xlinker -rpath -Xlinker @executable_path/Frameworks -Xlinker -dead_strip -Xlinker -object_path_lto -Xlinker /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite_lto.o -Xlinker -dependency_info -Xlinker /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite_dependency_info.dat -fobjc-link-runtime -L/Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphoneos -L/usr/lib/swift -Xlinker -add_ast_path -Xlinker /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite.swiftmodule @/Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite-linker-args.resp -o /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SurgeLite

GenerateDSYMFile /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app.dSYM /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SurgeLite (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dsymutil /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SurgeLite -o /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app.dSYM

ExtractAppIntentsMetadata (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/appintentsmetadataprocessor --toolchain-dir /var/run/com.apple.security.cryptexd/mnt/com.apple.MobileAsset.MetalToolchain-v17.6.109.0.J2ZNyZ/Metal.xctoolchain --module-name SurgeLite --sdk-root /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk --xcode-version 17F113 --platform-family iOS --deployment-target 17.0 --bundle-identifier com.ty7817.surgelite --output /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app --target-triple arm64-apple-ios17.0 --binary-file /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SurgeLite --dependency-file /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite_dependency_info.dat --stringsdata-file /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/ExtractedAppShortcutsMetadata.stringsdata --source-file-list /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite.SwiftFileList --metadata-file-list /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/SurgeLite.DependencyMetadataFileList --static-metadata-file-list /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/SurgeLite.DependencyStaticMetadataFileList --swift-const-vals-list /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/Objects-normal/arm64/SurgeLite.SwiftConstValuesFileList --compile-time-extraction --deployment-aware-processing --validate-assistant-intents --no-app-shortcuts-localization
2026-11-13 08:20:36.082 appintentsmetadataprocessor[2762:12448] Starting appintentsmetadataprocessor export
2026-11-13 08:20:36.093 appintentsmetadataprocessor[2762:12448] warning: Metadata extraction skipped. No AppIntents.framework dependency found.

CopySwiftLibs /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    builtin-swiftStdLibTool --copy --verbose --scan-executable /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SurgeLite --scan-folder /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Frameworks --scan-folder /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/PlugIns --scan-folder /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/SystemExtensions --scan-folder /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Extensions --platform iphoneos --toolchain /var/run/com.apple.security.cryptexd/mnt/com.apple.MobileAsset.MetalToolchain-v17.6.109.0.J2ZNyZ/Metal.xctoolchain --toolchain /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain --destination /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Frameworks --strip-bitcode --strip-bitcode-tool /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/bitcode_strip --emit-dependency-info /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/SwiftStdLibToolInputDependencies.dep --filter-for-swift-os --back-deploy-swift-span
Ignoring --strip-bitcode because --sign was not passed

AppIntentsSSUTraining (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    /Applications/Xcode_26.6.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/appintentsnltrainingprocessor --infoplist-path /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Info.plist --temp-dir-path /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/ssu --bundle-id com.ty7817.surgelite --product-path /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app --extracted-metadata-path /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Metadata.appintents --metadata-file-list /Users/runner/work/SurgeLite/SurgeLite/build/Build/Intermediates.noindex/SurgeLite.build/Release-iphoneos/SurgeLite.build/SurgeLite.DependencyMetadataFileList --source-file /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app/Info.plist --archive-ssu-assets
2026-11-13 08:20:36.152 appintentsnltrainingprocessor[2763:12454] Parsing options for appintentsnltrainingprocessor
2026-11-13 08:20:36.153 appintentsnltrainingprocessor[2763:12454] Starting AppIntents SSU YAML Generation
2026-11-13 08:20:36.160 appintentsnltrainingprocessor[2763:12454] No AppShortcuts found - Skipping.

RegisterExecutionPolicyException /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    builtin-RegisterExecutionPolicyException /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app

Validate /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    builtin-validationUtility /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app -shallow-bundle -infoplist-subpath Info.plist
warning: All interface orientations must be supported unless the app requires full screen. (in target 'SurgeLite' from project 'SurgeLite')

Touch /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app (in target 'SurgeLite' from project 'SurgeLite')
    cd /Users/runner/work/SurgeLite/SurgeLite
    /usr/bin/touch -c /Users/runner/work/SurgeLite/SurgeLite/build/Build/Products/Release-iphoneos/SurgeLite.app

** BUILD SUCCEEDED **

EXIT_CODE=0
```
