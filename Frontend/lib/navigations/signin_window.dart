import 'dart:convert';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:chat_app/navigations/signup_window.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInWindow extends StatefulWidget {
  @override
  _SignInWindowState createState() => _SignInWindowState();
}

class _SignInWindowState extends State<SignInWindow> {
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

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.bgColor),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.bgColor),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.bgColor),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      appBar: AppBar(
        title: const Text("Sign In"),
        backgroundColor: Styles.bgColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/icons/cow.gif', // Replace with your dementia app logo
                height: 200,
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _usernameController,
                style: TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Username'),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Password'),
              ),
              SizedBox(height: 20.0),
              _isLoading
                  ? Center(
                child: Image.asset(
                  'assets/images/loading.gif',
                  height: 50.0,
                  width: 50.0,
                ),
              )
                  : SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: CustomButton(
                  text: 'Get to Dashboard', // Pass button text
                  textColor: Colors.white, // Pass text color
                  prColor: Styles.primaryColor,
                  seColor: Styles.primaryAccent,
                  icon: Icons.transit_enterexit, // Pass icon
                  onPressed: _signIn,
                ),
              ),
              SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterUserScreen()),
                  );
                },
                child: Text(
                  'Don’t have an account? Sign up',
                  style: TextStyle(color: Styles.fontLight),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
