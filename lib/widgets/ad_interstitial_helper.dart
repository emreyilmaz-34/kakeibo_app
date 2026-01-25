import 'package:shared_preferences/shared_preferences.dart';
// import '../services/ad_service.dart';

class AdInterstitialHelper {
  static const String _expenseCountKey = 'expense_count_for_ad';
  static const int _expensesPerAd = 3; // Her 3 harcamada bir reklam göster

  static Future<void> onExpenseAdded({
    required void Function() onAdShown,
    required void Function() onAdFailed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(_expenseCountKey) ?? 0;
    count++;

    await prefs.setInt(_expenseCountKey, count);

    // Her X harcamada bir reklam göster
    if (count >= _expensesPerAd) {
      await prefs.setInt(_expenseCountKey, 0);

      // TODO: Uncomment when google_mobile_ads is installed
      // Interstitial reklamı yükle ve göster
      // AdService.loadInterstitialAd(
      //   onAdLoaded: () {
      //     AdService.showInterstitialAd(
      //       onAdDismissed: onAdShown,
      //       onAdFailedToShow: onAdFailed,
      //     );
      //   },
      //   onAdFailedToLoad: onAdFailed,
      // );
      
      // For now, just call onAdShown
      onAdShown();
    } else {
      onAdShown();
    }
  }

  static Future<void> resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_expenseCountKey, 0);
  }
}
