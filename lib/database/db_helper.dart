import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/receipt_transaction.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('receipt_expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            merchant TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            category TEXT NOT NULL,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  Future<int> insert(ReceiptTransaction tx) async {
    final db = await instance.database;
    return await db.insert('transactions', tx.toMap());
  }

  Future<List<ReceiptTransaction>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => ReceiptTransaction.fromMap(json)).toList();
  }
}