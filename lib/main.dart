import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/network/api_base_helper.dart';
import 'package:quick_task/pages/home.dart';
import 'package:quick_task/pages/login.dart';
import 'package:quick_task/utils/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiBaseHelper().initializeApi();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _loadLoggedInStatus();
  }

  _loadLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      print("USERNAME__${prefs.getString('userName')}");
      _isLoading = false; // Set loading to false once preferences are loaded
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Quick Task',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(), // Show progress indicator
              ),
            )
          : (_isLoggedIn ? HomePage() : LoginPage()),
      debugShowCheckedModeBanner: false,
    );
  }
}
