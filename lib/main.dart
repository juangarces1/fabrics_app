import 'dart:convert';

import 'package:fabrics_app/Models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fabrics_app/Screens/home_screen_modern.dart';
import 'package:fabrics_app/Screens/login_screen.dart';
import 'package:fabrics_app/Screens/wait_screen.dart';
import 'package:provider/provider.dart';
import 'package:fabrics_app/Providers/cart_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _showLoginPage = true;

  late User _user;

  @override
  void initState() {
    super.initState();
    _getHome();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tex App',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.oswaldTextTheme(Theme.of(context).textTheme),
      ),
      builder: (context, child) {
        return child!;
      },
      home: _isLoading
          ? const WaitScreen()
          : _showLoginPage
          ? const LoginScreen()
          : HomeScreenModern(user: _user),
    );
  }

  void _getHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRemembered = prefs.getBool('isRemembered') ?? false;
    if (isRemembered) {
      String? userBody = prefs.getString('userBody');
      if (userBody != null) {
        var decodedJson = jsonDecode(userBody);
        _user = User.fromJson(decodedJson);
        _showLoginPage = false;

        // Cargar órdenes pendientes si el usuario está logueado
        if (mounted) {
          context.read<CartProvider>().loadFromPrefs();
        }
      }
    }
    _isLoading = false;
    if (mounted) setState(() {});
  }
}
