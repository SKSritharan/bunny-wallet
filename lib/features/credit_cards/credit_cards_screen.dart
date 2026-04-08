import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/theme/app_colors.dart';
import 'package:bunny_wallet/core/utils/currency_formatter.dart';
import 'package:bunny_wallet/data/models/credit_card_model.dart';
import 'package:bunny_wallet/data/providers/providers.dart';
import 'package:bunny_wallet/widgets/empty_state.dart';
import 'package:bunny_wallet/features/credit_cards/add_card_sheet.dart';

class CreditCardsScreen extends ConsumerWidget {
  const CreditCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(allCreditCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return EmptyState(
              icon: Icons.credit_card_outlined,
              title: 'No credit cards',
              subtitle: 'Add your credit cards to track spending and payments',
              action: FilledButton.icon(
                onPressed: () => _showAddCard(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Card'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Card carousel
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.9),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _CreditCardWidget(
                        card: cards[index],
                        onTap: () =>
                            context.push('/cards/${cards[index].id}'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Cards list view
              Text('All Cards', style: context.textTheme.titleMedium),
              const SizedBox(height: 12),
              ...cards.map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CardListTile(
                    card: card,
                    onTap: () => context.push('/cards/${card.id}'),
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
        heroTag: 'cards_fab',
        onPressed: () => _showAddCard(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddCardSheet(),
    );
  }
}

class _CreditCardWidget extends StatelessWidget {
  final CreditCardModel card;
  final VoidCallback onTap;

  const _CreditCardWidget({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gradient = card.gradientIndex < AppColors.creditCardGradients.length
        ? AppColors.creditCardGradients[card.gradientIndex]
        : AppColors.creditCardGradients[0];

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.name,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.contactless_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 28,
                ),
              ],
            ),
            Text(
              '**** **** **** ${card.lastFourDigits}',
              style: context.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(card.currentBalance),
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Limit',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(card.creditLimit),
                      style: context.textTheme.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardListTile extends StatelessWidget {
  final CreditCardModel card;
  final VoidCallback onTap;

  const _CardListTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gradient = card.gradientIndex < AppColors.creditCardGradients.length
        ? AppColors.creditCardGradients[card.gradientIndex]
        : AppColors.creditCardGradients[0];

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
        ),
        title: Text(card.name, style: context.textTheme.titleSmall),
        subtitle: Text('**** ${card.lastFourDigits}',
            style: context.textTheme.bodySmall),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(card.currentBalance),
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(card.utilizationRate * 100).toInt()}% used',
              style: context.textTheme.labelSmall?.copyWith(
                color: card.utilizationRate > 0.8
                    ? AppColors.expense
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
