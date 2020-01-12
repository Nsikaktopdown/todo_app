import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/model/todo.dart';


class DBHelper{

  static final DBHelper _dbHelper = DBHelper._internal();
  String tableName = "todo";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  DBHelper._internal();

  // create Database singleton
  factory DBHelper() => _dbHelper;

  static Database _db;

  Future<Database> get db async{
    if(_db == null){
      _db = await initializeDb();
    }
    return _db;
  }

  // initialize Database
  Future<Database> initializeDb() async{
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "todo.db";
    var dbTodos = await openDatabase(path, version: 1, onCreate: _createDb);
    return dbTodos;

  }

  /// Create new datablae
  void _createDb(Database db, int newVersion) async {
    await db.execute(
      "CREATE TABLE $tableName($colId INTEGER PRIMARY KEY, $colTitle TEXT, " + "$colDescription TEXT, $colPriority INTERGER, $colDate TEXT )");
  }

  //insert query method

  Future<int> insertTodo(Todo todo) async{
    Database db = await this.db;
    var result = await db.insert(tableName, todo.toMap());
    return result;
  }

  //get list of todos
  Future<List> getTodos() async{
    Database db = await this.db;
    var result = await db.rawQuery("SELECT * FROM $tableName order by $colPriority ASC");
    return result;
  }

  //return table count
  Future<int> getCount() async{
    Database db = await this.db;
    var result = Sqflite.firstIntValue(
      await db.rawQuery("select count (*) from $tableName")
    );
    return result;
  }

  //update record
 Future<int> updateTodo(Todo todo) async{
    var db = await this.db;
    var result = await db.update(tableName, todo.toMap(),
    where: "$colId = ?", whereArgs: [todo.id]);
    return result;
 }

 //deletc
 Future<int> deleteTodo(int id) async{
   var db = await this.db;
   var result = await db.rawDelete('DELETE FROM $tableName WHERE $colId = $id');
   return result;
 }

}