import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'model.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper dbHelper = DBHelper._();

  final String dbName = 'demo.db';
  final String tableName = 'Student';
  final String colId = 'id';
  final String colName = 'name';
  final String colDob = 'dob';
  Database? db;

  Future<void> initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS $tableName ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT, $colDob TEXT);');
      print("--------------------------");
      print("table - done");
      print("---------------------------");
    });
  }

  Future<int> insertRecord({required String name, required String dob}) async {
    await initDb();
    String query = 'INSERT INTO $tableName($colName,$colDob) VALUES(?, ?);';
    //"INSERT INTO $tableName($colName,$colAge,$colCity,$colImage ) VALUES(?, ?, ?,?);";
    List args = [name, dob];
    print(args);
    int id = await db!.rawInsert(query, args);
    return id;
  }

  Future<List<Student>> fetch() async {
    await initDb();
    String query = 'SELECT * FROM $tableName';
    List<Map<String, dynamic>> students = await db!.rawQuery(query);
    List<Student> st = students.map((e) => Student.fromMap(e)).toList();
    return st;
  }

  Future<int> update(
      {required String name, required String dob, required int id}) async {
    await initDb();
    String query =
        'UPDATE $tableName SET $colName=? , $colDob=? WHERE $colId=?';
    List args = [name, dob, id];
    return db!.rawUpdate(query, args);
  }

  Future<int> delete({required int id}) async {
    await initDb();
    String query = 'DELETE FROM $tableName WHERE $colId=?';
    List args = [id];
    return db!.rawDelete(query, args);
  }
}
