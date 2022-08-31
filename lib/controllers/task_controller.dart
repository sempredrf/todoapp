import 'package:get/get.dart';
import 'package:todoapp/db/db_helper.dart';
import 'package:todoapp/models/task.dart';

class TaskController extends GetxController {
  @override
  void onReady() {
    getTasks();
    super.onReady();
  }

  var taskList = <Task>[].obs;

  Future<int>? addTask({required Task task}) async {
    return await DataBaseHelper.insert(task);
  }

  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DataBaseHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  void delete(Task task) {
    DataBaseHelper.delete(task);
    taskList.remove(task);
  }

  void completeTask(Task task) {
    task.isCompleted = 1;
    DataBaseHelper.update(task);
    taskList.refresh();
  }
}
