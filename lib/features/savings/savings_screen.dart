import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/utils/currency_formatter.dart';
import 'package:bunny_wallet/data/models/savings_goal_model.dart';
import 'package:bunny_wallet/data/providers/providers.dart';
import 'package:bunny_wallet/widgets/empty_state.dart';
import 'package:bunny_wallet/features/savings/add_goal_sheet.dart';
import 'package:bunny_wallet/features/savings/savings_goal_card.dart';
import 'package:bunny_wallet/features/savings/deposit_sheet.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(allSavingsProvider);
    final totalAsync = ref.watch(totalSavedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: Icons.savings_outlined,
              title: 'No savings goals',
              subtitle: 'Start saving by creating your first goal',
              action: FilledButton.icon(
                onPressed: () => _showAddGoal(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Goal'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total saved header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.savings_rounded,
                      color: context.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Saved',
                          style: context.textTheme.bodySmall,
                        ),
                        Text(
                          CurrencyFormatter.format(
                              totalAsync.valueOrNull ?? 0),
                          style:
                              context.textTheme.headlineMedium?.copyWith(
                            color: context.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Goal cards
              ...goals.map(
                (goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SavingsGoalCard(
                    goal: goal,
                    onDeposit: () => _showDeposit(context, ref, goal),
                    onEdit: () => _showEditGoal(context, goal),
                    onDelete: () => _deleteGoal(context, ref, goal),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'savings_fab',
        onPressed: () => _showAddGoal(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddGoal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddGoalSheet(),
    );
  }

  void _showEditGoal(BuildContext context, SavingsGoalModel goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddGoalSheet(existing: goal),
    );
  }

  void _showDeposit(
      BuildContext context, WidgetRef ref, SavingsGoalModel goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DepositSheet(goal: goal),
    );
  }

  Future<void> _deleteGoal(
      BuildContext context, WidgetRef ref, SavingsGoalModel goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Delete "${goal.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(savingsRepoProvider).delete(goal.id);
      refreshSavings(ref);
    }
  }
}
