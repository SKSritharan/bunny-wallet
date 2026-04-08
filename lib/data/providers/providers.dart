import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bunny_wallet/data/repositories/transaction_repository.dart';
import 'package:bunny_wallet/data/repositories/category_repository.dart';
import 'package:bunny_wallet/data/repositories/savings_repository.dart';
import 'package:bunny_wallet/data/repositories/credit_card_repository.dart';
import 'package:bunny_wallet/data/models/transaction_model.dart';
import 'package:bunny_wallet/data/models/category_model.dart';
import 'package:bunny_wallet/data/models/savings_goal_model.dart';
import 'package:bunny_wallet/data/models/credit_card_model.dart';
import 'package:bunny_wallet/core/utils/date_helpers.dart';

// Repositories
final transactionRepoProvider = Provider((ref) => TransactionRepository());
final categoryRepoProvider = Provider((ref) => CategoryRepository());
final savingsRepoProvider = Provider((ref) => SavingsRepository());
final creditCardRepoProvider = Provider((ref) => CreditCardRepository());

// Refresh triggers
final transactionRefreshProvider = StateProvider<int>((ref) => 0);
final savingsRefreshProvider = StateProvider<int>((ref) => 0);
final creditCardRefreshProvider = StateProvider<int>((ref) => 0);
final categoryRefreshProvider = StateProvider<int>((ref) => 0);

// Transactions
final allTransactionsProvider = FutureProvider<List<TransactionModel>>((ref) {
  ref.watch(transactionRefreshProvider);
  return ref.read(transactionRepoProvider).getAll();
});

final monthlyTransactionsProvider =
    FutureProvider<List<TransactionModel>>((ref) {
  ref.watch(transactionRefreshProvider);
  final start = DateHelpers.startOfMonth();
  final end = DateHelpers.endOfMonth();
  return ref.read(transactionRepoProvider).getByDateRange(start, end);
});

final recentTransactionsProvider =
    FutureProvider<List<TransactionModel>>((ref) {
  ref.watch(transactionRefreshProvider);
  return ref.read(transactionRepoProvider).getRecent(limit: 5);
});

final monthlyIncomeProvider = FutureProvider<double>((ref) {
  ref.watch(transactionRefreshProvider);
  final start = DateHelpers.startOfMonth();
  final end = DateHelpers.endOfMonth();
  return ref
      .read(transactionRepoProvider)
      .getTotalByType(TransactionType.income, start: start, end: end);
});

final monthlyExpenseProvider = FutureProvider<double>((ref) {
  ref.watch(transactionRefreshProvider);
  final start = DateHelpers.startOfMonth();
  final end = DateHelpers.endOfMonth();
  return ref
      .read(transactionRepoProvider)
      .getTotalByType(TransactionType.expense, start: start, end: end);
});

// Categories
final allCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  ref.watch(categoryRefreshProvider);
  return ref.read(categoryRepoProvider).getAll();
});

final incomeCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  ref.watch(categoryRefreshProvider);
  return ref.read(categoryRepoProvider).getByType('income');
});

final expenseCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  ref.watch(categoryRefreshProvider);
  return ref.read(categoryRepoProvider).getByType('expense');
});

// Savings
final allSavingsProvider = FutureProvider<List<SavingsGoalModel>>((ref) {
  ref.watch(savingsRefreshProvider);
  return ref.read(savingsRepoProvider).getAll();
});

final totalSavedProvider = FutureProvider<double>((ref) {
  ref.watch(savingsRefreshProvider);
  return ref.read(savingsRepoProvider).getTotalSaved();
});

// Credit Cards
final allCreditCardsProvider = FutureProvider<List<CreditCardModel>>((ref) {
  ref.watch(creditCardRefreshProvider);
  return ref.read(creditCardRepoProvider).getAll();
});

final activeCreditCardsProvider = FutureProvider<List<CreditCardModel>>((ref) {
  ref.watch(creditCardRefreshProvider);
  return ref.read(creditCardRepoProvider).getActive();
});

// Helper to refresh data after mutations
void refreshTransactions(WidgetRef ref) {
  ref.read(transactionRefreshProvider.notifier).state++;
}

void refreshSavings(WidgetRef ref) {
  ref.read(savingsRefreshProvider.notifier).state++;
}

void refreshCreditCards(WidgetRef ref) {
  ref.read(creditCardRefreshProvider.notifier).state++;
}

void refreshCategories(WidgetRef ref) {
  ref.read(categoryRefreshProvider.notifier).state++;
}

void refreshAll(WidgetRef ref) {
  refreshTransactions(ref);
  refreshSavings(ref);
  refreshCreditCards(ref);
  refreshCategories(ref);
}
