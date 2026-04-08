import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/theme/app_colors.dart';
import 'package:bunny_wallet/data/models/credit_card_model.dart';
import 'package:bunny_wallet/data/providers/providers.dart';

class AddCardSheet extends ConsumerStatefulWidget {
  final CreditCardModel? existing;

  const AddCardSheet({super.key, this.existing});

  @override
  ConsumerState<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends ConsumerState<AddCardSheet> {
  final _nameController = TextEditingController();
  final _lastFourController = TextEditingController();
  final _limitController = TextEditingController();
  final _balanceController = TextEditingController();
  int _billingDay = 1;
  int _dueDay = 15;
  int _gradientIndex = 0;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.existing!;
      _nameController.text = c.name;
      _lastFourController.text = c.lastFourDigits;
      _limitController.text = c.creditLimit.toStringAsFixed(2);
      _balanceController.text = c.currentBalance.toStringAsFixed(2);
      _billingDay = c.billingDay;
      _dueDay = c.dueDay;
      _gradientIndex = c.gradientIndex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastFourController.dispose();
    _limitController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEditing ? 'Edit Card' : 'Add Credit Card',
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Card name (e.g. Chase Sapphire)',
                prefixIcon: Icon(Icons.credit_card_rounded),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _lastFourController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'Last 4 digits',
                prefixIcon: Icon(Icons.pin_rounded),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _limitController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Credit limit',
                      prefixText: '\$ ',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _balanceController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Current balance',
                      prefixText: '\$ ',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Billing & due day
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Billing Day',
                          style: context.textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color:
                              context.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<int>(
                          value: _billingDay,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: List.generate(
                            28,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text('${i + 1}'),
                            ),
                          ),
                          onChanged: (v) =>
                              setState(() => _billingDay = v!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Day',
                          style: context.textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color:
                              context.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<int>(
                          value: _dueDay,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: List.generate(
                            28,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text('${i + 1}'),
                            ),
                          ),
                          onChanged: (v) =>
                              setState(() => _dueDay = v!),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card color
            Text('Card Style', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                AppColors.creditCardGradients.length,
                (i) {
                  final isSelected = i == _gradientIndex;
                  final colors = AppColors.creditCardGradients[i];
                  return GestureDetector(
                    onTap: () => setState(() => _gradientIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: colors),
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                                color: context.colorScheme.onSurface,
                                width: 2)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _isEditing ? 'Update Card' : 'Add Card',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      context.showSnack('Please enter a card name');
      return;
    }
    if (_lastFourController.text.length != 4) {
      context.showSnack('Please enter 4 digits');
      return;
    }
    final limit = double.tryParse(_limitController.text.trim());
    if (limit == null || limit <= 0) {
      context.showSnack('Please enter a valid credit limit');
      return;
    }

    setState(() => _saving = true);

    final balance =
        double.tryParse(_balanceController.text.trim()) ?? 0;

    final card = CreditCardModel(
      id: _isEditing ? widget.existing!.id : const Uuid().v4(),
      name: _nameController.text.trim(),
      lastFourDigits: _lastFourController.text,
      creditLimit: limit,
      currentBalance: balance,
      billingDay: _billingDay,
      dueDay: _dueDay,
      gradientIndex: _gradientIndex,
      createdAt:
          _isEditing ? widget.existing!.createdAt : DateTime.now(),
    );

    final repo = ref.read(creditCardRepoProvider);
    if (_isEditing) {
      await repo.update(card);
    } else {
      await repo.insert(card);
    }

    refreshCreditCards(ref);
    if (mounted) Navigator.of(context).pop();
  }
}
