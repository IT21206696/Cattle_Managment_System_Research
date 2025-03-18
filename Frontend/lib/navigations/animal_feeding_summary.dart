import 'package:chat_app/constants/env.dart';
import 'package:chat_app/models/cattle_data.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:chat_app/widgets/feeding_records_table.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnimalFeedingSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> animal;

  const AnimalFeedingSummaryScreen({super.key, required this.animal});

  @override
  State<AnimalFeedingSummaryScreen> createState() =>
      _AnimalFeedingSummaryScreenState();
}

class _AnimalFeedingSummaryScreenState
    extends State<AnimalFeedingSummaryScreen> {
  bool isActive = true;
  bool showChart = false;
  bool showFeedingRecord = false;
  bool showFeedingPattern = false;
  List<CattleData> feedHistory = [];
  Map<String, String> feedingPrediction = {};
  String selectedDiet = 'Mid';
  List<Map<String, String>> feedingPatternLogs = [];

  Map<Color, String> colorMap = {
    Colors.green: "green",
    Colors.yellow: "yellow",
    Colors.orange: "orange",
    Colors.red: "red",
  };



  @override
  void initState() {
    super.initState();
    _fetchFeedingData();
    _fetchFeedingPrediction();
  }

  Future<void> _fetchFeedingData() async {
    String cattleId = widget.animal['id'];
    String url = ENVConfig.serverUrl + "/feed-patterns/$cattleId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        List<CattleData> history = (data['data'] as List)
            .map((item) => CattleData.fromJson(item))
            .toList();

        int lowMorningCount = 0;
        int lowNoonCount = 0;
        int lowEveningCount = 0;
        bool feedingAnomaly = false;
        bool criticalCondition = false;
        String reason = "";



        for (var record in history) {
          print(record.scoreMorning);
          bool lowMorning = record.scoreMorning <= 2;
          bool lowNoon = record.scoreNoon <= 2;
          bool lowEvening = record.scoreEvening <= 2;

          // Track consecutive low scores for each meal
          if (lowMorning) lowMorningCount++; else lowMorningCount = 0;
          if (lowNoon) lowNoonCount++; else lowNoonCount = 0;
          if (lowEvening) lowEveningCount++; else lowEveningCount = 0;

          if (lowMorning || lowNoon || lowEvening) {
            feedingAnomaly = true;
          }

          if (lowMorningCount >= 10 && lowNoonCount >= 10 && lowEveningCount >= 10) {
            criticalCondition = true;
          }
        }

        String anomalyStatus = "No anomaly";
        Color anomalyColor = Colors.green;

        print(lowMorningCount+ lowNoonCount+ lowEveningCount);

        if (criticalCondition) {
          anomalyStatus = "Critical - Get Veterinary Assistance!";
          anomalyColor = Colors.red;
          reason = "Severe feeding drop detected for Morning, Noon, and Evening over 10+ days.";
        } else if (lowMorningCount > 10 || lowNoonCount > 10 || lowEveningCount > 10) {
          anomalyStatus = "Get to a Vet";
          anomalyColor = Colors.orange;
          reason = "Prolonged low feeding detected for ${_getLowScoreReason(lowMorningCount, lowNoonCount, lowEveningCount)}.";
        } else if (lowMorningCount > 5 || lowNoonCount > 5 || lowEveningCount > 5) {
          anomalyStatus = "Change Feeding Pattern";
          anomalyColor = Styles.warningColor;
          reason = "Moderate feeding drop detected for ${_getLowScoreReason(lowMorningCount, lowNoonCount, lowEveningCount)}.";
        } else if (feedingAnomaly) {
          anomalyStatus = "Feeding Anomaly Detected";
          anomalyColor = Styles.warningColor;
          reason = "Irregular feeding detected for ${_getLowScoreReason(lowMorningCount, lowNoonCount, lowEveningCount)}.";
        }

        setState(() {
          feedHistory = history;
          showFeedingRecord = true;
        });

        // Display anomaly in Feeding Pattern container
        _logFeedingPattern(anomalyStatus, anomalyColor, reason);
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void _logFeedingPattern(String status, Color color, String reason) {
    feedingPatternLogs.add({
      "status": status,
      "color": color.value.toRadixString(16), // Convert Color to hex string
      "reason": reason
    });
  }

// Helper function to generate reason text
  String _getLowScoreReason(int morning, int noon, int evening) {
    List<String> reasons = [];

    if (morning > 0) reasons.add("Morning (${morning} days)");
    if (noon > 0) reasons.add("Afternoon (${noon} days)");
    if (evening > 0) reasons.add("Evening (${evening} days)");

    return reasons.join(", ");
  }

  Future<void> _fetchFeedingPrediction() async {
    String breed = widget.animal['type'];
    String health = widget.animal['health'] == 'Healthy' ? 'Healthy' : 'Sick';
    String status = widget.animal['status'];

    double feedingAmount = selectedDiet == 'Large'
        ? 15
        : selectedDiet == 'Mid'
        ? 7.5
        : 3;

    Map<String, dynamic> requestBody = {
      "cattle_breed": breed,
      "health_status": health,
      "status": status,
      "feeding_amount_KG_morning": feedingAmount,
      "score_morning": 4.5,
      "feeding_amount_KG_noon": feedingAmount,
      "score_noon": 4.5,
      "feeding_amount_KG_evening": feedingAmount,
      "score_evening": 4.5,
      "travel_distance_per_day_KM": 10
    };

    try {
      final response = await http.post(
        Uri.parse(ENVConfig.serverUrl + "/predict_food_type"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          feedingPrediction = {
            'morning': data['morning'],
            'noon': data['noon'],
            'evening': data['evening'],
          };
        });
      } else {
        throw Exception("Failed to fetch prediction");
      }
    } catch (error) {
      print("Error fetching prediction: $error");
    }
  }

  void _updateDiet(String value) {
    setState(() {
      selectedDiet = value;
    });
    _fetchFeedingPrediction();
  }

  void _toggleStatus(bool value) {
    setState(() {
      isActive = value;
    });
  }

  void _toggleChartVisibility() {
    setState(() {
      showChart = !showChart;
      showFeedingRecord = false;
      showFeedingPattern = false;
    });
  }

  void _toggleFeedingRecordVisibility() {
    setState(() {
      showFeedingRecord = !showFeedingRecord;
      showChart = false;
      showFeedingPattern = false;
    });
  }

  void _toggleFeedingPatternVisibility() {
    setState(() {
      showFeedingPattern = !showFeedingPattern;
      showChart = false;
      showFeedingRecord = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            title: 'Animal Feeding Summary',
            content: 'Overview of animal feeding details',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (feedingPrediction.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, spreadRadius: 2, blurRadius: 5),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Effective Feeding Pattern",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70
                            ),
                          ),
                          SizedBox(height: 10),
                          DropdownButton<String>(
                            value: selectedDiet,
                            dropdownColor: Colors.black87,
                            icon: Icon(Icons.arrow_drop_down, color: Colors.green),
                            style: TextStyle(color: Colors.green, fontSize: 16),
                            underline: Container(height: 2, color: Colors.green),
                            items: ['Large', 'Mid', 'Low']
                                .map<DropdownMenuItem<String>>(
                                    (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                                .toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _updateDiet(newValue);
                              }
                            },
                          ),
                          SizedBox(height: 10),
                          Text("Morning: ${feedingPrediction['morning']}", style: TextStyle(color: Colors.green),),
                          Text("Noon: ${feedingPrediction['noon']}", style: TextStyle(color: Colors.green),),
                          Text("Evening: ${feedingPrediction['evening']}", style: TextStyle(color: Colors.green),),
                          SizedBox(height: 10,),
                          SizedBox(height: 10),
                          ...feedingPatternLogs.map((log) => Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.symmetric(vertical: 4),

                            decoration: BoxDecoration(
                              // color: Color(int.parse(log["color"]!, radix: 16)),
                              border: Border.all(color: Color(int.parse(log["color"]!, radix: 16)), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${log["status"]}'??'',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text('${log["reason"]}', style: TextStyle(fontSize: 12, color: Color(int.parse(log["color"]!, radix: 16))),)
                              ],
                            )
                          )),

                        ],
                      ),
                    ),
                  ),
                // Action Buttons Row
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Add Feeding Record Button
                    _buildSquareButton(
                      icon: Icons.add,
                      label: 'Feeding Record',
                      onTap: _toggleFeedingRecordVisibility,
                    ),
                    // Enter New Feeding Pattern Button
                    _buildSquareButton(
                      icon: Icons.edit,
                      label: 'Last Day Summary',
                      onTap: _toggleFeedingPatternVisibility,
                    ),
                    // Feeding History Button
                    _buildSquareButton(
                      icon: Icons.history,
                      label: 'Feeding History',
                      onTap: _toggleChartVisibility,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Show chart when "Feeding History" is clicked
                if (showChart) _buildFeedingHistoryChart(),
                if (showChart) _buildFeedingHistoryBarChart(),
                if (showFeedingRecord)
                  FeedingRecordTable(
                    animal: widget.animal,
                    feedHistory: feedHistory,
                  ),
                // Show feeding patterns when "Feeding Pattern" is clicked
                if (showFeedingPattern) _buildFeedingSummaryPieChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to build square-shaped buttons
  Widget _buildSquareButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Icon(
              icon, color: Colors.white, size: 30
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Feeding History Chart
  Widget _buildFeedingHistoryChart() {
    if (feedHistory.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    // Limit to the first 7 records
    List<CattleData> limitedFeedHistory = feedHistory.take(7).toList();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // Adjust for rotated labels
                getTitlesWidget: (value, _) {
                  int index = value.toInt();
                  return (index >= 0 && index < limitedFeedHistory.length)
                      ? Transform.rotate(
                    angle: -0.5, // Rotate labels to avoid overlap
                    child: Text(
                      limitedFeedHistory[index].feedDate,
                      style: TextStyle(fontSize: 10),
                    ),
                  )
                      : SizedBox.shrink();
                },
              ),
            ),
          ),
          lineBarsData: [
            _buildLineChartBar(limitedFeedHistory, (c) => c.scoreMorning.toDouble(), Colors.yellow),
            _buildLineChartBar(limitedFeedHistory, (c) => c.scoreNoon.toDouble(), Colors.blue),
            _buildLineChartBar(limitedFeedHistory, (c) => c.scoreEvening.toDouble(), Colors.green),
          ],
        ),
      ),
    );
  }


  LineChartBarData _buildLineChartBar(
      List<CattleData> data, double Function(CattleData) valueGetter, Color color) {
    return LineChartBarData(
      spots: data.asMap().entries.map(
            (entry) => FlSpot(entry.key.toDouble(), valueGetter(entry.value)),
      ).toList(),
      isCurved: true,
      color: color,
      dotData: const FlDotData(show: false),
    );
  }

  Widget _buildFeedingHistoryBarChart() {
    if (feedHistory.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    // Limit to the first 7 records
    List<CattleData> limitedFeedHistory = feedHistory.take(7).toList();

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: _buildBarGroups(limitedFeedHistory),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // Adjust for rotated labels
                    getTitlesWidget: (value, _) {
                      int index = value.toInt();
                      return (index >= 0 && index < limitedFeedHistory.length)
                          ? Transform.rotate(
                        angle: -0.5, // Rotate labels to avoid overlap
                        child: Text(
                          limitedFeedHistory[index].feedDate,
                          style: TextStyle(fontSize: 10),
                        ),
                      )
                          : SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildLegend(), // Add legend below the chart
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<CattleData> data) {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      CattleData cattleData = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: cattleData.scoreMorning.toDouble(),
            color: Colors.yellow,
            width: 8,
          ),
          BarChartRodData(
            toY: cattleData.scoreNoon.toDouble(),
            color: Colors.blue,
            width: 8,
          ),
          BarChartRodData(
            toY: cattleData.scoreEvening.toDouble(),
            color: Colors.green,
            width: 8,
          ),
        ],
        barsSpace: 4, // Adjust spacing between bars
      );
    }).toList();
  }

  Widget _buildFeedingSummaryPieChart() {
    if (feedHistory.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    // Use the first record only
    CattleData firstRecord = feedHistory.first;

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 60, // Makes it a donut chart
              sections: _buildPieChartSections(firstRecord),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildLegend(), // Add legend below the pie chart
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(CattleData data) {
    return [
      PieChartSectionData(
        value: data.feedingAmountKgMorning.toDouble(),
        color: Colors.yellow,
        title: "${data.feedingAmountKgMorning} Kg",
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: data.feedingAmountKgNoon.toDouble(),
        color: Colors.blue,
        title: "${data.feedingAmountKgNoon} Kg",
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: data.feedingAmountKgEvening.toDouble(),
        color: Colors.green,
        title: "${data.feedingAmountKgEvening} Kg",
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ];
  }

// Function to build the legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.yellow, "Morning"),
        const SizedBox(width: 10),
        _buildLegendItem(Colors.blue, "Noon"),
        const SizedBox(width: 10),
        _buildLegendItem(Colors.green, "Evening"),
      ],
    );
  }

// Helper function to create a single legend item
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}


