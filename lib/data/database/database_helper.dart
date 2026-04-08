import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bunny_wallet/core/constants/app_constants.dart';
import 'package:bunny_wallet/data/models/category_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_code_point INTEGER NOT NULL,
        color INTEGER NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        credit_card_id TEXT,
        note TEXT DEFAULT '',
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (credit_card_id) REFERENCES credit_cards(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        saved_amount REAL DEFAULT 0,
        deadline INTEGER,
        icon_code_point INTEGER NOT NULL,
        color INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE credit_cards (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        last_four_digits TEXT NOT NULL,
        credit_limit REAL NOT NULL,
        current_balance REAL DEFAULT 0,
        billing_day INTEGER NOT NULL,
        due_day INTEGER NOT NULL,
        gradient_index INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_reminders (
        id TEXT PRIMARY KEY,
        credit_card_id TEXT NOT NULL,
        days_before INTEGER NOT NULL,
        is_enabled INTEGER DEFAULT 1,
        FOREIGN KEY (credit_card_id) REFERENCES credit_cards(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions(date DESC)');
    await db.execute(
        'CREATE INDEX idx_transactions_type ON transactions(type)');
    await db.execute(
        'CREATE INDEX idx_transactions_category ON transactions(category_id)');

    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    final batch = db.batch();
    for (final cat in CategoryModel.defaultCategories) {
      batch.insert('categories', cat.toMap());
    }
    await batch.commit(noResult: true);
  }
}
