class Note {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  Note(this._title, this._date, this._priority, [this._description]);
  Note.withId(this._id, this._title, this._date, this._priority,
      [this._description]); // named constructor

// All the getters
  int get id => this._id;
  String get title => this._title;
  String get description => this._description;
  String get date => this._date;
  int get priority => this._priority;

  // All the setters
  set title(String newTittle) {
    if (newTittle.length <= 255) {
      this._title = newTittle;
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 255) {
      this._description = newDescription;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      this._priority = newPriority;
    }
  }

  // used to save and retrive from database

  // convert note object to map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (this._id != null) {
      map["id"] = this._id;
    }
    map["title"] = this._title;
    map["description"] = this._description;
    map["priority"] = this._priority;
    map["date"] = this._date;
    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map["id"];
    this._title = map["title"];
    this._description = map["description"];
    this._priority = map["priority"];
    this._date = map["date"];
  }
}
