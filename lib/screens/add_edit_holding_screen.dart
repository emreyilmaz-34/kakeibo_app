import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/holding_provider.dart';
import '../models/holding.dart';
import '../services/mock_asset_service.dart';
import '../models/asset.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/simple_card.dart';

class AddEditHoldingScreen extends StatefulWidget {
  final String? holdingId;

  const AddEditHoldingScreen({super.key, this.holdingId});

  @override
  State<AddEditHoldingScreen> createState() => _AddEditHoldingScreenState();
}

class _AddEditHoldingScreenState extends State<AddEditHoldingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _buyDate;
  Holding? _holding;
  bool _isLoading = false;
  List<Asset> _availableAssets = [];
  List<String> _filteredSymbols = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableAssets();
    if (widget.holdingId != null) {
      _loadHolding();
    } else {
      _unitController.text = 'share';
    }
  }

  Future<void> _loadAvailableAssets() async {
    try {
      final assets = await MockAssetService.getAllAssets();
      setState(() {
        _availableAssets = assets;
        _filteredSymbols = assets.map((a) => a.symbol).toList();
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadHolding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final holdingProvider = context.read<HoldingProvider>();
      await holdingProvider.loadHoldings();
      _holding = holdingProvider.holdings.firstWhere(
        (h) => h.id == widget.holdingId,
        orElse: () => throw Exception('Holding not found'),
      );

      _symbolController.text = _holding!.symbol;
      _quantityController.text = _holding!.quantity.toString();
      _unitController.text = _holding!.unit;
      _buyPriceController.text = _holding!.buyPrice?.toString() ?? '';
      _buyDate = _holding!.buyDate;
      _noteController.text = _holding!.note ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading holding: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/portfolio');
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

  Future<void> _selectBuyDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _buyDate ?? DateTime.now(),
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
    if (picked != null) {
      setState(() {
        _buyDate = picked;
      });
    }
  }

  Future<void> _saveHolding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final quantity = double.parse(_quantityController.text);
      final buyPrice = _buyPriceController.text.isNotEmpty
          ? double.tryParse(_buyPriceController.text)
          : null;
      final holdingProvider = context.read<HoldingProvider>();

      if (_holding != null) {
        final updated = _holding!.copyWith(
          symbol: _symbolController.text.toUpperCase(),
          quantity: quantity,
          unit: _unitController.text,
          buyPrice: buyPrice,
          buyDate: _buyDate,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          updatedAt: DateTime.now(),
        );
        await holdingProvider.updateHolding(updated);
      } else {
        await holdingProvider.addHolding(
          symbol: _symbolController.text.toUpperCase(),
          quantity: quantity,
          unit: _unitController.text,
          buyPrice: buyPrice,
          buyDate: _buyDate,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );
      }

      if (mounted) {
        // Show success message first
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(_holding != null ? 'Holding updated!' : 'Holding added!'),
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
          context.pop();
        } else {
          context.go('/portfolio');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving holding: $e'),
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
    _symbolController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _buyPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _holding == null && widget.holdingId != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
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
          context.go('/portfolio');
        }
          } else {
            context.go('/portfolio');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.holdingId != null ? 'Edit Holding' : 'Add Holding'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                if (context.canPop()) {
          context.pop();
        } else {
          context.go('/portfolio');
        }
              } else {
                context.go('/portfolio');
              }
            },
          ),
          actions: [
            if (widget.holdingId != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Delete Holding'),
                      content: const Text('Are you sure you want to delete this holding?'),
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
                      await context.read<HoldingProvider>().deleteHolding(widget.holdingId!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Holding deleted'),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12))),
                            backgroundColor: Colors.red,
                          ),
                        );
                        // Navigate back safely
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/portfolio');
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting holding: $e'),
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
              // Symbol
              FadeInWidget(
                delay: const Duration(milliseconds: 50),
                child: SimpleCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.label_rounded, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Symbol',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Autocomplete<String>(
                        initialValue: TextEditingValue(text: _symbolController.text),
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _filteredSymbols;
                          }
                          return _filteredSymbols.where((symbol) {
                            return symbol.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase(),
                                );
                          });
                        },
                        onSelected: (value) {
                          _symbolController.text = value;
                          // Set unit from asset
                          final asset = _availableAssets.firstWhere(
                            (a) => a.symbol == value,
                            orElse: () => _availableAssets.first,
                          );
                          _unitController.text = asset.unit;
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            onFieldSubmitted: (_) => onFieldSubmitted(),
                            decoration: const InputDecoration(
                              hintText: 'Enter symbol (e.g., ALTIN, THYAO)',
                            ),
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a symbol';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quantity
              FadeInWidget(
                delay: const Duration(milliseconds: 100),
                child: SimpleCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.numbers_rounded, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Quantity',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          final quantity = double.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Please enter a valid quantity';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Unit
              FadeInWidget(
                delay: const Duration(milliseconds: 150),
                child: SimpleCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.straighten_rounded, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Unit',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          hintText: 'gram, share, unit, etc.',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a unit';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Buy Price (optional)
              FadeInWidget(
                delay: const Duration(milliseconds: 200),
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
                            'Buy Price (optional)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _buyPriceController,
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          prefixText: '₺ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Buy Date (optional)
              FadeInWidget(
                delay: const Duration(milliseconds: 250),
                child: SimpleCard(
                  padding: EdgeInsets.zero,
                  onTap: _selectBuyDate,
                  child: ListTile(
                    leading: Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor),
                    title: const Text('Buy Date (optional)'),
                    subtitle: Text(
                      _buyDate != null
                          ? DateFormat('EEEE, MMMM dd, yyyy').format(_buyDate!)
                          : 'Select buy date',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Note (optional)
              FadeInWidget(
                delay: const Duration(milliseconds: 300),
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
                          hintText: 'Add a note about this holding',
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
                delay: const Duration(milliseconds: 350),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveHolding,
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
                                widget.holdingId != null ? 'Update Holding' : 'Add Holding',
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
}
