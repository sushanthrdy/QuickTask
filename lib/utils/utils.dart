import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_color.dart';

class Utils {
  static textFieldInputDecoration(
      {required String labelText, Icon? prefixIcon, Icon? suffixIcon}) {
    return InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColor.greyColor)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppColor.greyColor), // Border color when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppColor.orangeColor,
              width: 2), // Border color when focused
        ),
        labelText: labelText,
        filled: true,
        fillColor: AppColor.grey1,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon);
  }

  static bool isCurrentYear(DateTime parsedDate) {
    final currentYear = DateTime.now().year; // Get the current year
    return parsedDate.year == currentYear;   // Compare years
  }

  static void showError(BuildContext context,String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static DateTime getNormalizedDate(DateTime dt){
    DateTime now = dt.add(const Duration(days: 1));
    DateTime normalizedDate = DateTime(now.year, now.month, now.day);
    DateTime correctDueDate = normalizedDate.subtract(const Duration(seconds: 1));
    return correctDueDate;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }
}
