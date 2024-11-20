import 'package:flutter/material.dart';

class TasksFetchingError extends StatelessWidget {
  const TasksFetchingError({super.key, required this.errorMsg});

  final String errorMsg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 72.0),
          child: Image.asset(
            "assets/images/no_tasks.png",
            scale: 0.5,
          ),
        ),
        Text(
          errorMsg,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
