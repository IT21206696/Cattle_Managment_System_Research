import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/constants/env.dart';  // Update the import for the ENVConfig path
import 'package:chat_app/constants/styles.dart';  // Update the import for the Styles path

class CattleWeightPredictionScreen extends StatefulWidget {
  @override
  _CattleWeightPredictionScreenState createState() => _CattleWeightPredictionScreenState();
}

class _CattleWeightPredictionScreenState extends State<CattleWeightPredictionScreen> {
  // Form controllers
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController feedAmountController = TextEditingController();

  // Dropdown selections and mappings
  String selectedCattleBreed = 'AUSTRALIAN MILKING ZEBU';
  String selectedLactationStage = 'EARLY';
  String selectedReproductiveStatus = 'PREGNANT';

  final Map<String, int> cattleBreedMapping = {
    'AUSTRALIAN MILKING ZEBU': 1,
    'AYRSHIRE': 2,
    'FRIESIAN': 3,
    'JERSEY': 4,
    'LANKA WHITE': 5,
    'SAHIWAL': 6,
  };

  final Map<String, int> lactationStageMapping = {
    'EARLY': 0,
    'LATE': 1,
    'MID': 2,
  };

  final Map<String, int> reproductiveStatusMapping = {
    'PREGNANT': 0,
    'NOT PREGNANT': 1,
    ' PREGNANT': 2,  // Handle this format if necessary
  };

  String healthPredictionResponse = "";

  // Function to send POST request and fetch prediction
  Future<void> getWeightPrediction() async {
    final apiUrl = ENVConfig.serverUrl + '/predict-growth-weight'; // Update with your actual API endpoint

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cattle_breed': selectedCattleBreed,
          'height_cm': double.parse(heightController.text),
          'age_years': double.parse(ageController.text),
          'feed_kg_per_day': double.parse(feedAmountController.text),
          'lactation_stage': selectedLactationStage,
          'reproductive_status': selectedReproductiveStatus,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          healthPredictionResponse = 'Predicted Weight: ${data['predicted_weight']} kg';
        });
      } else {
        setState(() {
          healthPredictionResponse = 'Failed to fetch prediction';
        });
      }
    } catch (error) {
      setState(() {
        healthPredictionResponse = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cattle Weight Prediction'),
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
                      Icon(Icons.agriculture, color: Colors.teal, size: 40),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Enter details to predict cattle weight',
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
                'Cattle Breed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              DropdownButtonFormField<String>(
                value: selectedCattleBreed,
                items: cattleBreedMapping.keys.map((String breed) {
                  return DropdownMenuItem<String>(
                    value: breed,
                    child: Text(
                      breed,
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCattleBreed = newValue!;
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
                'Lactation Stage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              DropdownButtonFormField<String>(
                value: selectedLactationStage,
                items: lactationStageMapping.keys.map((String stage) {
                  return DropdownMenuItem<String>(
                    value: stage,
                    child: Text(
                      stage,
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLactationStage = newValue!;
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
                'Height (cm)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              TextField(
                controller: heightController,
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
                'Age (Years)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              TextField(
                controller: ageController,
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
                'Feed Amount (kg/day)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              TextField(
                controller: feedAmountController,
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

              ElevatedButton(
                onPressed: getWeightPrediction,
                child: Text(
                  'Predict Weight',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.bgColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Display health prediction response
              Text(
                healthPredictionResponse,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
