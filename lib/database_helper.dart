import 'Note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton
  static Database _database; //Singleton

  String noteTable = "note_table";
  String colID = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  // create Database instance if not exist
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  // custom getter
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // TODO: database creation directory
    Directory directory = await getApplicationDocumentsDirectory();
    // TODO: name of the database file
    String path = directory.path + "notes.db";
    // TODO: open database
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: this._createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable ($colID INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    // var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC'); //optional one
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result =
        await db.insert(noteTable, note.toMap()); // toMap from Note class
    return result;
  }

  Future<int> updatedNote(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colID = ?', whereArgs: [note.id]); // toMap from Note class
    return result;
  }

  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    // var result =
    //     await db.rawDelete('DELETE FROM $noteTable where $colID = $id');
    var result = await db.delete(noteTable,
        where: '$colID =?', whereArgs: [id]); // toMap from Note class
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();

    int count = noteMapList.length;
    List<Note> noteList = List<Note>();
    for (var i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
