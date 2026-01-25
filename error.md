➜  kakeibo_app git:(main) ✗ flutter run
Resolving dependencies... 
Downloading packages... 
  characters 1.4.0 (1.4.1 available)
  flutter_lints 5.0.0 (6.0.0 available)
  flutter_secure_storage 9.2.4 (10.0.0 available)
  flutter_secure_storage_linux 1.2.3 (3.0.0 available)
  flutter_secure_storage_macos 3.1.3 (4.0.0 available)
  flutter_secure_storage_platform_interface 1.1.2 (2.0.1 available)
  flutter_secure_storage_web 1.2.1 (2.1.0 available)
  flutter_secure_storage_windows 3.1.2 (4.1.0 available)
  go_router 14.8.1 (17.0.1 available)
  js 0.6.7 (0.7.2 available)
  lints 5.1.1 (6.0.0 available)
  matcher 0.12.17 (0.12.18 available)
  material_color_utilities 0.11.1 (0.13.0 available)
  meta 1.16.0 (1.18.0 available)
  path_provider_foundation 2.5.1 (2.6.0 available)
  test_api 0.7.6 (0.7.9 available)
These packages are no longer being depended on:
- google_mobile_ads 4.0.0
- in_app_purchase 3.2.3
- in_app_purchase_android 0.4.0+8
- in_app_purchase_platform_interface 1.4.0
- in_app_purchase_storekit 0.4.7
- json_annotation 4.9.0
- webview_flutter 4.9.0
- webview_flutter_android 3.16.9
- webview_flutter_platform_interface 2.14.0
- webview_flutter_wkwebview 3.23.5
Changed 10 dependencies!
16 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Launching lib/main.dart on iPhone 13 in debug mode...
Running pod install...                                             621ms
Running Xcode build...                                                  
Xcode build done.
12.4s
Failed to build iOS app
Error output from Xcode build:
↳
    --- xcodebuild: WARNING: Using the first of multiple
    matching destinations:
    { platform:iOS Simulator,
    id:74C39DAF-DA6F-477E-A8FE-9E2E0C3FDEE2, OS:17.5,
    name:iPhone 13 }
    { platform:iOS Simulator,
    id:74C39DAF-DA6F-477E-A8FE-9E2E0C3FDEE2, OS:17.5,
    name:iPhone 13 }
    ** BUILD FAILED **


Xcode's output:
↳
    Writing result bundle at path:
        /var/folders/55/t4mfd_qx2xlct3s2t36tqhm80000gn/T/flutter
        _tools.pBTJXw/flutter_ios_build_temp_dir8cEooO/temporary
        _xcresult_bundle

    lib/screens/expense_detail_screen.dart:27:8: Error: Type
    'Asset' not found.
      List<Asset> _assets = [];
           ^^^^^
    lib/screens/expense_detail_screen.dart:27:8: Error:
    'Asset' isn't a type.
      List<Asset> _assets = [];
           ^^^^^
    Target kernel_snapshot_program failed: Exception
    Failed to package
    /Users/emreyilmaz/work/apps/kakeibo_app.
    Command PhaseScriptExecution failed with a nonzero exit
    code
    warning: Stale file
    '/Users/emreyilmaz/work/apps/kakeibo_app/build/ios/Debug-
    iphonesimulator/Runner.app/Frameworks/FBLPromises.framewo
    rk' is located outside of the allowed root paths.

    warning: Stale file
    '/Users/emreyilmaz/work/apps/kakeibo_app/build/ios/Debug-
    iphonesimulator/Runner.app/Frameworks/GoogleUtilities.fra
    mework' is located outside of the allowed root paths.

    warning: Stale file
    '/Users/emreyilmaz/work/apps/kakeibo_app/build/ios/Debug-
    iphonesimulator/Runner.app/Frameworks/in_app_purchase_sto
    rekit.framework' is located outside of the allowed root
    paths.

    warning: Stale file
    '/Users/emreyilmaz/work/apps/kakeibo_app/build/ios/Debug-
    iphonesimulator/Runner.app/Frameworks/nanopb.framework'
    is located outside of the allowed root paths.

    warning: Stale file
    '/Users/emreyilmaz/work/apps/kakeibo_app/build/ios/Debug-
    iphonesimulator/Runner.app/Frameworks/webview_flutter_wkw
    ebview.framework' is located outside of the allowed root
    paths.

    warning: Stale file
    '/Users/emreyilmaz/work/apps/kakeibo_app/build/ios/Debug-
    iphonesimulator/Runner.app/UserMessagingPlatformResources
    .bundle' is located outside of the allowed root paths.

    warning: Stale file
    '/Users/emreyilmaz/work/apps/kakeibo_app/build/ios/Debug-
    iphonesimulator/Runner.app/google_mobile_ads.bundle' is
    located outside of the allowed root paths.

    /Users/emreyilmaz/work/apps/kakeibo_app/ios/Pods/Pods.xco
    deproj: warning: The iOS Simulator deployment target
    'IPHONEOS_DEPLOYMENT_TARGET' is set to 9.0, but the range
    of supported deployment target versions is 12.0 to
    17.5.99. (in target
    'flutter_secure_storage-flutter_secure_storage' from
    project 'Pods')
    note: Run script build phase 'Thin Binary' will be run
    during every build because the option to run the script
    phase "Based on dependency analysis" is unchecked. (in
    target 'Runner' from project 'Runner')
    note: Run script build phase 'Run Script' will be run
    during every build because the option to run the script
    phase "Based on dependency analysis" is unchecked. (in
    target 'Runner' from project 'Runner')

Could not build the application for the simulator.
Error launching application on iPhone 13.
➜  kakeibo_app git:(main) ✗ 