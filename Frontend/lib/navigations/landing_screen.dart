import 'dart:convert';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/forget_password_screen.dart';
import 'package:chat_app/navigations/landing_page_sinhala.dart';
import 'package:chat_app/navigations/signup_window.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;


  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ENVConfig.serverUrl}/login');
    final signInData = {
      "username": _usernameController.text,
      "password": _passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signInData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        // Save user data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', user['username']);
        await prefs.setString('email', user['email']);
        await prefs.setString('fullName', user['full_name'] ?? '');
        await prefs.setString('contactNumber', user['contact_number'] ?? '');

        Provider.of<SessionProvider>(context, listen: false).updateSession(
          accessToken: "N/A",
          refreshToken: "N/A",
          userRole: "N/A",
          authEmployeeID: user['username'] ?? '',
          complications: [],
          contactNumber: user['contact_number'] ?? '',
          createdAt: DateTime.now(),
          email: user['email'] ?? '',
          fullName: user['full_name'] ?? '',
          userId: user['username'] ?? '',
          username: user['username'] ?? '',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  InputDecoration _buildInputDecoration(String labelText, String hintText, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white70),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white),
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.successColor2),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Styles.secondaryColor, Styles.secondaryAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            // Logo
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('assets/images/logo-bg.png'),
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 20),
            // App Title
            const Text(
              'Cowherd',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFBC02D),
              ),
            ),
            const Text(
              'CATTLE CARE APP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPageSinhala()),
                );
              },
              child: Text(
                'සිංහල',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent, // Hyperlink-style color
                  decoration: TextDecoration.underline, // Underline for hyperlink effect
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Input Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: _buildInputDecoration('Email Address', 'Provide Email Address', Icons.email),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _buildInputDecoration('Password', 'Provide your Password', Icons.password),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Forgot Password and Buttons
            Expanded(
              child: Container(
                width: double.infinity, // Full width
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, // Change background color as needed
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()), // Navigate to ProfileScreen
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Styles.secondaryColor, // Custom color for the link
                          fontSize: 14,
                          decoration: TextDecoration.underline, // Underline to indicate it's a link
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : _buildButton('Login', Styles.successColor, Colors.white, _signIn),
                    const SizedBox(height: 10),
                    Text(
                      'or',
                      style: TextStyle(color: Styles.secondaryColor, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    _buildButton('Create an account', Styles.successColor2, Colors.black87, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterUserScreen()), // Navigate to ProfileScreen
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
