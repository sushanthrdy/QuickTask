import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_task/bloc/tasks_bloc.dart';
import 'package:quick_task/model/task_model.dart';
import 'package:quick_task/pages/home.dart';

import '../network/api_response.dart';
import '../utils/utils.dart';
import '../widgets/rounded_gradient_button.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key, this.task});

  final TaskModel? task;

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  int? _priorityValue;
  final _days = <String>["Today", "Tomorrow"];
  int? _selectedDueDay;
  final _titleController = TextEditingController();
  DateTime? _selectedDueDate;
  late TasksBloc _bloc;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bloc = TasksBloc();

    _priorityValue = widget.task?.priority.index;
    _titleController.text = widget.task?.taskName ?? "";
    if (widget.task != null && widget.task?.dueDate != null) {
      if (Utils.isToday(widget.task!.dueDate)) {
        _selectedDueDay = 0;
        _selectedDueDate = null;
      } else if (Utils.isTomorrow(widget.task!.dueDate)) {
        _selectedDueDay = 1;
        _selectedDueDate = null;
      } else {
        _selectedDueDay = null;
        _selectedDueDate = widget.task!.dueDate;
      }
    }

    _bloc.getTaskResponse()?.listen((response) {
      if (response.status == Status.LOADING) {
        setState(() {
          _isLoading = true;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (response.status == Status.SUCCESS) {
          // Navigate to login screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
          );
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
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 24.0, right: 24.0, bottom: 24.0, top: 64.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.cancel_outlined,
                        color: Colors.black26, size: 32),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.task != null ? "Update Task" : "New Task",
                    style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 32),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        dueDateSelectionWidget(),
                        ActionChip(
                          label: _selectedDueDate != null
                              ? Text(
                                  DateFormat("dd MMM yyyy")
                                      .format(_selectedDueDate!),
                                  style: const TextStyle(color: Colors.white))
                              : const Icon(
                                  Icons.schedule,
                                  color: Colors.black,
                                  size: 20,
                                ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(24)),
                              side: BorderSide(
                                  color: _selectedDueDate != null
                                      ? Colors.red
                                      : Colors.black38)),
                          backgroundColor: _selectedDueDate != null
                              ? Colors.red
                              : Colors.white,
                          onPressed: () {
                            _selectDate();
                          },
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFormField(
                          controller: _titleController,
                          decoration: Utils.textFieldInputDecoration(
                            labelText: "Title",
                          ),
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: 80,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter title";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          "PRIORITY",
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16.0),
                        prioritySelectionWidget(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  RoundedGradientButton(
                      child: Text(
                        widget.task != null ? "Update" : "Create",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        if (_selectedDueDate == null &&
                            _selectedDueDay == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select due date."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else if (_formKey.currentState!.validate()) {
                          if (_priorityValue == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please assign priority."),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } else {
                            widget.task == null
                                ? _bloc.saveTask(TaskModel(
                                    taskName: _titleController.text,
                                    priority:
                                        Priority.values[_priorityValue ?? 0],
                                    dueDate: _selectedDueDay == null
                                        ? Utils.getNormalizedDate(
                                            _selectedDueDate!)
                                        : (_selectedDueDay == 0
                                            ? Utils.getNormalizedDate(
                                                DateTime.now())
                                            : Utils.getNormalizedDate(
                                                DateTime.now().add(
                                                    const Duration(days: 1))))))
                                : _bloc.updateTask(TaskModel(
                                    taskId: widget.task!.taskId,
                                    taskName: _titleController.text,
                                    priority:
                                        Priority.values[_priorityValue ?? 0],
                                    dueDate: _selectedDueDay == null
                                        ? Utils.getNormalizedDate(
                                            _selectedDueDate!)
                                        : (_selectedDueDay == 0
                                            ? Utils.getNormalizedDate(DateTime.now())
                                            : Utils.getNormalizedDate(DateTime.now().add(const Duration(days: 1))))));
                          }
                        }
                      }),
                  const SizedBox(
                    height: 16,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      if (_isLoading)
        // Full-screen loader overlay
        Container(
          color: Colors.black54, // Semi-transparent overlay
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
    ]);
  }

  Widget dueDateSelectionWidget() {
    return Wrap(spacing: 5.0, children: [
      ...List.generate(
        _days.length,
        (int index) {
          return ChoiceChip(
            label: Text(
              _days[index],
              style: TextStyle(
                  color:
                      _selectedDueDay == index ? Colors.white : Colors.black),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
            selected: _selectedDueDay == index,
            onSelected: (bool selected) {
              setState(() {
                _selectedDueDay = selected ? index : null;
                _selectedDueDate = null;
              });
            },
            showCheckmark: false,
            selectedColor: Colors.red,
            backgroundColor: Colors.white,
          );
        },
      ),
    ]);
  }

  Widget prioritySelectionWidget() {
    return Wrap(
      spacing: 5.0,
      children: List<Widget>.generate(
        Priority.values.length,
        (int index) {
          return ChoiceChip(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32)),
                side: BorderSide(color: Priority.values[index].bgColor)),
            label: Text(
              Priority.values[index].name,
              style: TextStyle(
                  color: _priorityValue == index ? Colors.white : Colors.black),
            ),
            selected: _priorityValue == index,
            backgroundColor: Priority.values[index].bgColor,
            selectedColor: Priority.values[index].fgColor,
            checkmarkColor: Colors.white,
            onSelected: (bool selected) {
              setState(() {
                _priorityValue = selected ? index : null;
              });
            },
          );
        },
      ).toList(),
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
        helpText: "Select due date",
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 2)),
        firstDate: DateTime.now().add(const Duration(days: 2)),
        lastDate: DateTime(2050));
    if (pickedDate != null) {
      setState(() {
        _selectedDueDay = null;
        _selectedDueDate = pickedDate;
      });
    }
  }
}
