import 'dart:convert';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/navigations/landing_screen.dart';
import 'package:chat_app/navigations/signin_window.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterUserScreen extends StatefulWidget {
  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();

  bool _isLoading = false;
  bool _agreeToTerms = false;

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("${ENVConfig.serverUrl}/register");
    final userData = {
      "username": _usernameController.text,
      "full_name": _fullNameController.text,
      "email": _emailController.text,
      "contact": _contactController.text,
      "password": _passwordController.text,
      "nic": _nicController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['detail'] ?? 'Registration failed')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(String labelText, String hintText, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.black54),
      fillColor: Colors.transparent,
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text("Let's", style: TextStyle(fontSize: 20, color: Colors.white)),
                  Text("Create Your Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: Colors.black87),
                    decoration: _buildInputDecoration('Username', 'Enter your username', Icons.person),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _fullNameController,
                    style: TextStyle(color: Colors.black87),
                    decoration: _buildInputDecoration('Full Naaasame', 'Enter your full name', Icons.person_outline),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.black87),
                    decoration: _buildInputDecoration('Email', 'Enter your email', Icons.email),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contactController,
                    style: TextStyle(color: Colors.black87),
                    decoration: _buildInputDecoration('Contact Number', 'Enter your contact number', Icons.phone),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.black87),
                    decoration: _buildInputDecoration('Password', 'Enter your password', Icons.lock),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nicController,
                    style: TextStyle(color: Colors.black87),
                    decoration: _buildInputDecoration('NIC', 'Enter your NIC', Icons.badge),
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? Center(
                    child: Image.asset(
                      'assets/avatars/loading.gif',
                      height: 100,
                      width: 100,
                    ),
                  )
                      :
                  _buildButton('Create Account', Styles.successColor, Colors.black87, _registerUser),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                      ),
                      Text("I agree to the "),
                      Text("Terms & Privacy", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildButton('Already have an Account!', Styles.successColor2, Colors.black87, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LandingPage()), // Navigate to ProfileScreen
                    );
                  }),
                ],
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

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _nicController.dispose();
    super.dispose();
  }
}
