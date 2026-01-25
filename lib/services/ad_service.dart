// Temporarily disabled for mock data testing
// TODO: Uncomment when google_mobile_ads package is added back

// import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID

  static String get bannerAdUnitId => _bannerAdUnitId;
  static String get interstitialAdUnitId => _interstitialAdUnitId;

  static Future<void> initialize() async {
    // Stub - no-op for mock data testing
  }

  static dynamic createBannerAd({
    required dynamic adSize,
    required void Function(dynamic) onAdLoaded,
    required void Function(dynamic, dynamic) onAdFailedToLoad,
  }) {
    // Stub - returns null for mock data testing
    return null;
  }

  static void loadInterstitialAd({
    required void Function() onAdLoaded,
    required void Function() onAdFailedToLoad,
  }) {
    // Stub - no-op for mock data testing
    onAdFailedToLoad();
  }

  static void showInterstitialAd({
    required void Function() onAdDismissed,
    required void Function() onAdFailedToShow,
  }) {
    // Stub - no-op for mock data testing
    onAdFailedToShow();
  }

  static void disposeInterstitialAd() {
    // Stub - no-op for mock data testing
  }
}
