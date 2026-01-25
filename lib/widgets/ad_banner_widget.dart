import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
// import '../services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  // final AdSize adSize;
  final bool showOnlyIfNotPremium;

  const AdBannerWidget({
    super.key,
    // this.adSize = AdSize.banner,
    this.showOnlyIfNotPremium = true,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  // BannerAd? _bannerAd;
  // bool _isAdLoaded = false;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    // Premium kullanıcılar için reklam gösterme
    if (widget.showOnlyIfNotPremium && settingsProvider.isPremium) {
      return const SizedBox.shrink();
    }

    // TODO: Uncomment when google_mobile_ads is installed
    // For now, return empty widget
    return const SizedBox.shrink();
    
    // Original implementation (commented out):
    // return Container(
    //   alignment: Alignment.center,
    //   width: _bannerAd!.size.width.toDouble(),
    //   height: _bannerAd!.size.height.toDouble(),
    //   child: AdWidget(ad: _bannerAd!),
    // );
  }
}
