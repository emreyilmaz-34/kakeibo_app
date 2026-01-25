import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/holding_provider.dart';
import '../models/holding.dart';
import '../models/asset.dart';
import '../services/mock_asset_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/simple_card.dart';
import '../widgets/animated_counter.dart';

class HoldingDetailScreen extends StatefulWidget {
  final String holdingId;

  const HoldingDetailScreen({super.key, required this.holdingId});

  @override
  State<HoldingDetailScreen> createState() => _HoldingDetailScreenState();
}

class _HoldingDetailScreenState extends State<HoldingDetailScreen> {
  Holding? _holding;
  Asset? _asset;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHolding();
  }

  Future<void> _loadHolding() async {
    try {
      final holdingProvider = context.read<HoldingProvider>();
      await holdingProvider.loadHoldings();
      _holding = holdingProvider.holdings.firstWhere(
        (h) => h.id == widget.holdingId,
        orElse: () => throw Exception('Holding not found'),
      );

      // Load asset price
      final asset = await MockAssetService.getAssetBySymbol(_holding!.symbol);
      setState(() {
        _holding = _holding;
        _asset = asset;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading holding: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Holding Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_holding == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Holding Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Holding not found')),
      );
    }

    final currentValue = _asset != null ? _holding!.quantity * _asset!.price : 0.0;
    final pl = _holding!.buyPrice != null && _asset != null
        ? _holding!.quantity * (_asset!.price - _holding!.buyPrice!)
        : null;
    final plPercent = _holding!.buyPrice != null && _asset != null
        ? ((_asset!.price - _holding!.buyPrice!) / _holding!.buyPrice!) * 100
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holding Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.go('/portfolio/${_holding!.id}/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Value Card
            FadeInWidget(
              delay: const Duration(milliseconds: 50),
              child: SimpleCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: AppTheme.primaryColor,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _holding!.symbol,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedCounter(
                      value: currentValue,
                      prefix: '₺',
                      formatter: NumberFormat.currency(
                        symbol: '',
                        decimalDigits: 2,
                      ),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_holding!.quantity} ${_holding!.unit}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    if (pl != null && plPercent != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: pl >= 0
                              ? AppTheme.successColor.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pl >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              color: pl >= 0 ? AppTheme.successColor : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${pl >= 0 ? '+' : ''}₺${NumberFormat.currency(symbol: '').format(pl.abs())} (${plPercent >= 0 ? '+' : ''}${plPercent.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                color: pl >= 0 ? AppTheme.successColor : Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Details Card
            FadeInWidget(
              delay: const Duration(milliseconds: 100),
              child: SimpleCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildDetailTile(
                      icon: Icons.label_rounded,
                      title: 'Symbol',
                      value: _holding!.symbol,
                    ),
                    const Divider(height: 1),
                    _buildDetailTile(
                      icon: Icons.numbers_rounded,
                      title: 'Quantity',
                      value: '${_holding!.quantity} ${_holding!.unit}',
                    ),
                    if (_asset != null) ...[
                      const Divider(height: 1),
                      _buildDetailTile(
                        icon: Icons.attach_money_rounded,
                        title: 'Current Price',
                        value: '₺${NumberFormat.currency(symbol: '').format(_asset!.price)} per ${_asset!.unit}',
                      ),
                    ],
                    if (_holding!.buyPrice != null) ...[
                      const Divider(height: 1),
                      _buildDetailTile(
                        icon: Icons.shopping_cart_rounded,
                        title: 'Buy Price',
                        value: '₺${NumberFormat.currency(symbol: '').format(_holding!.buyPrice!)} per ${_holding!.unit}',
                      ),
                    ],
                    if (_holding!.buyDate != null) ...[
                      const Divider(height: 1),
                      _buildDetailTile(
                        icon: Icons.calendar_today_rounded,
                        title: 'Buy Date',
                        value: DateFormat('EEEE, MMMM dd, yyyy').format(_holding!.buyDate!),
                      ),
                    ],
                    if (_holding!.note != null && _holding!.note!.isNotEmpty) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.note_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Note',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _holding!.note!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Divider(height: 1),
                    _buildDetailTile(
                      icon: Icons.access_time_rounded,
                      title: 'Created',
                      value: DateFormat('MMM dd, yyyy • HH:mm').format(_holding!.createdAt),
                      isSmall: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Edit Button
            FadeInWidget(
              delay: const Duration(milliseconds: 150),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/portfolio/${_holding!.id}/edit'),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit Holding'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    bool isSmall = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
        size: 20,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
      ),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isSmall ? 13 : null,
            ),
      ),
    );
  }
}
