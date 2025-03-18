import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeedingStatsScreen extends StatefulWidget {
  @override
  _FeedingStatsScreenState createState() => _FeedingStatsScreenState();
}

class _FeedingStatsScreenState extends State<FeedingStatsScreen> {
  bool isLoading = false;
  List<dynamic> popularFoods = [];
  Map<String, dynamic> mostScoredFood = {};

  Future<void> _loadFeedingStats() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? farmerId = prefs.getString('username');
      final response = await http.get(Uri.parse(
          ENVConfig.serverUrl + "/feed-patterns/farmer/$farmerId/last-30-days"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          popularFoods = data["statistics"]["popular_foods"];
          mostScoredFood = data["statistics"]["most_scored_food"];
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFeedingStats();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // backgroundColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (popularFoods.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _generatePieSections(),
                        centerSpaceRadius: 50,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _generateLegends(),
                  ),
                ],
              ),
            if (popularFoods.isEmpty)
              const Center(child: Text("No data available.")),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Popular Foods (Last 30 Days)",
                style: TextStyle(
                    fontSize: 12,
                    color: Styles.secondaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Popular Food Item for Each Meal',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Styles.secondaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFoodCard("Morning", mostScoredFood["morning"] ?? ""),
                _buildFoodCard("Noon", mostScoredFood["noon"] ?? ""),
                _buildFoodCard("Evening", mostScoredFood["evening"] ?? ""),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(String timeOfDay, String food) {
    return Card(
      elevation: 3,
      color: Styles.secondaryAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(timeOfDay, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(food, style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
    );
  }


  List<PieChartSectionData> _generatePieSections() {
    final List<Color> colors = [
      Color(0xFF145D34),
      Color(0xFF20814B),
      Color(0xFF3EAA6D),
      Color(0xFF57A178),
      Color(0xFF76AF8E),
      Color(0xFF8FBDA4),
      Color(0xFFBDCCC3),
    ];

    return popularFoods.asMap().entries.map((entry) {
      String truncatedLabel = entry.value["food_type"].length > 10
          ? "${entry.value["food_type"].substring(0, 10)}.."
          : entry.value["food_type"];
      return PieChartSectionData(
        color: colors[entry.key % colors.length],
        value: entry.value["percentage"].toDouble(),
        title: "${entry.value["percentage"].toStringAsFixed(1)}%",
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<Widget> _generateLegends() {
    final List<Color> colors = [
      Color(0xFF145D34),
      Color(0xFF20814B),
      Color(0xFF3EAA6D),
      Color(0xFF57A178),
      Color(0xFF76AF8E),
      Color(0xFF8FBDA4),
      Color(0xFFBDCCC3),
    ];

    return popularFoods.asMap().entries.map((entry) {
      String truncatedLabel = entry.value["food_type"].length > 10
          ? "${entry.value["food_type"].substring(0, 10)}.."
          : entry.value["food_type"];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[entry.key % colors.length],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              truncatedLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }
}
