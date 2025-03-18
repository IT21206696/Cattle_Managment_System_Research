import 'dart:convert';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/navigations/feeding_overview_screen.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FeedingRecordsScreen extends StatefulWidget {
  @override
  _FeedingRecordsScreenState createState() => _FeedingRecordsScreenState();
}

class _FeedingRecordsScreenState extends State<FeedingRecordsScreen> {
  String username = 'Guest';
  String userid = '';
  List<Map<String, dynamic>> cattles = [];
  List<Map<String, dynamic>> filteredCattles = [];
  Set<Map<String, dynamic>> selectedCattles = {};
  TextEditingController feedAmountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime displayedDate = DateTime.now();
  List<Map<String, dynamic>> feedingRecords = [];
  bool isLoading = false;
  TextEditingController scoreController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<String> foodItems = [
    'Coconut Poonac', 'Coconut Poonac, Grass', 'Grass, Paddy Straw',
    'Napier Grass, Guinea grass', 'Napier Grass, Guinea grass, Para grass',
    'Napier Grass, Guinea grass, Gliricidia', 'Paddy Straw, Grass (Chopped)',
    'Para grass, Gliricidia', 'Milk', 'Paddy Straw', 'Paddy Straw, Corn',
    'Paddy Straw, Grass', 'Paddy Straw, Legumes'
  ];

// Meal Type and Food Item Selections
  String? selectedMealType;
  String? selectedFoodItem;
  String? selectedPlatform;

// List of available meal types
  List<String> mealTypes = ['Morning', 'Afternoon', 'Evening'];
  List<String> platfroms = ['Cement', 'Plastic', 'Plastic Bottle'];

// List to store added meals
  List<Map<String, String>> meals = [];



  @override
  void initState() {
    super.initState();
    _loadUsername().then((_) => loadAnimals());
  }

