import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/theme/app_colors.dart';
import 'package:bunny_wallet/core/utils/currency_formatter.dart';
import 'package:bunny_wallet/core/utils/date_helpers.dart';
import 'package:bunny_wallet/data/models/transaction_model.dart';
import 'package:bunny_wallet/data/models/category_model.dart';
import 'package:bunny_wallet/data/providers/providers.dart';

class TransactionTile extends ConsumerWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.expense : AppColors.income;

    return categoriesAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (c) => c.id == transaction.categoryId,
          orElse: () => CategoryModel.defaultCategories.first,
        );

        final tile = ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.colorValue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category.icon,
              color: category.colorValue,
              size: 22,
            ),
          ),
          title: Text(
            category.name,
            style: context.textTheme.titleSmall,
          ),
          subtitle: transaction.note.isNotEmpty
              ? Text(
                  transaction.note,
                  style: context.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  DateHelpers.relativeDate(transaction.date),
                  style: context.textTheme.bodySmall,
                ),
          trailing: Text(
            '${isExpense ? '-' : '+'}${CurrencyFormatter.format(transaction.amount)}',
            style: context.textTheme.titleSmall?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

        if (onDismissed != null) {
          return Dismissible(
            key: Key(transaction.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onDismissed?.call(),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: AppColors.expense),
            ),
            child: tile,
          );
        }

        return tile;
      },
      loading: () => const SizedBox(height: 64),
      error: (_, __) => const SizedBox(height: 64),
    );
  }
}
