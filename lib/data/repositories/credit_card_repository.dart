import 'package:bunny_wallet/data/database/database_helper.dart';
import 'package:bunny_wallet/data/models/credit_card_model.dart';
import 'package:bunny_wallet/data/models/payment_reminder_model.dart';

class CreditCardRepository {
  final DatabaseHelper _dbHelper;

  CreditCardRepository([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<CreditCardModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('credit_cards', orderBy: 'created_at DESC');
    return maps.map(CreditCardModel.fromMap).toList();
  }

  Future<List<CreditCardModel>> getActive() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'credit_cards',
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );
    return maps.map(CreditCardModel.fromMap).toList();
  }

  Future<CreditCardModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'credit_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CreditCardModel.fromMap(maps.first);
  }

  Future<void> insert(CreditCardModel card) async {
    final db = await _dbHelper.database;
    await db.insert('credit_cards', card.toMap());
  }

  Future<void> update(CreditCardModel card) async {
    final db = await _dbHelper.database;
    await db.update(
      'credit_cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> updateBalance(String id, double balance) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE credit_cards SET current_balance = ? WHERE id = ?',
      [balance, id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('credit_cards', where: 'id = ?', whereArgs: [id]);
  }

  // Payment Reminders
  Future<List<PaymentReminderModel>> getReminders(String cardId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'payment_reminders',
      where: 'credit_card_id = ?',
      whereArgs: [cardId],
    );
    return maps.map(PaymentReminderModel.fromMap).toList();
  }

  Future<List<PaymentReminderModel>> getAllActiveReminders() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'payment_reminders',
      where: 'is_enabled = 1',
    );
    return maps.map(PaymentReminderModel.fromMap).toList();
  }

  Future<void> insertReminder(PaymentReminderModel reminder) async {
    final db = await _dbHelper.database;
    await db.insert('payment_reminders', reminder.toMap());
  }

  Future<void> updateReminder(PaymentReminderModel reminder) async {
    final db = await _dbHelper.database;
    await db.update(
      'payment_reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteReminder(String id) async {
    final db = await _dbHelper.database;
    await db.delete('payment_reminders', where: 'id = ?', whereArgs: [id]);
  }
}
