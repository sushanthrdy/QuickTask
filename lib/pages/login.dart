import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/bloc/login_bloc.dart';
import 'package:quick_task/pages/home.dart';
import 'package:quick_task/pages/signup.dart';
import 'package:quick_task/utils/utils.dart';
import 'package:quick_task/widgets/rounded_gradient_button.dart';
import '../network/api_response.dart';
import '../utils/app_string.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late LoginBloc _bloc;
  bool _isLoading = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = LoginBloc();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  enabled: !_isLoading,
                  controller: _usernameController,
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
                  enabled: !_isLoading,
                  controller: _passwordController,
                  obscureText: true,
                  decoration: Utils.textFieldInputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter password";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                RoundedGradientButton(
                    child: StreamBuilder(
                        stream: _bloc.getLoginResponse(),
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

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                  );
                                });
                                return const Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                );
                              case Status.ERROR:
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _isLoading = false;
                                  Utils.showError(context,data.message ?? "");
                                });
                                return const Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                );
                            }
                          }
                          else if (snapshot.hasError) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _isLoading = false;
                              Utils.showError(context,AppString.snapShotErrorMsg);
                            });
                            // Handle unexpected errors (rare in your case as `ApiResponse` already manages errors)
                            return const Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            );
                          }

                          _isLoading = false;
                          // Default UI for when there's no data
                          return const Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          );
                        }),
                    onTap: () {
                      if (!_isLoading && _formKey.currentState!.validate()) {
                        _bloc.loginUser(
                            _usernameController.text, _passwordController.text);
                      }
                    }),
                const SizedBox(
                  height: 16,
                ),
                signUpButton(onTap: () {
                  //Navigate to signup screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()));
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
              text: "Welcome back to",
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

  signUpButton({required Function() onTap}) {
    return Align(
      alignment: Alignment.center,
      child: Text.rich(TextSpan(children: [
        const TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(color: Colors.black87, fontSize: 16)),
        TextSpan(
            text: "Create now",
            style: const TextStyle(
                color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = onTap)
      ])),
    );
  }

  navigateToHome(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }
}
