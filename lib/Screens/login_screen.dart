import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fabrics_app/Components/loader_component.dart';
import 'package:fabrics_app/Helpers/constans.dart';
import 'package:fabrics_app/Models/user.dart';
import 'package:fabrics_app/Screens/home_screen_modern.dart';
import 'package:fabrics_app/constans.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _password = '';
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _rememberme = true;
  bool _passwordShow = false;

  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimaryColor, kColorHomeBar, Color(0xFF020420)],
              ),
            ),
          ),
          // Subtle background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kColorAlternativo.withValues(alpha: 0.1),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _showLogo(),
                    const SizedBox(height: 20),
                    Text(
                      'TexApp',
                      style: GoogleFonts.oswald(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'SISTEMA DE GESTION',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Glass Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              _showPassword(),
                              const SizedBox(height: 10),
                              _showRememberme(),
                              const SizedBox(height: 20),
                              _showLoginButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showLoader) const LoaderComponent(text: 'Iniciando sesión...'),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return const Image(
      image: AssetImage('assets/rollostela.png'),
      width: 150,
      fit: BoxFit.fill,
    );
  }

  Widget _showPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            "Tu Contraseña",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextField(
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          obscureText: !_passwordShow,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            errorStyle: const TextStyle(color: Color(0xFFFF8A8A)),
            errorText: _passwordShowError ? _passwordError : null,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white70,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordShow
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () => setState(() => _passwordShow = !_passwordShow),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: kColorAlternativo, width: 2),
            ),
          ),
          onChanged: (value) => _password = value,
        ),
      ],
    );
  }

  Widget _showRememberme() {
    return Theme(
      data: ThemeData(unselectedWidgetColor: Colors.white54),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'Recordar cuenta',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        value: _rememberme,
        activeColor: kColorAlternativo,
        checkColor: Colors.white,
        onChanged: (value) => setState(() => _rememberme = value!),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _showLoginButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: kGradientTexApp,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffc91047).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _login,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Text(
              'INICIAR SESIÓN',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _storeUser(String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', true);
    await prefs.setString('userBody', body);
  }

  void _login() async {
    setState(() {
      _passwordShow = false;
    });

    if (!_validateFields()) {
      return;
    }

    setState(() {
      _showLoader = true;
    });

    var url = Uri.parse('${Constans.apiUrl}/api/Kilos/LogIn/$_password');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
    );

    setState(() {
      _showLoader = false;
    });

    if (response.statusCode >= 400) {
      setState(() {
        _passwordShowError = true;
        _passwordError = "Contraseña incorrecta";
      });
      return;
    }

    var body = response.body;

    if (_rememberme) {
      _storeUser(body);
    }

    var decodedJson = jsonDecode(body);

    User user = User.fromJson(decodedJson);

    goHome(user);
  }

  bool _validateFields() {
    bool isValid = true;

    if (_password.isEmpty) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar tu contraseña.';
    } else {
      _passwordShowError = false;
    }

    setState(() {});
    return isValid;
  }

  void goHome(User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreenModern(user: user)),
    );
  }
}
