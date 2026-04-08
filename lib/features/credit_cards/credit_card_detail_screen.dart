import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/theme/app_colors.dart';
import 'package:bunny_wallet/core/utils/currency_formatter.dart';
import 'package:bunny_wallet/data/models/credit_card_model.dart';
import 'package:bunny_wallet/data/models/transaction_model.dart';
import 'package:bunny_wallet/data/providers/providers.dart';
import 'package:bunny_wallet/widgets/transaction_tile.dart';
import 'package:bunny_wallet/widgets/empty_state.dart';
import 'package:bunny_wallet/features/credit_cards/add_card_sheet.dart';
import 'package:bunny_wallet/features/credit_cards/reminder_sheet.dart';

final _cardProvider =
    FutureProvider.family<CreditCardModel?, String>((ref, id) {
  ref.watch(creditCardRefreshProvider);
  return ref.read(creditCardRepoProvider).getById(id);
});

final _cardTransactionsProvider =
    FutureProvider.family<List<TransactionModel>, String>((ref, id) {
  ref.watch(transactionRefreshProvider);
  return ref.read(transactionRepoProvider).getByCreditCard(id);
});

class CreditCardDetailScreen extends ConsumerWidget {
  final String cardId;

  const CreditCardDetailScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(_cardProvider(cardId));
    final txnAsync = ref.watch(_cardTransactionsProvider(cardId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        actions: [
          cardAsync.whenOrNull(
                data: (card) {
                  if (card == null) return const SizedBox();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () => _showReminderSheet(context, card),
                        tooltip: 'Payment Reminders',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showEditCard(context, card),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteCard(context, ref, card),
                      ),
                    ],
                  );
                },
              ) ??
              const SizedBox(),
        ],
      ),
      body: cardAsync.when(
        data: (card) {
          if (card == null) {
            return const Center(child: Text('Card not found'));
          }
          return _buildContent(context, card, txnAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CreditCardModel card,
    AsyncValue<List<TransactionModel>> txnAsync,
  ) {
    final gradient =
        card.gradientIndex < AppColors.creditCardGradients.length
            ? AppColors.creditCardGradients[card.gradientIndex]
            : AppColors.creditCardGradients[0];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card visual
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Icon(Icons.contactless_rounded,
                      color: Colors.white70, size: 28),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '**** **** **** ${card.lastFourDigits}',
                style: context.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CardStat(
                      label: 'Balance',
                      value: CurrencyFormatter.format(card.currentBalance)),
                  _CardStat(
                      label: 'Available',
                      value: CurrencyFormatter.format(card.availableCredit)),
                  _CardStat(
                      label: 'Due Day', value: '${card.dueDay}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Utilization bar
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Credit Utilization',
                        style: context.textTheme.titleSmall),
                    Text(
                      '${(card.utilizationRate * 100).toStringAsFixed(1)}%',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: card.utilizationRate > 0.8
                            ? AppColors.expense
                            : card.utilizationRate > 0.5
                                ? Colors.orange
                                : AppColors.income,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: card.utilizationRate,
                    minHeight: 8,
                    backgroundColor: context
                        .colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      card.utilizationRate > 0.8
                          ? AppColors.expense
                          : card.utilizationRate > 0.5
                              ? Colors.orange
                              : AppColors.income,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CurrencyFormatter.format(card.currentBalance)} used',
                      style: context.textTheme.bodySmall,
                    ),
                    Text(
                      '${CurrencyFormatter.format(card.creditLimit)} limit',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Payment info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _InfoTile(
                  icon: Icons.calendar_month_rounded,
                  label: 'Billing Day',
                  value: '${card.billingDay}',
                ),
                const SizedBox(width: 16),
                _InfoTile(
                  icon: Icons.event_rounded,
                  label: 'Due Day',
                  value: '${card.dueDay}',
                ),
                const SizedBox(width: 16),
                _InfoTile(
                  icon: Icons.credit_score_rounded,
                  label: 'Status',
                  value: card.isActive ? 'Active' : 'Inactive',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Card transactions
        Text('Transactions', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        txnAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No transactions',
                  subtitle: 'No transactions linked to this card yet',
                ),
              );
            }
            return Column(
              children: transactions
                  .map((t) => TransactionTile(transaction: t))
                  .toList(),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _showEditCard(BuildContext context, CreditCardModel card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddCardSheet(existing: card),
    );
  }

  void _showReminderSheet(BuildContext context, CreditCardModel card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ReminderSheet(card: card),
    );
  }

  Future<void> _deleteCard(
      BuildContext context, WidgetRef ref, CreditCardModel card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Delete "${card.name}"? This cannot be undone.'),
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
      await ref.read(creditCardRepoProvider).delete(card.id);
      refreshCreditCards(ref);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _CardStat extends StatelessWidget {
  final String label;
  final String value;

  const _CardStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon,
              size: 22, color: context.colorScheme.primary),
          const SizedBox(height: 4),
          Text(label, style: context.textTheme.labelSmall),
          Text(value,
              style: context.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
