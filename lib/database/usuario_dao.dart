import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/usuario.dart';

class UsuarioDao {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'usuarios.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            senha TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<bool> cadastrar(Usuario u) async {
    final db = await database;
    try {
      await db.insert('usuarios', u.toMap());
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<Usuario?> login(String email, String senha) async {
    final db = await database;
    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    if (resultado.isEmpty) return null;
    return Usuario.fromMap(resultado.first);
  }
}