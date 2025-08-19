import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const int _version = 2; // Incremented version number

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('crypto.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE cryptos (
      id TEXT PRIMARY KEY,
      name TEXT,
      symbol TEXT,
      priceUsd REAL,
      changePercent24Hr REAL,
      marketCapUsd REAL,
      volumeUsd24Hr REAL,
      supply REAL
    )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns if they don't exist
      await db.execute('ALTER TABLE cryptos ADD COLUMN symbol TEXT');
      await db.execute('ALTER TABLE cryptos ADD COLUMN changePercent24Hr REAL');
      await db.execute('ALTER TABLE cryptos ADD COLUMN marketCapUsd REAL');
      await db.execute('ALTER TABLE cryptos ADD COLUMN volumeUsd24Hr REAL');
      await db.execute('ALTER TABLE cryptos ADD COLUMN supply REAL');
    }
  }
  
  // Clear the database (for testing)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('cryptos');
  }

  Future<void> insertCrypto(Crypto crypto) async {
    final db = await instance.database;
    await db.insert(
      'cryptos',
      crypto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Crypto>> getCryptos() async {
    final db = await instance.database;
    final result = await db.query('cryptos');
    return result.map((e) => Crypto.fromMap(e)).toList();
  }

  Future<void> clearTable() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('cryptos');
    });
  }
  
  // This will completely drop and recreate the table
  Future<void> resetDatabase() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.execute('DROP TABLE IF EXISTS cryptos');
    });
    
    // Recreate the table using the database, not the transaction
    await _createDB(db, _version);
  }
}
