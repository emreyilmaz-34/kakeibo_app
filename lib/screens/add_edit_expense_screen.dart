import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/simple_card.dart';
import '../widgets/ad_interstitial_helper.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final String? expenseId;

  const AddEditExpenseScreen({super.key, this.expenseId});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'TRY';
  Expense? _expense;
  bool _isLoading = false;

  final List<String> _categories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Bills & Utilities',
    'Entertainment',
    'Healthcare',
    'Education',
    'Travel',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      _loadExpense();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider = context.read<SettingsProvider>();
        _selectedCurrency = settingsProvider.preferredCurrency;
        setState(() {});
      });
    }
  }

  Future<void> _loadExpense() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenseProvider = context.read<ExpenseProvider>();
      await expenseProvider.loadExpenses();
      _expense = expenseProvider.expenses.firstWhere(
        (e) => e.id == widget.expenseId,
        orElse: () => throw Exception('Expense not found'),
      );

      _amountController.text = _expense!.amount.toString();
      _noteController.text = _expense!.note ?? '';
      _categoryController.text = _expense!.category ?? '';
      _selectedDate = _expense!.date;
      _selectedCurrency = _expense!.currency;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading expense: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/expenses');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final expenseProvider = context.read<ExpenseProvider>();

      final isNewExpense = _expense == null;
      final settingsProvider = context.read<SettingsProvider>();

      if (_expense != null) {
        final updated = _expense!.copyWith(
          amount: amount,
          currency: _selectedCurrency,
          date: _selectedDate,
          category: _categoryController.text.isEmpty ? null : _categoryController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          updatedAt: DateTime.now(),
        );
        await expenseProvider.updateExpense(updated);
      } else {
        await expenseProvider.addExpense(
          amount: amount,
          currency: _selectedCurrency,
          date: _selectedDate,
          category: _categoryController.text.isEmpty ? null : _categoryController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );
      }

      if (mounted) {
        // Yeni expense eklendiyse ve premium değilse interstitial reklam göster
        if (isNewExpense && !settingsProvider.isPremium) {
          await AdInterstitialHelper.onExpenseAdded(
            onAdShown: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        const Text('Expense added!'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppTheme.successColor,
                    margin: const EdgeInsets.all(16),
                  ),
                );
                // Navigate back safely
                if (context.canPop()) {
                  if (context.canPop()) {
          context.pop();
        } else {
          context.go('/expenses');
        }
                } else {
                  context.go('/expenses');
                }
              }
            },
            onAdFailed: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        const Text('Expense added!'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppTheme.successColor,
                    margin: const EdgeInsets.all(16),
                  ),
                );
                // Navigate back safely
                if (context.canPop()) {
                  if (context.canPop()) {
          context.pop();
        } else {
          context.go('/expenses');
        }
                } else {
                  context.go('/expenses');
                }
              }
            },
          );
        } else {
          // Show success message first
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(_expense != null ? 'Expense updated!' : 'Expense added!'),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: AppTheme.successColor,
                margin: const EdgeInsets.all(16),
              ),
            );
          }
          
          // Navigate back safely
          if (mounted) {
            if (context.canPop()) {
              if (context.canPop()) {
          context.pop();
        } else {
          context.go('/expenses');
        }
            } else {
              context.go('/expenses');
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving expense: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _expense == null && widget.expenseId != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                if (context.canPop()) {
          context.pop();
        } else {
          context.go('/expenses');
        }
              } else {
                context.go('/expenses');
              }
            },
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (context.canPop()) {
            if (context.canPop()) {
          context.pop();
        } else {
          context.go('/expenses');
        }
          } else {
            // Eğer pop yapılamıyorsa, expenses listesine dön
            context.go('/expenses');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.expenseId != null ? 'Edit Expense' : 'Add Expense'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                if (context.canPop()) {
          context.pop();
        } else {
          context.go('/expenses');
        }
              } else {
                // Eğer pop yapılamıyorsa, expenses listesine dön
                context.go('/expenses');
              }
            },
          ),
          automaticallyImplyLeading: false,
        actions: [
          if (widget.expenseId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Delete Expense'),
                    content: const Text('Are you sure you want to delete this expense?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && mounted) {
                  try {
                    await context.read<ExpenseProvider>().deleteExpense(widget.expenseId!);
                    if (mounted) {
                      if (context.canPop()) {
          context.pop();
        } else {
          context.go('/expenses');
        }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.white),
                              SizedBox(width: 12),
                              Text('Expense deleted'),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12))),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting expense: $e'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  }
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Amount
            FadeInWidget(
              delay: const Duration(milliseconds: 50),
              child: SimpleCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money_rounded, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'Amount',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '${_getCurrencySymbol(_selectedCurrency)} ',
                        prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date
            FadeInWidget(
              delay: const Duration(milliseconds: 100),
              child: SimpleCard(
                padding: EdgeInsets.zero,
                onTap: _selectDate,
                child: ListTile(
                  leading: Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor),
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category
            FadeInWidget(
              delay: const Duration(milliseconds: 150),
              child: SimpleCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category_rounded, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'Category',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: _categoryController.text),
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _categories;
                        }
                        return _categories.where((category) {
                          return category.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (value) {
                        _categoryController.text = value;
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          onFieldSubmitted: (_) => onFieldSubmitted(),
                          decoration: const InputDecoration(
                            hintText: 'Select or type a category',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Note
            FadeInWidget(
              delay: const Duration(milliseconds: 200),
              child: SimpleCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note_rounded, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'Note (optional)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        hintText: 'Add a note about this expense',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            FadeInWidget(
              delay: const Duration(milliseconds: 250),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_rounded),
                            const SizedBox(width: 8),
                            Text(
                              widget.expenseId != null ? 'Update Expense' : 'Add Expense',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
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
