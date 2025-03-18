import 'package:chat_app/models/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomCard extends StatefulWidget {
  final String title;
  final String content;

  const CustomCard({super.key, required this.title, required this.content});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.black.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Icon
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          // More Options Icon
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == "profile") {
                // Navigate to profile
              } else if (value == "logout") {
                // Clear session
                        Provider.of<SessionProvider>(context, listen: false).clearSession();
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('accessToken');
                        await prefs.remove('refreshToken');
                        await prefs.remove('accessTokenExpireDate');
                        await prefs.remove('refreshTokenExpireDate');
                        await prefs.remove('userRole');
                        await prefs.remove('authEmployeeID');
                        Navigator.pushReplacementNamed(context, '/landing');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "profile",
                child: Text("Profile"),
              ),
              const PopupMenuItem(
                value: "logout",
                child: Text("Logout"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
