import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/asset.dart';
import '../theme/app_theme.dart';
import '../widgets/simple_card.dart';
import '../widgets/animations/fade_in_widget.dart';

class AssetComparisonWidget extends StatelessWidget {
  final double expenseAmount;
  final String currency;
  final DateTime expenseDate;
  final List<Asset> assets;

  const AssetComparisonWidget({
    super.key,
    required this.expenseAmount,
    required this.currency,
    required this.expenseDate,
    required this.assets,
  });

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.compare_arrows_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              'What you could have bought',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...assets.asMap().entries.map((entry) {
          final index = entry.key;
          final asset = entry.value;
          final quantity = expenseAmount / asset.price;

          return FadeInWidget(
            delay: Duration(milliseconds: 50 + (index * 30)),
            child: SimpleCard(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getAssetIcon(asset.type),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getCurrencySymbol(asset.currency)}${NumberFormat.currency(symbol: '').format(asset.price)} per ${asset.unit}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${quantity.toStringAsFixed(2)} ${asset.unit}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                      ),
                      Text(
                        asset.symbol,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          'Prices as of ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }

  IconData _getAssetIcon(AssetType type) {
    switch (type) {
      case AssetType.stock:
        return Icons.trending_up_rounded;
      case AssetType.etf:
        return Icons.account_balance_rounded;
      case AssetType.commodity:
        return Icons.diamond_rounded;
      case AssetType.crypto:
        return Icons.currency_bitcoin_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'TRY':
        return '₺';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }
}
