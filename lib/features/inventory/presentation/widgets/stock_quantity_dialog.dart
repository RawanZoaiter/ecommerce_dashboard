import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/stock_item.dart';

/// Asks for a product's new quantity on hand.
///
/// Returns the number, or null when dismissed.
class StockQuantityDialog extends StatefulWidget {
  const StockQuantityDialog({required this.item, super.key});

  final StockItem item;

  static Future<int?> show(BuildContext context, {required StockItem item}) {
    return showDialog<int>(
      context: context,
      builder: (context) => StockQuantityDialog(item: item),
    );
  }

  @override
  State<StockQuantityDialog> createState() => _StockQuantityDialogState();
}

class _StockQuantityDialogState extends State<StockQuantityDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.item.quantityOnHand?.toString() ?? '',
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(int.parse(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.inventoryUpdateStock),
      content: SizedBox(
        width: 340,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.item.productName, style: context.text.titleSmall),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.inventoryStockQuantity,
                  prefixIcon: const Icon(Icons.numbers, size: 20),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  final parsed = int.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed < 0) {
                    return l10n.productFormErrorPriceFormat;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionSave)),
      ],
    );
  }
}
