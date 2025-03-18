import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/navigations/milk_records_screen.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FullViewScreen extends StatefulWidget {
  final String username;

  FullViewScreen({required this.username});

  @override
  _FullViewScreenState createState() => _FullViewScreenState();
}

class _FullViewScreenState extends State<FullViewScreen> {
  List<Map<String, dynamic>> milkRecords = [];
  List<double> totalMilkByDate = [];
  List<String> dates = [];

  @override
  void initState() {
    super.initState();
    _fetchMilkRecords();
  }

  Future<void> _fetchMilkRecords() async {
    DateTime currentDate = DateTime.now();
    List<String> dateList = [];
    for (int i = 0; i < 10; i++) {
      print(i);
      dateList.add(DateFormat('yyyy-MM-dd').format(currentDate.subtract(Duration(days: i))));
    }

    print(dateList);

    // Fetch data for the past 10 days
    List<double> totalMilkList = [];
    for (String date in dateList) {
      var response = await http.get(
        Uri.parse(ENVConfig.serverUrl+'/milk_collection/${widget.username}/by_date/$date'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        double totalMilk = 0;
        if (data['milk_records'] != null) {
          for (var record in data['milk_records']) {
            totalMilk += record['amount'].toDouble();
          }
          print(totalMilk);
        }
        totalMilkList.add(totalMilk);
      }
    }

    setState(() {
      dates = dateList;
      totalMilkByDate = totalMilkList;
    });
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
            title: 'Milk Records Summary (Full)',
            content: 'Add Milk records and observe previous results',
          ),
        ),
      ),
      body: Center(
        child: totalMilkByDate.isEmpty
            ? CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
          child: Container(
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Styles.secondaryAccent, // Set the background color (if needed)
              borderRadius: BorderRadius.circular(12.0), // Set the round border radius
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Add shadow if needed
                  blurRadius: 4.0,
                  offset: Offset(0, 2), // Shadow position
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: List.generate(
                  totalMilkByDate.length,
                      (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: totalMilkByDate[index],
                          color: Colors.green,
                        ),
                      ],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Disable left-side titles
                  ),
                  rightTitles: AxisTitles( // Enable right-side titles
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            value.toInt().toString(), // Display the Y-axis value
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 && value.toInt() < dates.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Transform.rotate(
                              angle: -0.8108, // Rotate the text 90 degrees (π/2 radians)
                              child: Text(
                                dates[value.toInt()],
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MilkRecordsScreen()),
          );
        },
        child: Icon(Icons.water),
        backgroundColor: Colors.green,
      ),
    );
  }
}