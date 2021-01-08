import 'package:flutter/material.dart';
import 'dart:async';
import '../database_helper.dart';
import '../Note.dart';
import 'note_details.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (this.noteList == null) {
      this.noteList = List<Note>();
      this.updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("LCO ToDo"),
        backgroundColor: Colors.purple,
      ),
      body: this.getNoteListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
        onPressed: () {
          navigateToDetails(Note('', '', 2), 'Add Note');
        },
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: this.count,
      itemBuilder: (context, position) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: this.noteList[position].priority == 1
              ? Colors.red
              : Colors.deepPurple,
          elevation: 4.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage("https://ibb.co/Wcg4HgC"),
              backgroundColor: this.noteList[position].priority == 1
                  ? Colors.white
                  : Colors.black,
            ),
            title: Text(
              this.noteList[position].title,
              style: TextStyle(
                fontSize: 25.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              this.noteList[position].date,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            trailing: GestureDetector(
              child: Icon(
                Icons.open_in_new,
                color: Colors.white,
              ),
              onTap: () {
                this.navigateToDetails(this.noteList[position], "Edit Todo");
              },
            ),
          ),
        );
      },
    );
  }

  void navigateToDetails(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(title, note);
    }));

    if (result == true) {
      this.updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = this.noteList.length;
        });
      }).catchError((err) {
        print("Error: ${err}");
      });
    });
  }
}
