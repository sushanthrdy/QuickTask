import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/bloc/signup_bloc.dart';
import 'package:quick_task/network/api_response.dart';
import 'package:quick_task/pages/home.dart';
import 'package:quick_task/utils/app_string.dart';

import '../utils/utils.dart';
import '../widgets/rounded_gradient_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  late SignUpBloc _bloc;
  final _userNameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bloc = SignUpBloc();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _userNameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                loginHeader(),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _userNameController,
                  maxLines: 1,
                  maxLength: 16,
                  decoration: Utils.textFieldInputDecoration(
                      labelText: "Username",
                      prefixIcon: const Icon(Icons.person)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Username";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: Utils.textFieldInputDecoration(
                      labelText: "New Password",
                      prefixIcon: const Icon(Icons.lock)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter new password";
                    } else if (!validateStructure(value)) {
                      return "Password must include 8+ chars, upper, lower, number & special.";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: Utils.textFieldInputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: const Icon(Icons.lock)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter confirm password";
                    } else if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                RoundedGradientButton(
                    child: StreamBuilder(
                        stream: _bloc.getSignupResponse(),
                        builder: (BuildContext context,
                            AsyncSnapshot<ApiResponse<ParseResponse>>
                                snapshot) {
                          if (snapshot.hasData) {
                            final data = snapshot.data!;
                            switch (data.status) {
                              case Status.LOADING:
                                _isLoading = true;
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.white,
                                ));
                              case Status.SUCCESS:
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _isLoading = false;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                    (Route<dynamic> route) => false,
                                  );
                                });
                                return const Text(
                                  "Signup",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                );
                              case Status.ERROR:
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _isLoading = false;
                                  Utils.showError(context, data.message ?? "");
                                });
                                return const Text(
                                  "Signup",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                );
                            }
                          } else if (snapshot.hasError) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _isLoading = false;
                              Utils.showError(context,
                                  AppString.snapShotErrorMsg);
                            });
                            // Handle unexpected errors (rare in your case as `ApiResponse` already manages errors)
                            return const Text(
                              "Signup",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            );
                          }

                          _isLoading = false;
                          // Default UI for when there's no data
                          return const Text(
                            "Signup",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          );
                        }),
                    onTap: () {
                      if (!_isLoading && _formKey.currentState!.validate()) {
                        _bloc.signUpUser(_userNameController.text,
                            _newPasswordController.text);
                      }
                    }),
                const SizedBox(
                  height: 16,
                ),
                signInButton(onTap: () {
                  //Navigate to signup screen
                  Navigator.pop(context);
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  loginHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hey,",
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 32),
        ),
        Text.rich(TextSpan(children: <TextSpan>[
          TextSpan(
              text: "Welcome to",
              style: TextStyle(color: Colors.black, fontSize: 24)),
          TextSpan(
              text: " QuickTask",
              style: TextStyle(color: Colors.red, fontSize: 24))
        ])),
        SizedBox(
          height: 4,
        ),
        Text(
          "Let's Get Stuff Done.",
          style: TextStyle(color: Colors.black87),
        ),
      ],
    );
  }

  signInButton({required Function() onTap}) {
    return Align(
      alignment: Alignment.center,
      child: Text.rich(TextSpan(children: [
        const TextSpan(
            text: "Already have an account? ",
            style: TextStyle(color: Colors.black87, fontSize: 16)),
        TextSpan(
            text: "Sign in",
            style: const TextStyle(
                color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = onTap)
      ])),
    );
  }

  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }
}
