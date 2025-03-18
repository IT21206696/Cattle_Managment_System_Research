import 'dart:convert';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimalMilkingHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> animal;

  const AnimalMilkingHistoryScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _AnimalMilkingHistoryScreenState createState() => _AnimalMilkingHistoryScreenState();
}

class _AnimalMilkingHistoryScreenState extends State<AnimalMilkingHistoryScreen> {
  String username = 'Guest';
  bool showChart = true;
  bool showMilkingRecord = false;
  bool isLoading = false;
  double? predictedMilk;
  List<Map<String, dynamic>> milkingRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchMilkingRecords();
    _fetchMilkPrediction();
  }

  Future<void> _fetchMilkingRecords() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
    });

    final String cattleName = widget.animal['name'];
    final String apiUrl = ENVConfig.serverUrl+"/milk_collection/${username}/$cattleName";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['milk_records']);
        setState(() {
          milkingRecords = List<Map<String, dynamic>>.from(data['milk_records']);
        });
      } else {
        throw Exception("Failed to load records");
      }
    } catch (e) {
      print("Error fetching milking records: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchMilkPrediction() async {
    final String apiUrl = "${ENVConfig.serverUrl}/predict_milk";

    // Sample data from `widget.animal`, modify as needed
    final requestBody = {
      "cattle_breed": widget.animal['type'],
      "height_cm": 168,
      "age_years": 5,
      "feed_kg_per_day": 7,
      "lactation_stage": "LATE",
      "reproductive_status": "NOT PREGNANT",
    };

    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          predictedMilk = data['predicted_milk_production'];
        });
      } else {
        throw Exception("Failed to predict milk production");
      }
    } catch (e) {
      print("Error fetching milk prediction: $e");
    }
  }

  void _toggleMilkingHistoryVisibility() {
    setState(() => showChart = !showChart);
  }

  void _toggleMilkingRecordVisibility() {
    setState(() => showMilkingRecord = !showMilkingRecord);
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
            title: 'Animal Milking Summary',
            content: 'Overview of animal milking details',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPredictionCard(),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSquareButton(
                      icon: Icons.history,
                      label: 'Milking History',
                      onTap: _toggleMilkingHistoryVisibility,
                    ),
                    _buildSquareButton(
                      icon: Icons.list,
                      label: 'Milking Records',
                      onTap: _toggleMilkingRecordVisibility,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const Center(child: CircularProgressIndicator()),

                if (!isLoading && showChart) _buildMilkingHistoryChart(),

                SizedBox(height: 10,),

                if (!isLoading && showMilkingRecord)
                  MilkingRecordTable(milkingRecords: milkingRecords),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMilkingHistoryChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, spreadRadius: 2, blurRadius: 5),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= milkingRecords.length) {
                    return const SizedBox.shrink();
                  }
                  String date = milkingRecords[value.toInt()]['date_collected'];
                  List<String> dateParts = date.split('-');
                  String formattedDate = "${dateParts[1]}-${dateParts[2]}";
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: milkingRecords.asMap().entries.map((e) {
                int index = e.key;
                double amount = double.parse(e.value['amount'].toString());
                return FlSpot(index.toDouble(), amount);
              }).toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 4,
              isStrokeCapRound: true,
            ),
            if (predictedMilk != null)
              LineChartBarData(
                spots: List.generate(milkingRecords.length, (index) =>
                    FlSpot(index.toDouble(), predictedMilk!)),
                isCurved: false,
                color: Colors.orange,
                barWidth: 2,
                dashArray: [5, 5], // Dashed line
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, spreadRadius: 2, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Predicted Milking Ability",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            predictedMilk != null ? "${predictedMilk!.toStringAsFixed(2)} liters/day" : "Loading...",
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

}

class CustomCard2 extends StatelessWidget {
  final String title;
  final String content;

  const CustomCard2({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }
}

class MilkingRecordTable extends StatelessWidget {
  final List<Map<String, dynamic>> milkingRecords;

  const MilkingRecordTable({Key? key, required this.milkingRecords}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return milkingRecords.isEmpty
        ? const Text("No records found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
        : Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, spreadRadius: 2, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Milking Records", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: Colors.grey),
            columnWidths: const {0: FractionColumnWidth(0.3)},
            children: [
              _buildTableRow(["Date", "Milk (L)", "Status"], isHeader: true),
              ...milkingRecords.map((record) => _buildTableRow([
                record["date_collected"],
                record["amount"].toString(),
                record["status"]
              ]))
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(color: isHeader ? Colors.green[100] : Colors.white),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Text(cell, textAlign: TextAlign.center, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
        );
      }).toList(),
    );
  }


}
