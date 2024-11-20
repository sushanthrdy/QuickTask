import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/bloc/login_bloc.dart';
import 'package:quick_task/pages/create_task.dart';
import 'package:quick_task/pages/login.dart';
import 'package:quick_task/pages/task_list.dart';

import '../network/api_response.dart';
import '../utils/app_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late LoginBloc _bloc;
  late ValueNotifier<bool> _isLoadingNotifier;

  @override
  void initState() {
    super.initState();
    _isLoadingNotifier = ValueNotifier(false);

    _bloc = LoginBloc();

    // Listen to stream updates
    _bloc.getLoginResponse()?.listen((response) {
      if (response.status == Status.LOADING) {
        setState(() {
          _isLoadingNotifier.value = true;
        });
      } else {
        setState(() {
          _isLoadingNotifier.value = false;
        });
        if (response.status == Status.SUCCESS) {
          // Navigate to login screen
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()));
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
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.greyColor,
            scrolledUnderElevation: 0,
            title: const Center(
              child: Text(
                "QuickTask",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  onPressed: () {
                    // Logout
                    showLogoutAlert(context, onLogoutPressed: () {
                      Navigator.of(context).pop();
                      _bloc.logoutUser();
                    });
                  },
                  icon: const Icon(Icons.logout))
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigate to add task
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateTaskPage()));
            },
            child: const Icon(Icons.add),
          ),
          body: Container(
              color: AppColor.greyColor,
              child: Container(
                decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32))),
                    color: Colors.white),
                child: TaskListPage(isLoadingNotifier: _isLoadingNotifier),
              ))),
      ValueListenableBuilder<bool>(
        valueListenable: _isLoadingNotifier,
        builder: (context, isLoading, child) {
          if (!isLoading) return const SizedBox.shrink();
          return Container(
            color: Colors.black54, // Semi-transparent overlay
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    ]);
  }

  static void showLogoutAlert(BuildContext context,
      {required VoidCallback onLogoutPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("QuickTask"),
          content: const Text("Are you sure want to logout?"),
          actions: <Widget>[
            TextButton(onPressed: onLogoutPressed, child: const Text("Yes")),
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
