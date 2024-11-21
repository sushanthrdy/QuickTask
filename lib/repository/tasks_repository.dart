import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/model/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskRepository {
  Future<ParseResponse> saveTask(TaskModel task) async {
    final username = await getUserName();
    final newTask = ParseObject('Task')
      ..set("title", task.taskName)
      ..set("priority", task.priority.index)
      ..set("dueDate", task.dueDate)
      ..set("isCompleted", false)
      ..set("userName", username);
    return await newTask.save();
  }

  Future<ParseResponse> fetchTasks(String status) async {
    final username = await getUserName();
    QueryBuilder<ParseObject> queryTodo =
        QueryBuilder<ParseObject>(ParseObject('Task'));
    queryTodo.whereEqualTo("userName", username);
    if (status == "In progress") {
      queryTodo.whereGreaterThanOrEqualsTo("dueDate", DateTime.now());
      queryTodo.whereEqualTo("isCompleted", false);
    } else if (status == "Completed") {
      queryTodo.whereEqualTo("isCompleted", true);
    } else {
      queryTodo.whereLessThan("dueDate", DateTime.now());
      queryTodo.whereEqualTo("isCompleted", false);
    }
    queryTodo.orderByAscending("dueDate");
    queryTodo.orderByAscending("priority");
    return await queryTodo.query();
  }

  Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName") ??
        ""; // Returns null if the key doesn't exist
  }

  Future<ParseResponse> deleteTask(String id) async {
    var todo = ParseObject('Task')..objectId = id;
    return await todo.delete();
  }

  Future<ParseResponse> updateTaskCompletion(String id, bool status) async {
    var task = ParseObject('Task')
      ..objectId = id
      ..set('isCompleted', status);
    return await task.save();
  }

  Future<ParseResponse> updateTask(TaskModel taskModel) async {
    var task = ParseObject('Task')
      ..objectId = taskModel.taskId
      ..set("title", taskModel.taskName)
      ..set("priority", taskModel.priority.index)
      ..set("dueDate", taskModel.dueDate);
    return await task.save();
  }
}
