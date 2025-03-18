import 'dart:convert';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class BreedComparison extends StatefulWidget {
  @override
  _BreedComparisonState createState() => _BreedComparisonState();
}

class _BreedComparisonState extends State<BreedComparison> {
  String? username;
  String? selectedBreed;
  Map<String, int> breedOptions = {
    'Zebu': 1,
    'Ayrshire': 2,
    'Friesian': 3,
    'Jersey': 4,
    'Lanka White': 5,
    'Sahiwal': 6,
  };

  List<Map<String, dynamic>> milkRecords = [];

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

  Future<void> _fetchMilkRecords() async {
    if (selectedBreed == null || username == null) return;

    final String url =
        ENVConfig.serverUrl + '/milk_collection_by_names/$username/$selectedBreed';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print(data);

        // Convert List<List<dynamic>> to List<Map<String, dynamic>>
        setState(() {
          milkRecords = (data["annual_milk_collection"] as List)
              .map((record) => {"year": record[0], "amount": record[1]})
              .toList();
        });
      } else {
        setState(() {
          milkRecords = [];
        });
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Request failed: $e");
    }
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
            title: 'Breed Comparison',
            content: 'Overview of animal breeds',
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  value: selectedBreed,
                  items: breedOptions.keys
                      .map((breed) => DropdownMenuItem(
                    value: breed,
                    child: Text(
                      breed,
                      style: TextStyle(color: Colors.white),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBreed = value!;
                    });
                    _fetchMilkRecords();
                  },
                  decoration: InputDecoration(labelText: "Select Breed"),
                  style: TextStyle(color: Colors.white),
                  dropdownColor: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Annual Milk Collection",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Bar Chart
            milkRecords.isEmpty
                ? Text("No data available")
                : SizedBox(
              height: 250, // Adjust height as needed
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: milkRecords.fold<double>(0, (prev, e) => e['amount'] > prev ? e['amount'].toDouble() : prev) + 10,
                  barGroups: milkRecords
                      .map(
                        (record) => BarChartGroupData(
                      x: record['year'],
                      barRods: [
                        BarChartRodData(
                          toY: record['amount'].toDouble(),
                          color: Colors.blueAccent,
                          width: 15,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    ),
                  )
                      .toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20, // Adjust based on your data
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),

            SizedBox(height: 20),
            Expanded(
              child: milkRecords.isEmpty
                  ? Text("No data available")
                  : ListView.builder(
                itemCount: milkRecords.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text("Year: ${milkRecords[index]["year"]}"),
                      subtitle:
                      Text("Total Milk: ${milkRecords[index]["amount"]} Liters"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
