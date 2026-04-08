import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/data/models/savings_goal_model.dart';
import 'package:bunny_wallet/data/providers/providers.dart';

class AddGoalSheet extends ConsumerStatefulWidget {
  final SavingsGoalModel? existing;

  const AddGoalSheet({super.key, this.existing});

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _deadline;
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  static const _icons = [
    Icons.flight_takeoff_rounded,
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.school_rounded,
    Icons.phone_iphone_rounded,
    Icons.diamond_rounded,
    Icons.celebration_rounded,
    Icons.medical_services_rounded,
    Icons.beach_access_rounded,
    Icons.shopping_bag_rounded,
  ];

  static const _colors = [
    0xFF42A5F5,
    0xFF66BB6A,
    0xFFFF7043,
    0xFFAB47BC,
    0xFFEF5350,
    0xFF26A69A,
    0xFFEC407A,
    0xFF5C6BC0,
    0xFFFFA726,
    0xFF78909C,
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existing!.name;
      _amountController.text =
          widget.existing!.targetAmount.toStringAsFixed(2);
      _deadline = widget.existing!.deadline;
      _selectedColorIndex = _colors.indexOf(widget.existing!.color);
      if (_selectedColorIndex < 0) _selectedColorIndex = 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
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
              _isEditing ? 'Edit Goal' : 'New Savings Goal',
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Goal name',
                prefixIcon: Icon(Icons.flag_rounded),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                hintText: 'Target amount',
                prefixText: '\$ ',
                prefixIcon: Icon(Icons.attach_money_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // Deadline picker
            InkWell(
              onTap: _pickDeadline,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 20,
                        color: context.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(
                      _deadline != null
                          ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                          : 'Set deadline (optional)',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: _deadline == null
                            ? context.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon picker
            Text('Icon', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_icons.length, (i) {
                final isSelected = i == _selectedIconIndex;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedIconIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(_colors[_selectedColorIndex])
                              .withValues(alpha: 0.15)
                          : context
                              .colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: Color(
                                  _colors[_selectedColorIndex]),
                              width: 1.5)
                          : null,
                    ),
                    child: Icon(
                      _icons[i],
                      size: 22,
                      color: isSelected
                          ? Color(_colors[_selectedColorIndex])
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Color picker
            Text('Color', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_colors.length, (i) {
                final isSelected = i == _selectedColorIndex;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedColorIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(_colors[i]),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(_colors[i])
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }),
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
                      _isEditing ? 'Update Goal' : 'Create Goal',
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

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) setState(() => _deadline = date);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      context.showSnack('Please enter a name');
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      context.showSnack('Please enter a valid target amount');
      return;
    }

    setState(() => _saving = true);

    final goal = SavingsGoalModel(
      id: _isEditing ? widget.existing!.id : const Uuid().v4(),
      name: _nameController.text.trim(),
      targetAmount: amount,
      savedAmount: _isEditing ? widget.existing!.savedAmount : 0,
      deadline: _deadline,
      iconCodePoint: _icons[_selectedIconIndex].codePoint,
      color: _colors[_selectedColorIndex],
      createdAt:
          _isEditing ? widget.existing!.createdAt : DateTime.now(),
    );

    final repo = ref.read(savingsRepoProvider);
    if (_isEditing) {
      await repo.update(goal);
    } else {
      await repo.insert(goal);
    }

    refreshSavings(ref);
    if (mounted) Navigator.of(context).pop();
  }
}
