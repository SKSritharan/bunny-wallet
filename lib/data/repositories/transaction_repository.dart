import 'package:bunny_wallet/data/database/database_helper.dart';
import 'package:bunny_wallet/data/models/transaction_model.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper;

  TransactionRepository([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<TransactionModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getByDateRange(
      DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getByType(TransactionType type) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'date DESC',
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getByCreditCard(String cardId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'credit_card_id = ?',
      whereArgs: [cardId],
      orderBy: 'date DESC',
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getRecent({int limit = 5}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<void> insert(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<void> update(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalByType(TransactionType type,
      {DateTime? start, DateTime? end}) async {
    final db = await _dbHelper.database;
    String where = 'type = ?';
    List<dynamic> args = [type.name];

    if (start != null && end != null) {
      where += ' AND date >= ? AND date <= ?';
      args.addAll([start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    }

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE $where',
      args,
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<Map<String, double>> getDailyTotals(
      DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );

    final dailyTotals = <String, double>{};
    for (final map in maps) {
      final txn = TransactionModel.fromMap(map);
      final dayKey =
          '${txn.date.year}-${txn.date.month}-${txn.date.day}';
      final sign = txn.type == TransactionType.expense ? -1 : 1;
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + (txn.amount * sign);
    }
    return dailyTotals;
  }
}
