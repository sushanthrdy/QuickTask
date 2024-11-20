import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/bloc/tasks_bloc.dart';
import 'package:quick_task/model/task_model.dart';
import 'package:quick_task/pages/create_task.dart';
import 'package:quick_task/widgets/tasks_list_data_widget.dart';

import '../network/api_response.dart';
import '../widgets/shimmer_list.dart';

class TaskListPage extends StatefulWidget {
  final ValueNotifier<bool> isLoadingNotifier;

  const TaskListPage({super.key, required this.isLoadingNotifier});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final _progressValues = <String>["In progress", "Completed", "Incomplete"];
  late String _selectedStatus;
  late TasksBloc _bloc;

  @override
  void initState() {
    super.initState();
    _selectedStatus = _progressValues[0];
    _bloc = TasksBloc();

    _bloc.fetchTasks(_selectedStatus);

    _bloc.getTaskResponse()?.listen((response) {
      if (response.status == Status.LOADING) {
        setState(() {
          widget.isLoadingNotifier.value = true;
        });
      } else {
        setState(() {
          widget.isLoadingNotifier.value = false;
        });
        if (response.status == Status.SUCCESS) {
          _bloc.fetchTasks(_selectedStatus);
        } else if (response.status == Status.ERROR) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'An error occurred'),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButton<String>(
            value: _selectedStatus,
            icon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.keyboard_arrow_down),
            ),
            elevation: 16,
            underline: Container(
              height: 0,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              print("ASMDHAS $value");
              setState(() {
                _selectedStatus = value!;

                // Fetch tasks for the newly selected status
                _bloc.fetchTasks(_selectedStatus);
              });
            },
            dropdownColor: Colors.white,
            items: _progressValues
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black45),
                ),
              );
            }).toList(),
          ),
          Expanded(
              flex: 1,
              child: StreamBuilder(
                  stream: _bloc.getFetchTaskResponse(),
                  builder: (BuildContext context,
                      AsyncSnapshot<ApiResponse<List<ParseObject>?>>
                          snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ShimmerList(); // Shimmer effect while loading
                    } else if (snapshot.data?.status == Status.LOADING) {
                      return const ShimmerList();
                    } else {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await _bloc.fetchTasks(_selectedStatus);
                        },
                        child: TasksListDataWidget(
                          snapshot: snapshot,
                          selectedStatus: _selectedStatus,
                          onTaskItemClicked: (TaskModel task) {
                            print("ITEM CLICKED");
                            showModalBottomSheet<void>(
                              context: context,
                              backgroundColor: Colors.white,
                              builder: (BuildContext context) {
                                return bottomSheetContent(task);
                              },
                            );
                          },
                        ),
                      );
                    }
                  }))
        ],
      ),
    );
  }
  
  bottomSheetContent(TaskModel task){
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(
            top: 32.0,
            left: 16,
            right: 16,
            bottom: 48),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    task.taskName,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w800),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDeletionAlert(() {
                        _bloc.deleteTask(
                            task.taskId!);
                      });
                    },
                    icon: Icon(
                      Icons.delete_outlined,
                      color: Colors.red,
                    ))
              ],
            ),
            if (_selectedStatus != "Completed")
              ediTaskButton(task),
            markAsCompleteButton(task)
          ],
        ),
      ),
    );
  }

  ediTaskButton(TaskModel task){
    return Padding(
      padding: const EdgeInsets.only(
          top: 16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CreateTaskPage(
                        task: task,
                      )));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          // Background color
          padding: const EdgeInsets
              .symmetric(
              horizontal: 16,
              vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
                8),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
          MainAxisAlignment.start,
          // Align text to the start
          children: [
            Icon(Icons.edit,
                color: Colors.white),
            // Icon at the start
            SizedBox(width: 16),
            // Spacing between icon and text
            Text(
              'Edit Task',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  markAsCompleteButton(TaskModel task){
    return Padding(
      padding: const EdgeInsets.only(
          top: 16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          _bloc.updateTaskCompletion(
              task.taskId!,
              _selectedStatus ==
                  "Completed"
                  ? false
                  : true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
          Colors.deepPurpleAccent,
          // Background color
          padding:
          const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.start,
          // Align text to the start
          children: [
            const Icon(Icons.check_circle,
                color: Colors.white),
            // Icon at the start
            const SizedBox(width: 16),
            // Spacing between icon and text
            Text(
              _selectedStatus ==
                  "Completed"
                  ? 'Mark as pending'
                  : "Mark as done",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  showDeletionAlert(VoidCallback onDeleteClicked) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("QuickTask"),
          content: const Text("Are you sure want to delete?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                onDeleteClicked();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
