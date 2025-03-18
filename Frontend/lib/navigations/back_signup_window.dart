import 'dart:convert';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/navigations/signin_window.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

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
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInWindow()),
        );
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['detail'] ?? 'Registration failed')),
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

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.bgColor),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.bgColor),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.bgColor),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      hintStyle: const TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Register User"),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/icons/farmer.gif', // Replace with your dementia app logo
              height: 200,
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('Username'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _fullNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('Full Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('Contact Number'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('Password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nicController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('NIC'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? Center(
                    child: Image.asset(
                      'assets/avatars/loading.gif',
                      height: 100,
                      width: 100,
                    ),
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: CustomButton(
                      text: 'Sign Up', // Pass button text
                      textColor: Colors.white, // Pass text color
                      prColor: Styles.successColor,
                      seColor: Styles.secondaryColor,
                      icon: Icons.app_registration, // Pass icon
                      onPressed: _registerUser,
                    ),
                  ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInWindow()),
                );
              },
              child: const Text(
                "If you're already got an account, click here",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
