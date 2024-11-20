import 'package:flutter/material.dart';
import 'package:quick_task/utils/app_color.dart';

class RoundedGradientButton extends StatelessWidget {
  RoundedGradientButton(
      {Key? key,
      this.height,
      this.width,
      this.onTap,
      this.loading = false,
      required this.child})
      : super(key: key);
  double? height;
  double? width;
  VoidCallback? onTap;
  bool loading;
  Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
              child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColor.orangeColor, AppColor.pinkColor])),
          )),
          TextButton(
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  textStyle: const TextStyle(fontSize: 20)),
              onPressed: onTap,
              child: Center(
                child: child
              ))
        ],
      ),
    );
  }
}
