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

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  Map<String, Asset> _assetPrices = {};
  bool _isLoadingPrices = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<HoldingProvider>().loadHoldings();
      await _loadAssetPrices();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload prices when holdings change
    final holdings = context.watch<HoldingProvider>().holdings;
    if (holdings.isNotEmpty && _assetPrices.isEmpty && !_isLoadingPrices) {
      _loadAssetPrices();
    }
  }

  Future<void> _loadAssetPrices() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingPrices = true;
    });

    try {
      final holdings = context.read<HoldingProvider>().holdings;
      final symbols = holdings.map((h) => h.symbol).toSet().toList();
      if (symbols.isNotEmpty) {
        final prices = await MockAssetService.getPrices(symbols);
        if (mounted) {
          setState(() {
            _assetPrices = prices;
            _isLoadingPrices = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingPrices = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPrices = false;
        });
      }
    }
  }

  double _getTotalValue(List<Holding> holdings) {
    double total = 0;
    for (final holding in holdings) {
      final asset = _assetPrices[holding.symbol];
      if (asset != null) {
        total += holding.quantity * asset.price;
      }
    }
    return total;
  }

  double _getTotalPL(List<Holding> holdings) {
    double totalPL = 0;
    for (final holding in holdings) {
      if (holding.buyPrice != null) {
        final asset = _assetPrices[holding.symbol];
        if (asset != null) {
          totalPL += holding.quantity * (asset.price - holding.buyPrice!);
        }
      }
    }
    return totalPL;
  }

  @override
  Widget build(BuildContext context) {
    final holdingProvider = context.watch<HoldingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              holdingProvider.loadHoldings();
              _loadAssetPrices();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: holdingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : holdingProvider.holdings.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    await holdingProvider.loadHoldings();
                    await _loadAssetPrices();
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Value Card
                        FadeInWidget(
                          delay: const Duration(milliseconds: 50),
                          child: SimpleCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Total Portfolio Value',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                AnimatedCounter(
                                  value: _getTotalValue(holdingProvider.holdings),
                                  prefix: '₺',
                                  formatter: NumberFormat.currency(
                                    symbol: '',
                                    decimalDigits: 2,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                ),
                                if (_getTotalPL(holdingProvider.holdings) != 0) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        _getTotalPL(holdingProvider.holdings) >= 0
                                            ? Icons.trending_up_rounded
                                            : Icons.trending_down_rounded,
                                        color: _getTotalPL(holdingProvider.holdings) >= 0
                                            ? AppTheme.successColor
                                            : Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_getTotalPL(holdingProvider.holdings) >= 0 ? '+' : ''}₺${NumberFormat.currency(symbol: '').format(_getTotalPL(holdingProvider.holdings))}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _getTotalPL(holdingProvider.holdings) >= 0
                                              ? AppTheme.successColor
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Holdings List
                        Text(
                          'Holdings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...holdingProvider.holdings.asMap().entries.map((entry) {
                          final index = entry.key;
                          final holding = entry.value;
                          final asset = _assetPrices[holding.symbol];
                          final currentValue = asset != null
                              ? holding.quantity * asset.price
                              : 0.0;
                          final pl = holding.buyPrice != null && asset != null
                              ? holding.quantity * (asset.price - holding.buyPrice!)
                              : null;
                          final plPercent = holding.buyPrice != null && asset != null
                              ? ((asset.price - holding.buyPrice!) / holding.buyPrice!) * 100
                              : null;

                          return FadeInWidget(
                            delay: Duration(milliseconds: 100 + (index * 30)),
                            child: SimpleCard(
                              padding: EdgeInsets.zero,
                              onTap: () => context.go('/portfolio/${holding.id}'),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.trending_up_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  holding.symbol,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${holding.quantity} ${holding.unit}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (asset != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '₺${NumberFormat.currency(symbol: '').format(asset.price)} per ${asset.unit}',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '₺${NumberFormat.currency(symbol: '').format(currentValue)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    if (pl != null && plPercent != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            pl >= 0
                                                ? Icons.arrow_upward_rounded
                                                : Icons.arrow_downward_rounded,
                                            size: 14,
                                            color: pl >= 0
                                                ? AppTheme.successColor
                                                : Colors.red,
                                          ),
                                          Text(
                                            '${pl >= 0 ? '+' : ''}₺${NumberFormat.currency(symbol: '').format(pl.abs())} (${plPercent >= 0 ? '+' : ''}${plPercent.toStringAsFixed(1)}%)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: pl >= 0
                                                  ? AppTheme.successColor
                                                  : Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'portfolio_fab',
        onPressed: () => context.go('/portfolio/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Holding'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No holdings yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first holding to track your portfolio',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/portfolio/add'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Holding'),
          ),
        ],
      ),
    );
  }
}
