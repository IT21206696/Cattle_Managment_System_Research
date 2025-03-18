import 'dart:convert';

import 'package:chat_app/constants/env.dart';
import 'package:chat_app/navigations/animal_feeding_summary.dart';
import 'package:chat_app/navigations/animal_milking_history_screen.dart';
import 'package:chat_app/navigations/farm_management_screen.dart';
import 'package:chat_app/navigations/growth_profile_screen.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class AnimalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> animal;

  // Constructor to receive animal details
  const AnimalDetailsScreen({super.key, required this.animal});

  @override
  _AnimalDetailsScreenState createState() => _AnimalDetailsScreenState();
}

class _AnimalDetailsScreenState extends State<AnimalDetailsScreen> {
  late bool isActive;
  int selectedTabIndex = 2; // Default tab index for "Health Details"

  // Lists to hold milk and feed details
  List<Map<String, dynamic>> milkRecords = [];
  List<Map<String, dynamic>> feedRecords = [];
  late LineChartData _milkChartData;

  @override
  void initState() {
    super.initState();
    // Initialize the switch state based on the passed 'status'
    isActive = widget.animal['status'] == 'active';
  }

  // Update the status when the switch is toggled
  void _toggleStatus(bool value) {
    setState(() {
      isActive = value;
      widget.animal['status'] = isActive ? 'active' : 'inactive';
    });
    // Optionally, you can add logic here to update the status in the backend or database
  }

  // Function to change the selected tab
  void _onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  void _updateAnimal(Map<String, dynamic> updates) async {
    final animalId = widget.animal['id']; // Assuming animal has an 'id' field
    final response = await http.patch(
      Uri.parse(ENVConfig.serverUrl+'/update-animal/$animalId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update animal')),
      );
    }
  }

  // Function to show the popup form for Milk or Feed Details
  void _showAddDetailPopup(String type) {
    final dateController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $type Detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                keyboardType: TextInputType.datetime,
                style: const TextStyle(
                    color: Colors.white70), // Changed to white70
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value (liters)'),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Colors.white70), // Changed to white70
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final date = dateController.text;
                final value = double.tryParse(valueController.text) ?? 0.0;

                if (date.isNotEmpty && value > 0) {
                  setState(() {
                    if (type == 'Milk') {
                      milkRecords.add({'date': date, 'value': value});
                      // Add new point to the chart
                      _updateMilkChartData();
                    } else if (type == 'Feed') {
                      feedRecords.add({'date': date, 'value': value});
                    }
                  });
                }

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _updateMilkChartData() {
    List<FlSpot> spots = [];
    for (int i = 0; i < milkRecords.length; i++) {
      DateTime date = DateTime.parse(milkRecords[i]['date']);
      double value = milkRecords[i]['value'];
      spots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), value));
    }

    // Update the graph with the new data
    setState(() {
      _milkChartData = LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.black, // Set the line color to black
            belowBarData: BarAreaData(
                show: false), // Optionally hide the area below the line
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
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
                child: const CustomCard(title: 'Animal Summary', content: 'Choose options you want to visit',),
              ),
              SizedBox(height: 10,),
              Padding(padding: EdgeInsets.all(20),
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Animal Image
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(widget.animal['image']),
                                  backgroundColor: Styles.primaryAccent,
                                  onBackgroundImageError: (_, __) {
                                    // Fallback icon if image fails to load
                                  },
                                ),
                                const SizedBox(width: 16),
                                // Animal Information Summary
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.animal['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Type: ${widget.animal['type']}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        'DOB: ${widget.animal['dob']}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        'Gender: ${widget.animal['gender']}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        'Health: ${widget.animal['health']}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        'Status: ${widget.animal['status']}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                                // Switch for Active/Inactive Status

                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GrowthProfileScreen(
                                              animal: widget
                                                  .animal)), // Navigate to ProfileScreen
                                    );
                                  },
                                  child: const Text('More Status'),
                                ),
                                Column(
                                  children: [
                                    const Text('Milking Status', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                    DropdownButton<String>(
                                      value: widget.animal['status'],
                                      dropdownColor: Styles.secondaryAccent,
                                      style: const TextStyle(color: Colors.white),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            widget.animal['status'] = newValue;
                                          });
                                          // Call API to update status
                                          _updateAnimal({'status': newValue});
                                        }
                                      },
                                      items: ['Pregnant', 'Active', 'Inactive', 'Lactating', 'Heifers', 'Breeding', 'Bulls', 'Calves']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),

                                // Switch to update health status
                                Column(
                                  children: [
                                    const Text('Health', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                    Switch(
                                      value: widget.animal['health'] == 'Healthy',
                                      onChanged: (bool newValue) {
                                        setState(() {
                                          widget.animal['health'] = newValue ? 'Healthy' : 'Unhealthy';
                                        });
                                        // Call API to update health status
                                        _updateAnimal({'health': widget.animal['health']});
                                      },
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.red,
                                      inactiveTrackColor: Colors.red.shade200,
                                    ),
                                  ],
                                ),

                                // Button to trigger update request
                                // IconButton(
                                //   icon: const Icon(Icons.update, color: Colors.white),
                                //   onPressed: () {
                                //     _updateAnimal({
                                //       'status': widget.animal['status'],
                                //       'health': widget.animal['health'],
                                //     });
                                //   },
                                // ),
                              ],
                            ),
                          ],
                        )
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "Other Details" Section
                    Text(
                      'Other Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Styles.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Custom Tab Bar with Icons
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Styles.secondaryAccent,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Milk Records Icon
                            GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AnimalMilkingHistoryScreen(animal: widget.animal)),
                                );
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.local_drink,
                                    size: 30,
                                    color: selectedTabIndex == 0
                                        ? Styles.primaryColor
                                        : Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Milk Records',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selectedTabIndex == 0
                                          ? Styles.primaryColor
                                          : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Feed Details Icon
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AnimalFeedingSummaryScreen(animal: widget.animal)),
                                );
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.fastfood,
                                    size: 30,
                                    color: selectedTabIndex == 1
                                        ? Styles.primaryColor
                                        : Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Feed Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selectedTabIndex == 1
                                          ? Styles.primaryColor
                                          : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Health Details Icon
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          GrowthProfileScreen(animal: widget.animal)),
                                );
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.health_and_safety,
                                    size: 30,
                                    color: selectedTabIndex == 2
                                        ? Styles.primaryColor
                                        : Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Growth Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selectedTabIndex == 2
                                          ? Styles.primaryColor
                                          : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Styles.secondaryAccent,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Milk Records Icon
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FarmManagementScreen(animal: widget.animal,)),
                                );
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.local_drink,
                                    size: 30,
                                    color: selectedTabIndex == 0
                                        ? Styles.primaryColor
                                        : Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Location Dat',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selectedTabIndex == 0
                                          ? Styles.primaryColor
                                          : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Feed Details Icon

                          ],
                        ),
                      ),
                    ),

                    // Display Content based on the selected tab

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
