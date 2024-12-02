import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/widgets/tasks_fetching_error.dart';

import '../model/task_model.dart';
import '../network/api_response.dart';
import '../utils/utils.dart';

class TasksListDataWidget extends StatelessWidget {
  final AsyncSnapshot<ApiResponse<Map<String, dynamic>>> snapshot;
  final String selectedStatus;
  final Function(TaskModel) onTaskItemClicked;

  const TasksListDataWidget(
      {super.key,
      required this.snapshot,
      required this.selectedStatus,
      required this.onTaskItemClicked});

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      if (snapshot.data?.status == Status.SUCCESS) {
        final tasks = (snapshot.data?.data?["tasks"] as ParseResponse).results as List<ParseObject>?;
        if (tasks != null) {
          return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                final task = tasks[index];
                final taskName = task.get<String>("title")!;
                final priorityIndex = task.get<int>('priority')!;
                Priority priority = Priority.values[priorityIndex];
                final dueDate = task.get<DateTime>('dueDate')!.toLocal();
                final taskItem = TaskModel(
                    taskId: task.objectId!,
                    taskName: taskName,
                    priority: priority,
                    dueDate: dueDate);
                return GestureDetector(
                  onTap: () {
                    onTaskItemClicked(taskItem);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Card(
                      color: Colors.white,
                      elevation: index == 0 ? 4 : 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: index == 0 ? Colors.white : Colors.grey,
                              width: 0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    taskItem.taskName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        color: taskItem.priority.bgColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 16),
                                        child: Text(
                                          taskItem.priority.name,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: taskItem.priority.fgColor),
                                        ),
                                      ))
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 1,
                                child: Text(
                                  Utils.isCurrentYear(taskItem.dueDate)
                                      ? "Due ${DateFormat("dd MMM").format(taskItem.dueDate)}"
                                      : "Due ${DateFormat("dd MMM yyyy").format(taskItem.dueDate)}",
                                  style: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        } else {
          return ListView(children: [
            TasksFetchingError(
                errorMsg: "You don't have any ${selectedStatus} Tasks.")
          ]);
        }
      } else {
        return ListView(children: [
          TasksFetchingError(errorMsg: snapshot.data?.message ?? "")
        ]);
      }
    } else {
      return ListView(children: [
        TasksFetchingError(errorMsg: snapshot.data?.message ?? "")
      ]);
    }
  }
}
