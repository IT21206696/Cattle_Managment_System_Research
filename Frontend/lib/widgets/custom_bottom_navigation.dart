import 'package:chat_app/navigations/animals_screen.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:chat_app/navigations/profile_screen.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavigationBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: BottomNavigationBar(
        backgroundColor: Colors.green.shade700,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: selectedIndex,
        onTap: (index) {
          onItemTapped(index);
          _navigateToScreen(index, context);  // Handle navigation
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home, selectedIndex == 0), // Glow effect if selected
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.map, selectedIndex == 1), // Glow effect if selected
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.person, selectedIndex == 2), // Glow effect if selected
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // Function to create icon with glow effect when selected
  Widget _buildIcon(IconData iconData, bool isSelected) {
    return Material(
      color: Colors.transparent, // Make the Material transparent
      elevation: isSelected ? 10 : 0, // Add elevation for shadow effect when selected
      child: Icon(
        iconData,
        size: 30,
        color: isSelected ? Colors.white : Colors.white70, // Change color for selected item
      ),
    );
  }

  void _navigateToScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Navigate to Home Screen
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimalsSummaryScreen()), // Navigate to Map Screen
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()), // Navigate to Profile Screen
        );
        break;
      default:
        break;
    }
  }
}
