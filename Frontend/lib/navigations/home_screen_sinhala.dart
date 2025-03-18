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

class HomeScreenSinhala extends StatefulWidget {
  const HomeScreenSinhala({super.key});

  @override
  State<HomeScreenSinhala> createState() => _HomeScreenSinhalaState();
}

class _HomeScreenSinhalaState extends State<HomeScreenSinhala> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'අමුත්තා';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
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
                child: const CustomCard(
                  title: 'පාලන පුවරුව',
                  content: 'ඔබට යාමට අවශ්‍ය විකල්ප තෝරන්න',
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ගොවිතැන සාරාංශය",
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
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                                  );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
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
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Text(
                                          '3',
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
                                "ඔබේ පැතිකඩ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Styles.secondaryAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 3),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => FarmManagementScreen()),
                                  // );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
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
                                          '12',
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
                                "ඔබේ වතු",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Styles.secondaryAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 3),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AnimalsSummaryScreen()),
                                  );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
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
                                          '5',
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
                                "ඔබේ සතුන්",
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
                    Text(
                      "කෘෂි කළමනාකරණ ක්‍රියාකාරකම්",
                      style: TextStyle(
                        fontSize: 15,
                        color: Styles.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // const SizedBox(height: 5),
                    // LongCard(
                    //   title: "ගොවි කළමනාකරණය",
                    //   icon: Icons.dashboard,
                    //   navigationWindow: FarmManagementScreen(),
                    // ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "ගවයන් නිරීක්ෂණය",
                      icon: Icons.pets,
                      navigationWindow: AnimalsSummaryScreen(),
                    ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "ජාති අනාවරණය",
                      icon: Icons.dashboard,
                      navigationWindow: BreedDetectionScreen(),
                    ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "පළිබෝධ නිරීක්ෂණය",
                      icon: Icons.bug_report,
                      navigationWindow: PestInspectionScreen(),
                    ),
                    const SizedBox(height: 10),
                    LongCard(
                      title: "සෞඛ්‍ය සහ පෝෂණ පාලනය",
                      icon: Icons.healing,
                      navigationWindow: HealthMonitoringScreen(),
                    ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "කිරි අධීක්ෂණය",
                      icon: Icons.pets,
                      navigationWindow: MilkRecordsScreen(),
                    ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "ආහාර පටිපාටිය",
                      icon: Icons.pets,
                      navigationWindow: FeedingRecordsScreen(),
                    ),
                    const SizedBox(height: 5),
                    LongCard(
                      title: "වැඩිදියුණු අධීක්ෂණය",
                      icon: Icons.pets,
                      navigationWindow: CattleWeightPredictionScreen(),
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
