import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/utils/currency_formatter.dart';
import 'package:bunny_wallet/data/models/savings_goal_model.dart';
import 'package:bunny_wallet/data/providers/providers.dart';

class DepositSheet extends ConsumerStatefulWidget {
  final SavingsGoalModel goal;

  const DepositSheet({super.key, required this.goal});

  @override
  ConsumerState<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends ConsumerState<DepositSheet> {
  final _amountController = TextEditingController();
  bool _isWithdraw = false;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining =
        widget.goal.targetAmount - widget.goal.savedAmount;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
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
          Text(widget.goal.name, style: context.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Saved ${CurrencyFormatter.format(widget.goal.savedAmount)} of ${CurrencyFormatter.format(widget.goal.targetAmount)}',
            style: context.textTheme.bodySmall,
          ),
          if (remaining > 0)
            Text(
              '${CurrencyFormatter.format(remaining)} remaining',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          const SizedBox(height: 20),

          // Deposit/Withdraw toggle
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isWithdraw = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isWithdraw
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Deposit',
                          style: TextStyle(
                            color: !_isWithdraw
                                ? Colors.green
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isWithdraw = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isWithdraw
                            ? Colors.red.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Withdraw',
                          style: TextStyle(
                            color:
                                _isWithdraw ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: context.textTheme.displayMedium,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
              prefixStyle: context.textTheme.displayMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor:
                  _isWithdraw ? Colors.red : Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _isWithdraw ? 'Withdraw' : 'Deposit',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      context.showSnack('Enter a valid amount');
      return;
    }

    if (_isWithdraw && amount > widget.goal.savedAmount) {
      context.showSnack('Cannot withdraw more than saved amount');
      return;
    }

    setState(() => _saving = true);

    final newSaved = _isWithdraw
        ? widget.goal.savedAmount - amount
        : widget.goal.savedAmount + amount;

    await ref
        .read(savingsRepoProvider)
        .updateSavedAmount(widget.goal.id, newSaved);

    refreshSavings(ref);
    if (mounted) {
      context.showSnack(
        _isWithdraw
            ? 'Withdrew ${CurrencyFormatter.format(amount)}'
            : 'Deposited ${CurrencyFormatter.format(amount)}',
      );
      Navigator.of(context).pop();
    }
  }
}
