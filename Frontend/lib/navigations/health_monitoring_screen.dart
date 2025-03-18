import 'dart:convert';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HealthMonitoringScreen extends StatefulWidget {
  @override
  _HealthMonitoringScreenState createState() => _HealthMonitoringScreenState();
}

class _HealthMonitoringScreenState extends State<HealthMonitoringScreen> {
  // Form controllers
  final TextEditingController feedingAmount1Controller = TextEditingController();
  final TextEditingController feedingAmount2Controller = TextEditingController();
  final TextEditingController averageFoodWeightController = TextEditingController();
  final TextEditingController travelDistanceController = TextEditingController();

  // Dropdown selection and mappings
  String selectedReproductiveStatus = 'Breeding';
  final Map<String, int> reproductiveStatusMapping = {
    'Breeding': 0,
    'Lactating': 1,
    'Non-reproductive': 2,
    'Pregnant': 3,
  };

  String healthStatusResponse = "";

  // Function to send POST request
  Future<void> submitHealthData() async {
    final apiUrl = ENVConfig.serverUrl + '/predict-health-status'; // Update with your actual API endpoint

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reproductive_status': selectedReproductiveStatus,
          'feeding_amount_KG_1': double.parse(feedingAmount1Controller.text),
          'feeding_amount_KG_2': double.parse(feedingAmount2Controller.text),
          'average_food_weight_KG': double.parse(averageFoodWeightController.text),
          'travel_distance_per_day_KM': double.parse(travelDistanceController.text),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          healthStatusResponse = data['health_status'] ?? 'No response received';
        });
      } else {
        setState(() {
          healthStatusResponse = 'Failed to fetch health status';
        });
      }
    } catch (error) {
      setState(() {
        healthStatusResponse = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Monitoring'),
        backgroundColor: Styles.bgColor,
      ),
      backgroundColor: Styles.primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.health_and_safety, color: Colors.teal, size: 40),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Enter details to monitor Health & Nutrition',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Input form
              Text(
                'Reproductive Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              DropdownButtonFormField<String>(
                value: selectedReproductiveStatus,
                items: reproductiveStatusMapping.keys.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(
                      status,
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedReproductiveStatus = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.bgColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.bgColor, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 10),

              Text(
                'Feeding Amount (KG) - Morning',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              TextField(
                controller: feedingAmount1Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.bgColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.bgColor, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 10),

              Text(
                'Feeding Amount (KG) - Afternoon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              TextField(
                controller: feedingAmount2Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.bgColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.bgColor, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 10),

              Text(
                'Feeding Amount (KG) - Evening',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              TextField(
                controller: averageFoodWeightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.bgColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.bgColor, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 10),

              Text(
                'Travel Distance per Day (KM)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              TextField(
                controller: travelDistanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.bgColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.bgColor, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 20),

              // Submit button
              ElevatedButton(
                onPressed: submitHealthData,
                child: Text('Submit'),
              ),
              SizedBox(height: 20),

              // Display response
              if (healthStatusResponse.isNotEmpty)
                Text(
                  'Health Status: $healthStatusResponse',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        ),
      )
    );
  }
}
