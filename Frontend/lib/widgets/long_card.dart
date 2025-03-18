import 'package:chat_app/constants/styles.dart';
import 'package:flutter/material.dart';

class LongCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget navigationWindow;

  const LongCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.navigationWindow,
  }) : super(key: key);

  void _navigate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => navigationWindow),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Styles.secondaryAccent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Styles.secondaryAccent.withOpacity(0.4), width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: () => _navigate(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Styles.fontHighlight2, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, color: Color(0xFF94B7B1)),
            ],
          ),
        ),
      ),
    );
  }
}
