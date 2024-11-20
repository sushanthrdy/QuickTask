import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import '../utils/app_color.dart';

class TaskModel {
  TaskModel(
      {this.taskId,
      required this.taskName,
      required this.priority,
      required this.dueDate});

  final String? taskId;
  final String taskName;
  final Priority priority;
  final DateTime dueDate;
  final bool isCompleted = false;
}

enum Priority {
  HIGH(bgColor: AppColor.redLight, fgColor: AppColor.redDark),
  NORMAL(bgColor: AppColor.yellowLight, fgColor: AppColor.yellowDark),
  LOW(bgColor: AppColor.blueLight, fgColor: AppColor.blueDark);

  const Priority({required this.bgColor, required this.fgColor});

  final Color bgColor;
  final Color fgColor;
}
