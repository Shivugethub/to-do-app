import 'package:flutter/material.dart';
import '../Note.dart';
import '../database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.appBarTitle, this.note);
  @override
  State<StatefulWidget> createState() {
    return _NoteDetailState(this.note, this.appBarTitle);
  }
}

class _NoteDetailState extends State<NoteDetail> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static var _priorities = ["High", "Low"];
  String appBarTitle;
  Note note;
  DatabaseHelper databaseHelper = DatabaseHelper();
  _NoteDetailState(this.note, this.appBarTitle);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope(
      onWillPop: () {
        this.moveToLastScreen();
      },
      child: Scaffold(
        key: this._scaffoldKey,
        backgroundColor: Colors.cyanAccent,
        appBar: AppBar(
          title: Text(
            this.appBarTitle,
            style: TextStyle(fontSize: 20.0),
          ),
          backgroundColor: Colors.pink,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              this.moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                  //dropdown menu
                  child: new ListTile(
                    leading: const Icon(Icons.low_priority),
                    title: DropdownButton(
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          );
                        }).toList(),
                        value: getPriorityAsString(note.priority),
                        onChanged: (valueSelectedByUser) {
                          setState(() {
                            updatePriorityAsInt(valueSelectedByUser);
                          });
                        }),
                  ),
                ),
                // Second Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      icon: Icon(Icons.title),
                    ),
                  ),
                ),

                // Third Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: InputDecoration(
                      labelText: 'Details',
                      icon: Icon(Icons.details),
                    ),
                  ),
                ),

                // Fourth Element
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.green,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              this._save(context);
                              // this._displaySnackBar(context);
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.red,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(
      elevation: 10.0,
      content: Text(
        'Fill All Fields',
        style: TextStyle(fontSize: 16.0),
      ),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          // side: BorderSide(
          //     color: Colors.white, width: 10.0),
          borderRadius: BorderRadius.circular(10.0)),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar); // edited line
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _save(context) async {
    if (this.titleController.text.isEmpty &&
        this.descriptionController.text.isEmpty) {
      this._displaySnackBar(context);
    } else {
      this.moveToLastScreen();
      note.date = DateFormat.yMMMd().format(DateTime.now());
      int result;
      if (note.id != null) {
        result = await databaseHelper.updatedNote(note);
      } else {
        result = await databaseHelper.insertNote(note);
      }

      if (result != 0) {
        this._showAlerDialog("Status", "Note saved successfully");
      } else {
        this._showAlerDialog("Problem", "Problem saving Note");
      }
    }
  }

  void _delete() async {
    this.moveToLastScreen();
    if (note.id == null) {
      this._showAlerDialog("Status", "First add a note");
      return;
    }

    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      this._showAlerDialog("Status", "Note deleted successfully");
    } else {
      this._showAlerDialog("Status", "Error");
    }
  }

  // convert to int to save into database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case "High":
        note.priority = 1;
        break;
      case "Low":
        note.priority = 2;
        break;
    }
  }

  // convert int to string to show user
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void moveToLastScreen() => Navigator.pop(context, true);

  void _showAlerDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(
        title,
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      content: Text(
        message,
        // style: TextStyle(fontSize: 16.0),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
