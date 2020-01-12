import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/util/dbhelper.dart';

DBHelper helper = DBHelper();
final List<String> choices = const <String>[
  'Save Todo & Back',
  'Delete Todo',
  'Back to List'
];
const menuSave = 'Save Todo & Back';
const menuDelete = 'Delete Todo';
const menuBack = 'Back to List';

class TodoDetail extends StatefulWidget {
  final Todo todo;
  final String action;
  TodoDetail(this.todo, this.action);

  @override
  State<StatefulWidget> createState() => TodoDetailState(this.todo, this.action);
}

class TodoDetailState extends State {
  Todo todo;
  final String action;
  TodoDetailState(this.todo, this.action);

  final _priorities = ["High", "Medium", "Low"];
  String _priority = "Low";
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  final formDistance = 5.0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    titleController.text = todo.title;
    descController.text = todo.description;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(todo.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value)  => select(value),
            itemBuilder: (BuildContext context) {
              return choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(15.0),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(top: formDistance, bottom: formDistance),
                  child: TextField(
                    decoration: InputDecoration(labelText: "Title"),
                    controller: titleController,
                    onChanged: (value) => updateTitle(),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: formDistance, bottom: formDistance),
                  child: TextField(
                      decoration: InputDecoration(labelText: "Description"),
                      controller: descController,
                      onChanged: (value) => updateDescription()),
                ),
                ListTile(
                  title: DropdownButton<String>(
                    items: _priorities.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: retrievePriority(todo.priority),
                    onChanged: (value) => updatePriority(value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onDropDownItemSelected(String value) {
    setState(() {
      this._priority = value;
    });
  }

  void select(String value) async {
    int result;
    switch (value) {
      case menuSave:
        save();
        break;
      case menuDelete:
        Navigator.pop(context, true);
        if (todo.id == null) {
          return;
        }
        result = await helper.deleteTodo(todo.id);
        if (result != 0) {
          AlertDialog alertDialog = AlertDialog(
            title: Text("Delete Todo"),
            content: Text("The todo has been deleted"),
          );
          showDialog(context: context, builder: (_) => alertDialog);
        }
        break;
      case menuBack:
        Navigator.pop(context, true);
        break;
      default:
    }
  }

  void save() {
    todo.date = DateFormat.yMd().format(DateTime.now());
    switch(action){
      case "insert":
        helper.insertTodo(todo);
        Navigator.pop(context, true);
        break;
      case "update":
        helper.updateTodo(todo);
        break;
    }
  }

  void updatePriority(String value) {
    switch (value) {
      case "High":
        todo.priority = 1;
        break;
      case "Medium":
        todo.priority = 2;
        break;
      case "Low":
        todo.priority = 3;
        break;
    }
    setState(() {
      _priority = value;
    });
  }

  String retrievePriority(int value) {
    return _priorities[value - 1];
  }

  void updateTitle() {
    todo.title = titleController.text;
  }

  void updateDescription() {
    todo.description = descController.text;
  }
}
