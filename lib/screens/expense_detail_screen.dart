import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/simple_card.dart';
import '../widgets/animated_counter.dart';
import '../widgets/asset_comparison_widget.dart';
import '../services/mock_asset_service.dart';
import '../models/asset.dart';
import '../providers/settings_provider.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  Expense? _expense;
  bool _isLoading = true;
  List<Asset> _assets = [];
  bool _isLoadingAssets = false;

  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  Future<void> _loadExpense() async {
    try {
      final expenseProvider = context.read<ExpenseProvider>();
      await expenseProvider.loadExpenses();
      final expense = expenseProvider.expenses.firstWhere(
        (e) => e.id == widget.expenseId,
        orElse: () => throw Exception('Expense not found'),
      );
      // Load assets for comparison if premium
      final settingsProvider = context.read<SettingsProvider>();
      if (settingsProvider.isPremium) {
        await _loadAssets();
      }

      setState(() {
        _expense = expense;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading expense: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    }
  }

  Future<void> _loadAssets() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingAssets = true;
    });

    try {
      final assets = await MockAssetService.getAllAssets();
      if (mounted) {
        setState(() {
          _assets = assets;
          _isLoadingAssets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAssets = false;
        });
      }
    }
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.category_rounded;
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Icons.restaurant_rounded;
      case 'transportation':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills & utilities':
        return Icons.receipt_long_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'healthcare':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'travel':
        return Icons.flight_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_expense == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Expense not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.go('/expenses/${_expense!.id}/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
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
                        _getCategoryIcon(_expense!.category),
                        color: AppTheme.primaryColor,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedCounter(
                      value: _expense!.amount,
                      prefix: _getCurrencySymbol(_expense!.currency),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _expense!.category ?? 'Uncategorized',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                      icon: Icons.calendar_today_rounded,
                      title: 'Date',
                      value: DateFormat('EEEE, MMMM dd, yyyy').format(_expense!.date),
                    ),
                    const Divider(height: 1),
                    _buildDetailTile(
                      icon: Icons.category_rounded,
                      title: 'Category',
                      value: _expense!.category ?? 'Uncategorized',
                    ),
                    if (_expense!.note != null && _expense!.note!.isNotEmpty) ...[
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
                              _expense!.note!,
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
                      value: DateFormat('MMM dd, yyyy • HH:mm').format(_expense!.createdAt),
                      isSmall: true,
                    ),
                    if (_expense!.updatedAt != _expense!.createdAt) ...[
                      const Divider(height: 1),
                      _buildDetailTile(
                        icon: Icons.update_rounded,
                        title: 'Last Updated',
                        value: DateFormat('MMM dd, yyyy • HH:mm').format(_expense!.updatedAt),
                        isSmall: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Asset Comparison (Premium only)
            Builder(
              builder: (context) {
                final settingsProvider = context.watch<SettingsProvider>();
                
                if (!settingsProvider.isPremium) {
                  return const SizedBox.shrink();
                }

                if (_isLoadingAssets) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return FadeInWidget(
                  delay: const Duration(milliseconds: 200),
                  child: AssetComparisonWidget(
                    expenseAmount: _expense!.amount,
                    currency: _expense!.currency,
                    expenseDate: _expense!.date,
                    assets: _assets,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Edit Button
            FadeInWidget(
              delay: const Duration(milliseconds: 250),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/expenses/${_expense!.id}/edit'),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit Expense'),
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
