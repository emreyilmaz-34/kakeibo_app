import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/simple_card.dart';
import '../widgets/ad_banner_widget.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    setState(() {});
  }

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    var filtered = expenses;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((expense) {
        final query = _searchQuery.toLowerCase();
        return (expense.note?.toLowerCase().contains(query) ?? false) ||
            (expense.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_startDate != null) {
      filtered = filtered.where((expense) =>
          expense.date.isAfter(_startDate!.subtract(const Duration(days: 1)))).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((expense) =>
          expense.date.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }

    if (_selectedCategory != null) {
      filtered = filtered.where((expense) => expense.category == _selectedCategory).toList();
    }

    return filtered;
  }

  List<String> _getCategories(List<Expense> expenses) {
    final categories = expenses.map((e) => e.category).whereType<String>().toSet().toList();
    categories.sort();
    return categories;
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

  String _getFilterText() {
    final parts = <String>[];
    if (_startDate != null && _endDate != null) {
      parts.add('${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}');
    }
    if (_selectedCategory != null) {
      parts.add(_selectedCategory!);
    }
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final filteredExpenses = _getFilteredExpenses(expenseProvider.expenses);
    final hasActiveFilters = _startDate != null || _endDate != null || _selectedCategory != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => _FilterBottomSheet(
                      startDate: _startDate,
                      endDate: _endDate,
                      selectedCategory: _selectedCategory,
                      categories: _getCategories(expenseProvider.expenses),
                      onDateRangeSelected: (start, end) {
                        setState(() {
                          _startDate = start;
                          _endDate = end;
                        });
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      onClearFilters: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                          _selectedCategory = null;
                        });
                        Navigator.pop(context);
                        _applyFilters();
                      },
                    ),
                  );
                },
              ),
              if (hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Active Filters
          if (hasActiveFilters)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt_rounded, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getFilterText(),
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _selectedCategory = null;
                      });
                      _applyFilters();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Expenses List
          Expanded(
            child: expenseProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredExpenses.isEmpty
                    ? FadeInWidget(
                        delay: const Duration(milliseconds: 100),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                expenseProvider.expenses.isEmpty
                                    ? Icons.receipt_long_rounded
                                    : Icons.search_off_rounded,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                expenseProvider.expenses.isEmpty
                                    ? 'No expenses yet'
                                    : 'No matching expenses',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                expenseProvider.expenses.isEmpty
                                    ? 'Add your first expense to get started'
                                    : 'Try adjusting your filters',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => expenseProvider.loadExpenses(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = filteredExpenses[index];
                            return FadeInWidget(
                              delay: Duration(milliseconds: 50 + (index * 20)),
                              child: SimpleCard(
                                padding: EdgeInsets.zero,
                                onTap: () => context.push('/expenses/${expense.id}'),
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
                                      _getCategoryIcon(expense.category),
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    expense.category ?? 'Uncategorized',
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
                                        DateFormat('MMM dd, yyyy').format(expense.date),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (expense.note != null && expense.note!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          expense.note!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Text(
                                    '${_getCurrencySymbol(expense.currency)}${NumberFormat.currency(symbol: '').format(expense.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),

          // Banner Ad
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: AdBannerWidget(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'expenses_fab',
        onPressed: () => context.go('/expenses/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedCategory;
  final List<String> categories;
  final Function(DateTime?, DateTime?) onDateRangeSelected;
  final Function(String?) onCategorySelected;
  final VoidCallback onClearFilters;

  const _FilterBottomSheet({
    required this.startDate,
    required this.endDate,
    required this.selectedCategory,
    required this.categories,
    required this.onDateRangeSelected,
    required this.onCategorySelected,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SimpleCard(
            padding: EdgeInsets.zero,
            onTap: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: startDate != null && endDate != null
                    ? DateTimeRange(start: startDate!, end: endDate!)
                    : null,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppTheme.primaryColor,
                        onPrimary: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onDateRangeSelected(picked.start, picked.end);
              }
            },
            child: ListTile(
              leading: Icon(Icons.date_range_rounded, color: AppTheme.primaryColor),
              title: const Text('Date Range'),
              subtitle: Text(
                startDate != null && endDate != null
                    ? '${DateFormat('MMM dd, yyyy').format(startDate!)} - ${DateFormat('MMM dd, yyyy').format(endDate!)}'
                    : 'Select date range',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) onCategorySelected(null);
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: selectedCategory == null ? AppTheme.primaryColor : null,
                    fontWeight: selectedCategory == null ? FontWeight.bold : null,
                  ),
                ),
                ...categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    onSelected: (selected) {
                      onCategorySelected(selected ? category : null);
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selectedCategory == category ? AppTheme.primaryColor : null,
                      fontWeight: selectedCategory == category ? FontWeight.bold : null,
                    ),
                  );
                }),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.grey.shade800,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Clear All Filters'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
