import 'package:chat_app/constants/styles.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement password reset logic (API call, Firebase, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reset link sent to ${_emailController.text}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Icon(Icons.lock, size: 80, color: Colors.green),
          SizedBox(height: 10),
          Text(
            "Forgot Password?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          SizedBox(height: 5),
          Text(
            "No worries, we'll send you reset instructions",
            style: TextStyle(color: Colors.green.shade700),
          ),
          SizedBox(height: 20),
          Expanded(  // Ensures the container fills the remaining space
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Styles.secondaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email", style: TextStyle(color: Colors.white)),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Colors.white),
                              hintText: "Enter your Email",
                              filled: true,
                              fillColor: Colors.green.shade700,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Styles.successColor2),
                                borderRadius: BorderRadius.all(Radius.circular(30)),
                              ),
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Styles.successColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: Text("Reset Password", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          SizedBox(height: 15),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Navigate back to login
                              },
                              child: Text("Back to Login", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
