import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/animals_screen.dart';
import 'package:chat_app/navigations/breed_detection_screen.dart';
import 'package:chat_app/navigations/cattle_growth_monitoring_screen.dart';
import 'package:chat_app/navigations/farm_management_screen.dart';
import 'package:chat_app/navigations/feeding_records_screen.dart';
import 'package:chat_app/navigations/health_monitoring_screen.dart';
import 'package:chat_app/navigations/milk_monitoring_screen.dart';
import 'package:chat_app/navigations/milk_records_screen.dart';
import 'package:chat_app/navigations/pests_inspection_screen.dart';
import 'package:chat_app/navigations/profile_screen.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:chat_app/widgets/idea_card.dart';
import 'package:chat_app/widgets/long_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: ListView(
            // padding: const EdgeInsets.all(20),
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
                child: const CustomCard(title: 'Dashboard', content: 'Choose options you want to visit',),
              ),
              SizedBox(height: 20),
              // Home Banner
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Farm Summary",
                      style: TextStyle(
                        fontSize: 15,
                        color: Styles.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Profile Section
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ProfileScreen()), // Navigate to ProfileScreen
                                  );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 60, // Larger avatar for profile
                                      backgroundColor: Styles.secondaryAccent,
                                      child: Icon(Icons.person, size: 40, color: Colors.white),
                                    ),
                                    Positioned(
                                      top: -5,
                                      right: -5,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2), // Optional border for better contrast
                                        ),
                                        child: const Text(
                                          '3', // Notification number
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
                              Text(
                                "Your Profile",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Styles.secondaryAccent,
                                ),
                              ),
                            ],
                          ),

                          // Spacer to keep the layout aligned
                          const SizedBox(width: 3),

                          // Properties Section
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => FarmManagementScreen()), // Navigate to PropertiesScreen
                                  // );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 30, // Smaller avatar for properties
                                      backgroundColor: Styles.secondaryColor,
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
                              Text(
                                "Your Properties",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Styles.secondaryAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 3),

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
                                      backgroundColor: Styles.secondaryColor,
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
                              Text(
                                "Your Animals",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Styles.secondaryAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Popular Queries
                    Text(
                      "Management Activities",
                      style: TextStyle(
                        fontSize: 15,
                        color: Styles.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // const SizedBox(height: 5),
                    // LongCard(
                    //   title: "Farm Management",
                    //   icon: Icons.dashboard,
                    //   navigationWindow: FarmManagementScreen(),
                    // ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "Cattle Tracking",
                      icon: Icons.pets,
                      navigationWindow: AnimalsSummaryScreen(),
                    ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "Breed Detection",
                      icon: Icons.dashboard,
                      navigationWindow: BreedDetectionScreen(),
                    ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "Pests and Disease Inspection",
                      icon: Icons.bug_report,
                      navigationWindow: PestInspectionScreen(),
                    ),
                    const SizedBox(height: 10),
                    LongCard(
                      title: "Health and Nutrition Monitoring",
                      icon: Icons.healing,
                      navigationWindow: HealthMonitoringScreen(),
                    ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "Milk Monitoring",
                      icon: Icons.pets,
                      navigationWindow: MilkRecordsScreen(),
                    ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "Feed Pattern",
                      icon: Icons.pets,
                      navigationWindow: FeedingRecordsScreen(),
                    ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "Growth Monitoring",
                      icon: Icons.pets,
                      navigationWindow: CattleWeightPredictionScreen(),
                    ),
                    const SizedBox(height: 5),
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
