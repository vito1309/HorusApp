import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/denuncia.dart';

class DenunciaDao {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'denuncias.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE denuncias(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            localizacao TEXT NOT NULL,
            foto TEXT,
            usuario_id INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE denuncias ADD COLUMN usuario_id INTEGER NOT NULL DEFAULT 0');
        }
      },
    );
  }

  static Future<int> inserir(Denuncia d) async {
    final db = await database;
    return db.insert('denuncias', d.toMap());
  }

  static Future<List<Denuncia>> listar() async {
    final db = await database;
    final maps = await db.query('denuncias');
    return maps.map((m) => Denuncia.fromMap(m)).toList();
  }

  static Future<int> atualizar(Denuncia d) async {
    final db = await database;
    return db.update('denuncias', d.toMap(), where: 'id = ?', whereArgs: [d.id]);
  }

  static Future<int> deletar(int id) async {
    final db = await database;
    return db.delete('denuncias', where: 'id = ?', whereArgs: [id]);
  }
}