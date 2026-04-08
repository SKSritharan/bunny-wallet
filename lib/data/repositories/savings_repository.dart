import 'package:bunny_wallet/data/database/database_helper.dart';
import 'package:bunny_wallet/data/models/savings_goal_model.dart';

class SavingsRepository {
  final DatabaseHelper _dbHelper;

  SavingsRepository([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<SavingsGoalModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('savings_goals', orderBy: 'created_at DESC');
    return maps.map(SavingsGoalModel.fromMap).toList();
  }

  Future<SavingsGoalModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return SavingsGoalModel.fromMap(maps.first);
  }

  Future<void> insert(SavingsGoalModel goal) async {
    final db = await _dbHelper.database;
    await db.insert('savings_goals', goal.toMap());
  }

  Future<void> update(SavingsGoalModel goal) async {
    final db = await _dbHelper.database;
    await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> updateSavedAmount(String id, double amount) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE savings_goals SET saved_amount = ? WHERE id = ?',
      [amount, id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalSaved() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(saved_amount), 0) as total FROM savings_goals',
    );
    return (result.first['total'] as num).toDouble();
  }
}
