import 'package:chat_app/navigations/animals_screen.dart';
import 'package:chat_app/widgets/custom_bottom_navigation.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String email = '';
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on index
    switch (index) {
      case 0:
      // Navigate to Home
        print("Home Clicked");
        break;
      case 1:
      // Navigate to Settings
        print("Settings Clicked");
        break;
      case 2:
      // Navigate to Profile
        print("Profile Clicked");
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  // Load username from SharedPreferences
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
      email = prefs.getString('authEmployeeID') ?? 'Emailx@gmail.com';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white, // Set the background color
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[800],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: const CustomCard(title: 'Your Profile', content: 'Your personal profile summary',),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Styles.secondaryAccent,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Profile Avatar
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Styles.primaryAccent,
                              child: Icon(Icons.person, size: 50, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            // Notification Text and Button
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "You have 5 new notifications",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(builder: (context) => NotificationsScreen()),
                                      // );
                                    },
                                    icon: Icon(Icons.notifications),
                                    label: Text("View Notifications"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Styles.secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // User Details Section
                    Text(
                      "User Details",
                      style: TextStyle(
                        fontSize: 15,
                        color: Styles.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.person, color: Styles.primaryAccent),
                      title: Text(
                        "Username",
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        username, // Display loaded username
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.email, color: Styles.primaryAccent),
                      title: Text(
                        "Email",
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        "email",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone, color: Styles.primaryAccent),
                      title: Text(
                        "Contact Number",
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        "+1 234 567 890",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.work, color: Styles.primaryAccent),
                      title: Text(
                        "Role",
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        "Farm Manager",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Farm Details",
                      style: TextStyle(
                        fontSize: 15,
                        color: Styles.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          // Properties Section
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ProfileScreen()), // Navigate to PropertiesScreen
                                  );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 30, // Smaller avatar for properties
                                      backgroundColor: Styles.infoColor,
                                      child: Icon(Icons.home, size: 30, color: Colors.white),
                                    ),
                                    Positioned(
                                      top: -5,
                                      right: -5,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Text(
                                          '12', // Notification number
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Your Properties",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF939797),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),

                          // Animals Section
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AnimalsSummaryScreen()), // Navigate to AnimalsScreen
                                  );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 30, // Smaller avatar for animals
                                      backgroundColor: Styles.infoColor,
                                      child: Icon(Icons.pets, size: 30, color: Colors.white),
                                    ),
                                    Positioned(
                                      top: -5,
                                      right: -5,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Text(
                                          '5', // Notification number
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Your Animals",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF939797),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
