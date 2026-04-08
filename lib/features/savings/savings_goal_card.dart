import 'package:flutter/material.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/utils/currency_formatter.dart';
import 'package:bunny_wallet/core/utils/date_helpers.dart';
import 'package:bunny_wallet/data/models/savings_goal_model.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final VoidCallback onDeposit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    required this.onDeposit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (goal.progress * 100).toInt();

    return Card(
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Progress circle
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: goal.progress,
                          strokeWidth: 5,
                          backgroundColor: goal.colorValue
                              .withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation(
                              goal.colorValue),
                          strokeCap: StrokeCap.round,
                        ),
                        Text(
                          '$percentage%',
                          style: context.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: goal.colorValue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(goal.icon,
                                size: 16, color: goal.colorValue),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                goal.name,
                                style: context.textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (goal.isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Done',
                                  style: context.textTheme.labelSmall
                                      ?.copyWith(color: Colors.green),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${CurrencyFormatter.format(goal.savedAmount)} / ${CurrencyFormatter.format(goal.targetAmount)}',
                          style: context.textTheme.bodySmall,
                        ),
                        if (goal.deadline != null)
                          Text(
                            'Due ${DateHelpers.formatShortDate(goal.deadline!)}',
                            style: context.textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Linear progress
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 6,
                  backgroundColor:
                      goal.colorValue.withValues(alpha: 0.12),
                  valueColor:
                      AlwaysStoppedAnimation(goal.colorValue),
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDeposit,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Deposit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: context.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