  _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
      userid = prefs.getString('username') ?? 'Guest';
    });
  }

  Future<void> loadAnimals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
    });

    try {
      final response =
      await http.get(Uri.parse('${ENVConfig.serverUrl}/animals/$username'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          cattles = List<Map<String, dynamic>>.from(data['animals']);
          filteredCattles = cattles;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load animals');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error: $error');
    }
  }

  void _filterCattles(String query) {
    setState(() {
      filteredCattles = cattles
          .where((cattle) =>
          cattle['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }


    void _submitFeedingRecord() async {
    if (selectedCattles.isEmpty || meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one cattle and add at least one meal.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Extract meal data
    Map<String, dynamic> mealData = {
      'food_type_morning': '',
      'feeding_amount_KG_morning': 0.0,
      'score_morning': 0,
      'food_type_noon': '',
      'feeding_amount_KG_noon': 0.0,
      'score_noon': 0,
      'food_type_evening': '',
      'feeding_amount_KG_evening': 0.0,
      'score_evening': 0,
    };

    for (var meal in meals) {
      if (meal['mealType'] == 'Morning') {
        mealData['food_type_morning'] = meal['foodItem'];
        mealData['feeding_amount_KG_morning'] = double.parse(meal['amount'].toString());
        mealData['score_morning'] = int.parse(meal['score'].toString());
      } else if (meal['mealType'] == 'Afternoon') {
        mealData['food_type_noon'] = meal['foodItem'];
        mealData['feeding_amount_KG_noon'] = double.parse(meal['amount'].toString());
        mealData['score_noon'] = int.parse(meal['score'].toString());
      } else if (meal['mealType'] == 'Evening') {
        mealData['food_type_evening'] = meal['foodItem'];
        mealData['feeding_amount_KG_evening'] = double.parse(meal['amount'].toString());
        mealData['score_evening'] = int.parse(meal['score'].toString());
      }
    }

    // Loop through each selected cattle and submit a request
    for (var cattle in selectedCattles) {
      Map<String, dynamic> payload = {
        'cattle_name': cattle['id'],
        'health_status': cattle['health'],
        'status': cattle['status'],
        ...mealData,
        'feed_platform': 'Cement',
        'travel_distance_per_day_KM': 1.5,
        'farmer_name': username,
        'feed_date': DateFormat('yyyy-MM-dd').format(selectedDate),
      };

      try {
        final response = await http.post(
          Uri.parse(ENVConfig.serverUrl+"/feed-patterns"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          print("Feeding record saved for cattle: ${cattle['id']}");
        } else {
          print("Failed to save record for cattle: ${cattle['id']}");
        }
      } catch (e) {
        print("Error: $e");
      }
    }

    // Show success message once all requests are sent
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Feeding records successfully saved!")),
    );

    // Reset state
    setState(() {
      isLoading = false;
      meals.clear();
      mealTypes = ['Morning', 'Afternoon', 'Evening'];
      selectedMealType = null;
      selectedFoodItem = null;
      feedAmountController.clear();
      scoreController.clear();
      selectedCattles.clear(); // Clear selected cattle
    });
  }

  Future<void> loadFeedingRecordsByDate() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(displayedDate);

    try {
      final response = await http.get(
        Uri.parse(ENVConfig.serverUrl+'/feed-patterns/$username/by_date/$formattedDate'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          feedingRecords = List<Map<String, dynamic>>.from(data['feeding_records']);
          print(feedingRecords);
        });

      } else {
        setState(() {
          feedingRecords = [];
        });
      }
    } catch (e) {
      setState(() {
        feedingRecords = [];
      });
    }
  }

  TextEditingController foodController = TextEditingController();

  void _addNewFoodItem() {
    String newFood = foodController.text.trim();
    if (newFood.isNotEmpty && !foodItems.contains(newFood)) {
      setState(() {
        foodItems.add(newFood);
        selectedFoodItem = newFood;
      });
      foodController.clear();
      Navigator.pop(context); // Close the dialog
    }
  }

  void _showAddNewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Food Item", style: TextStyle(color: Colors.white70),),
          content: TextField(
            controller: foodController,
            decoration: InputDecoration(
              hintText: "Enter food item",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without saving
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addNewFoodItem,
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green[800],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: const CustomCard(
            title: 'Feeding Records Summary',
            content: 'Add Milk records and observe previous results',
          ),
        ),
      ),
      backgroundColor: Colors.white70,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FeedingOverviewScreen(farmerId: username)),
          );
        },
        child: Icon(Icons.fullscreen), // Icon for the button
        backgroundColor: Colors.green,  // Customize the background color
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Half: Form to Enter Feeding Record
            SizedBox(
              width: double.infinity,
              child: Card(
                margin: EdgeInsets.all(20),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Enter Feeding Record',
                        style: TextStyle(color: Colors.green[800], fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      // Feed Amount Input
                      DropdownButtonFormField<String>(
                        value: selectedMealType,
                        decoration: InputDecoration(
                          labelText: "Select Meal Type",
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.green),
                        items: mealTypes.map((String meal) {
                          return DropdownMenuItem<String>(
                            value: meal,
                            child: Text(meal),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMealType = value;
                          });
                        },
                      ),

                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedFoodItem,
                        decoration: InputDecoration(
                          labelText: "Select Food Item",
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.green),
                        items: foodItems.map((String food) {
                          return DropdownMenuItem<String>(
                            value: food,
                            child: Text(food),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFoodItem = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _showAddNewDialog,
                        icon: Icon(Icons.add, color: Colors.yellow), // Icon color
                        label: Text("Add New", style: TextStyle(color: Colors.yellow)), // Text color
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.yellow, width: 2), // Yellow border
                          backgroundColor: Colors.transparent, // Transparent background
                          shadowColor: Colors.transparent, // Remove shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Rounded borders
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: feedAmountController,
                              decoration: InputDecoration(
                                labelText: 'Amount (kg)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: scoreController,
                              decoration: InputDecoration(
                                labelText: 'Score (0-6)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Colors.green),

                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      Wrap(
                        spacing: 8,
                        children: meals.map((meal) {
                          return Chip(
                            label: Text("${meal['mealType']}: ${meal['foodItem']} (${meal['amount']}kg, Score: ${meal['score']})"),
                            deleteIcon: Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                mealTypes.add(meal['mealType']??'Morning'); // Re-add meal type to dropdown options
                                meals.remove(meal);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 10,),

                      // Add Meal Button
                      ElevatedButton(
                        onPressed: () {


                          if (selectedMealType != null &&
                              selectedFoodItem != null &&
                              feedAmountController.text.isNotEmpty &&
                              scoreController.text.isNotEmpty) {
                              int? score = int.tryParse(scoreController.text);

                              if (score != null && score >= 0 && score <= 6) {
                                setState(() {
                                  meals.add({
                                    'mealType': selectedMealType ?? "Morning",
                                    'foodItem': selectedFoodItem ?? "Coconut Poonac",
                                    'amount': feedAmountController.text,
                                    'score': scoreController.text,
                                  });
                                  print(meals);

                                  // Remove selected meal type from options
                                  mealTypes.remove(selectedMealType);
                                  selectedMealType = null;
                                  selectedFoodItem = null;
                                  feedAmountController.clear();
                                  scoreController.clear();
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Score must be a number between 0 and 6!"),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text('Add Meal', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(height: 20),

                      // Select Cattle
                      Row(
                        children: [
                          Text(
                            "Select Cattle",
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10), // Spacing
                          Icon(Icons.search, color: Colors.green[800]),
                          SizedBox(width: 10), // Spacing
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: Colors.green[800]), // Typed text color
                              onChanged: _filterCattles, // Trigger filtering on text change
                              decoration: InputDecoration(
                                hintText: "Search",
                                hintStyle: TextStyle(color: Colors.green[600]),
                                filled: true,
                                fillColor: Colors.transparent, // Transparent background
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.green[800]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.green[900]!),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Cattle List (Scrollable Row)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filteredCattles.map((cattle) {
                            bool isSelected = selectedCattles.contains(cattle);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedCattles.remove(cattle); // Deselect if already selected
                                  } else {
                                    selectedCattles.add(cattle); // Select if not selected
                                  }
                                });
                              },
                              child: Card(
                                color: isSelected ? Colors.green[100] : Colors.white, // Change color when selected
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: isSelected ? 6 : 2,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(cattle['image']!),
                                        backgroundColor: Colors.grey[200],
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cattle['name']!,
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            cattle['id']!,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: selectedPlatform,
                        decoration: InputDecoration(
                          labelText: "Select Platform",
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.green),
                        items: platfroms.map((String meal) {
                          return DropdownMenuItem<String>(
                            value: meal,
                            child: Text(meal),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMealType = value;
                          });
                        },
                      ),

                      SizedBox(height: 20),

                      // Select Date
                      Text(
                        "Select Date",
                        style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null && pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd').format(selectedDate),
                                style: TextStyle(fontSize: 16, color: Colors.green[800]),
                              ),
                              Icon(Icons.calendar_today, color: Colors.green),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _submitFeedingRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Text('Add Feeding Record', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Half: Placeholder Card
            SizedBox(
              width: double.infinity,
              child: Card(
                margin: EdgeInsets.all(20),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date Selection Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_left),
                                onPressed: () {
                                  setState(() {
                                    displayedDate = displayedDate.subtract(Duration(days: 1));
                                  });
                                  loadFeedingRecordsByDate();
                                },
                              ),
                              SizedBox(width: 10),
                              Text(
                                DateFormat('yyyy-MM-dd').format(displayedDate),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Styles.secondaryAccent),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.arrow_right),
                                onPressed: displayedDate.isBefore(DateTime.now())
                                    ? () {
                                  setState(() {
                                    displayedDate = displayedDate.add(Duration(days: 1));
                                  });
                                  loadFeedingRecordsByDate();
                                }
                                    : null, // Disable if already at today's date
                              ),
                            ],
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     setState(() {
                          //       isChartView = !isChartView;
                          //     });
                          //   },
                          //   child: CircleAvatar(
                          //     backgroundColor: Styles.secondaryColor,
                          //     radius: 15,
                          //     child: Icon(
                          //       isChartView ? Icons.list : Icons.bar_chart,
                          //       size: 15,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Display Feeding Records
                      feedingRecords.isEmpty
                          ? Center(child: Text("No feeding records for this date", style: TextStyle(color: Colors.white70)))
                          : Column(
                        children: feedingRecords.map((record) {
                          return ListTile(
                            title: Text("Cattle: ${record['cattle_name']}"),
                            subtitle: Text("Morning: ${record['food_type_morning']} (${record['feeding_amount_KG_morning']}kg)\n"
                                "Noon: ${record['food_type_noon']} (${record['feeding_amount_KG_noon']}kg)\n"
                                "Evening: ${record['food_type_evening']} (${record['feeding_amount_KG_evening']}kg)"),
                            trailing: Text(record['status']),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
