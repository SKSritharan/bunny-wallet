import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 1,
  );

  static String format(double amount) => _formatter.format(amount);

  static String formatCompact(double amount) =>
      _compactFormatter.format(amount);

  static String formatSigned(double amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${_formatter.format(amount)}';
  }
}
