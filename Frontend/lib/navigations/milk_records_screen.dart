import 'dart:convert';

import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/navigations/milk_full_view_screen.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class MilkRecordsScreen extends StatefulWidget {
  @override
  _MilkRecordsScreenState createState() => _MilkRecordsScreenState();
}

class _MilkRecordsScreenState extends State<MilkRecordsScreen> {
  String username = 'Guest';
  List<Map<String, dynamic>> cattles = [];
  Map<String, dynamic>? selectedCattle;
  TextEditingController amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  DateTime displayedDate = DateTime.now();
  List<Map<String, dynamic>> milkRecords = [];
  bool isChartView = false;

  Future<void> loadMilkRecordsByDate() async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(displayedDate);
      final response = await http.get(
        Uri.parse('${ENVConfig.serverUrl}/milk_collection/$username/by_date/$formattedDate'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          milkRecords = List<Map<String, dynamic>>.from(data['milk_records']);
        });
      } else {
        throw Exception('Failed to load milk records');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsername().then((_) => loadMilkRecordsByDate());
    loadAnimals();
  }

  _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
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
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load animals');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle errors (e.g., show a message)
      print('Error: $error');
    }
  }

  _submitMilkRecord() async {
    if (selectedCattle == null || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Prepare data for the milk record submission
    var milkRecord = {
      'date_collected': DateFormat('yyyy-MM-dd').format(selectedDate),
      'cattle': selectedCattle!['name'],
      'amount': double.parse(amountController.text),
      'status': 'no issue',
    };

    try {
      final response = await http.post(
        Uri.parse('${ENVConfig.serverUrl}/milk_collection/$username'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(milkRecord),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Milk collection record added successfully")),
        );

        // Reset form
        setState(() {
          amountController.clear();
          selectedCattle = null;
          selectedDate = DateTime.now();
        });
      } else {
        throw Exception('Failed to submit record');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting record: $error")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
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
            title: 'Milk Records Summary',
            content: 'Add Milk records and observe previous results',
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FullViewScreen(username: username)),
          );
        },
        child: Icon(Icons.fullscreen), // Icon for the button
        backgroundColor: Colors.green,  // Customize the background color
      ),
      backgroundColor: Colors.white70,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Half: Form to Enter Milk Record
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
                        'Enter Milk Collection Record',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount (liters)',
                          border: OutlineInputBorder(),

                        ),

                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.green),
                      ),
                      SizedBox(height: 20),
                      Text("Select Cattle", style: TextStyle(color: Colors.white70),),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: cattles.where((cattle) => cattle['gender'] == "Female").map((cattle) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCattle = cattle;
                                });
                              },
                              child: Card(
                                color: selectedCattle == cattle ? Colors.green[100] : Colors.white,
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: selectedCattle == cattle ? 6 : 2,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(cattle['image']), // Cattle image
                                        backgroundColor: Colors.grey[200],
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cattle['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            cattle['id'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
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
                      Text(
                        "Select Date",
                        style: TextStyle(color: Colors.white70),
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
                                DateFormat('yyyy-MM-dd').format(selectedDate), // Display selected date
                                style: TextStyle(fontSize: 16, color: Styles.secondaryAccent),
                              ),
                              Icon(Icons.calendar_today, color: Colors.green),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitMilkRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Styles.secondaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Text('Add Milk Reecord'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Half: Chart
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
                                  loadMilkRecordsByDate();
                                },
                              ),
                              SizedBox(width: 10,),
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
                                  loadMilkRecordsByDate();
                                }
                                    : null, // Disable if already at today's date
                              ),

                            ],
                          ),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isChartView = !isChartView;
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: Styles.secondaryColor,
                              radius: 15,
                              child: Icon(
                                isChartView ? Icons.list : Icons.bar_chart,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        ],
                      ),
                      SizedBox(height: 10),
                      // Display Milk Records
                      isChartView
                          ? milkRecords.isEmpty
                          ? Center(child: Text("No milk records for this date", style: TextStyle(color: Colors.white70),))
                          : Container(
                        height: 300,
                        padding: EdgeInsets.all(10),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: milkRecords.map((record) {
                              return BarChartGroupData(
                                x: milkRecords.indexOf(record),
                                barRods: [
                                  BarChartRodData(
                                    toY: record['amount'].toDouble(),
                                    color: Colors.green,
                                  ),
                                ],
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    if (value.toInt() >= 0 && value.toInt() < milkRecords.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          milkRecords[value.toInt()]['cattle'],
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Styles.secondaryAccent),
                                        ),
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                            ),

                          ),
                        ),
                      )
                          : milkRecords.isEmpty
                          ? Center(child: Text("No milk records for this date", style: TextStyle(color: Colors.white70),))
                          : Column(
                        children: milkRecords.map((record) {
                          return ListTile(
                            title: Text("Cattle: ${record['cattle']}"),
                            subtitle: Text("Amount: ${record['amount']} liters"),
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

