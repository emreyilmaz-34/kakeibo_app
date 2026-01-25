import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/simple_card.dart';
// import '../services/iap_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Premium Status Card
          FadeInWidget(
            delay: const Duration(milliseconds: 50),
            child: SimpleCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: settingsProvider.isPremium
                              ? LinearGradient(
                                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                )
                              : null,
                          color: settingsProvider.isPremium
                              ? null
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          settingsProvider.isPremium
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: settingsProvider.isPremium
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settingsProvider.isPremium
                                  ? 'Premium Member'
                                  : 'Free Plan',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              settingsProvider.isPremium
                                  ? 'Enjoy ad-free experience'
                                  : 'Upgrade to remove ads',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!settingsProvider.isPremium) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/premium'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Upgrade to Premium'),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // TODO: Uncomment when in_app_purchase is installed
                          // try {
                          //   await IAPService.instance.restorePurchases();
                          //   if (context.mounted) {
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       const SnackBar(
                          //         content: Text('Purchases restored'),
                          //         backgroundColor: AppTheme.successColor,
                          //       ),
                          //     );
                          //   }
                          // } catch (e) {
                          //   if (context.mounted) {
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(
                          //         content: Text('Error: $e'),
                          //       ),
                          //     );
                          //   }
                          // }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Restore purchases coming soon'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.restore_rounded),
                        label: const Text('Restore Purchases'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Currency Settings
          FadeInWidget(
            delay: const Duration(milliseconds: 100),
            child: SimpleCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.currency_exchange_rounded, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'Currency',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...['TRY', 'USD', 'EUR', 'GBP'].map((currency) {
                    final isSelected = settingsProvider.preferredCurrency == currency;
                    return ListTile(
                      title: Text(currency),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
                          : null,
                      onTap: () {
                        settingsProvider.setPreferredCurrency(currency);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          FadeInWidget(
            delay: const Duration(milliseconds: 150),
            child: SimpleCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kakeibo v1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your expenses and build financial awareness',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
