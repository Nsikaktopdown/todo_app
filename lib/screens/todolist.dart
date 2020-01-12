import 'package:flutter/material.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/screens/TodoDetail.dart';
import 'package:todo_app/util/dbhelper.dart';

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends State {
  List<Todo> todoList;
  int count;
  DBHelper helper = DBHelper();
  @override
  Widget build(BuildContext context) {
    if (todoList == null) {
      todoList = List<Todo>();
      getData();
    }
    return Scaffold(
      body: todoListItems(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Todo('', 3, ''), "insert");
        },
        tooltip: "Add Todo",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView todoListItems() {
    return ListView.builder(
      itemCount: todoList.length,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getColor(this.todoList[position].priority),
                child: Text(this.todoList[position].priority.toString()),
              ),
              title: Text(this.todoList[position].title),
              subtitle: Text(this.todoList[position].date.toString()),
              onTap: () {
                navigateToDetail(this.todoList[position], "update");
              }),
        );
      },
    );
  }

  void getData() {
    final dbFuture = helper.initializeDb();
    dbFuture.then((results) {
      final todoFuture = helper.getTodos();
      todoFuture.then((results) {
        List<Todo> todos = List<Todo>();
        count = results.length;
        for (int i = 0; i < count; i++) {
          todos.add(Todo.fromObject(results[i]));
          debugPrint(todos[i].title);
        }
        setState(() {
          todoList = todos;
          count = count;
        });
        debugPrint("items" + count.toString());
      });
    });
  }

  //TODO("insert todos")
  void insertTodo() {
    final dbFuture = helper.initializeDb();
    dbFuture.then((result) {
      final insertTodoFuture = helper.insertTodo(
          Todo("Buy Mackbook", 2, DateTime.now().toString(), "a good once"));
      insertTodoFuture.then((result) {
        debugPrint("Inserted Todo");
      });
    });
  }

  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.orange;
        break;
      case 3:
        return Colors.green;
        break;

      default:
        return Colors.green;
    }
  }

  void navigateToDetail(Todo todo, String action) async {
    bool result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => TodoDetail(todo, action)));
    if(result == true){
      getData();
    }
  }
}
