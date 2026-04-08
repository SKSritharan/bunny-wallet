import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/utils/date_helpers.dart';
import 'package:bunny_wallet/data/models/transaction_model.dart';
import 'package:bunny_wallet/data/providers/providers.dart';
import 'package:bunny_wallet/widgets/transaction_tile.dart';
import 'package:bunny_wallet/widgets/empty_state.dart';
import 'package:bunny_wallet/features/transactions/add_transaction_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionType? _filter;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Income',
                  isSelected: _filter == TransactionType.income,
                  onTap: () =>
                      setState(() => _filter = TransactionType.income),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Expense',
                  isSelected: _filter == TransactionType.expense,
                  onTap: () =>
                      setState(() => _filter = TransactionType.expense),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Transaction list
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                var filtered = transactions;
                if (_filter != null) {
                  filtered = transactions
                      .where((t) => t.type == _filter)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    subtitle: 'Tap the + button to add your first transaction',
                    action: FilledButton.icon(
                      onPressed: _showAddSheet,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Transaction'),
                    ),
                  );
                }

                final grouped = _groupByDate(filtered);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                          child: Text(
                            DateHelpers.relativeDate(entry.value.first.date),
                            style: context.textTheme.labelMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (txn) => TransactionTile(
                            transaction: txn,
                            onTap: () => _showEditSheet(txn),
                            onDismissed: () => _delete(txn),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'txn_fab',
        onPressed: _showAddSheet,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Map<String, List<TransactionModel>> _groupByDate(
      List<TransactionModel> transactions) {
    final map = <String, List<TransactionModel>>{};
    for (final txn in transactions) {
      final key = '${txn.date.year}-${txn.date.month}-${txn.date.day}';
      map.putIfAbsent(key, () => []).add(txn);
    }
    return map;
  }

  Future<void> _showAddSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  Future<void> _showEditSheet(TransactionModel txn) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddTransactionSheet(existing: txn),
    );
  }

  Future<void> _delete(TransactionModel txn) async {
    await ref.read(transactionRepoProvider).delete(txn.id);
    refreshTransactions(ref);
    if (mounted) context.showSnack('Transaction deleted');
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.primary.withValues(alpha: 0.12)
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: context.colorScheme.primary, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
