import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/theme/app_colors.dart';
import 'package:bunny_wallet/core/utils/currency_formatter.dart';
import 'package:bunny_wallet/core/utils/date_helpers.dart';
import 'package:bunny_wallet/data/providers/providers.dart';
import 'package:bunny_wallet/widgets/summary_card.dart';
import 'package:bunny_wallet/widgets/section_header.dart';
import 'package:bunny_wallet/widgets/transaction_tile.dart';
import 'package:bunny_wallet/widgets/empty_state.dart';
import 'package:bunny_wallet/features/dashboard/weekly_chart.dart';
import 'package:bunny_wallet/features/transactions/add_transaction_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(monthlyIncomeProvider);
    final expenseAsync = ref.watch(monthlyExpenseProvider);
    final recentAsync = ref.watch(recentTransactionsProvider);

    final income = incomeAsync.valueOrNull ?? 0;
    final expense = expenseAsync.valueOrNull ?? 0;
    final balance = income - expense;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🐰',
                    style: context.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Bunny Wallet'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Balance card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colorScheme.primary,
                        context.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(balance),
                        style: context.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateHelpers.formatMonthYear(DateTime.now()),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Income / Expense summary
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Income',
                        amount: income,
                        icon: Icons.arrow_upward_rounded,
                        color: AppColors.income,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: 'Expense',
                        amount: expense,
                        icon: Icons.arrow_downward_rounded,
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Weekly chart
                const WeeklyChart(),
                const SizedBox(height: 8),
              ]),
            ),
          ),

          // Recent transactions header
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Recent Transactions',
              actionText: 'See all',
              onAction: () => context.go('/transactions'),
            ),
          ),

          // Recent transactions
          recentAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    subtitle: 'Add your first transaction to get started',
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TransactionTile(
                    transaction: transactions[index],
                  ),
                  childCount: transactions.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dash_fab',
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddTransactionSheet(),
    );
  }
}
