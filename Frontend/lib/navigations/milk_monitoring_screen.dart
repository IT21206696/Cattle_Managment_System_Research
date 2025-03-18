import 'package:chat_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MilkMonitoringScreen extends StatefulWidget {
  @override
  _MilkMonitoringScreenState createState() => _MilkMonitoringScreenState();
}

class _MilkMonitoringScreenState extends State<MilkMonitoringScreen> {
  final List<Map<String, dynamic>> _milkData = [];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  void _showAddMilkDataForm() {
    final TextEditingController litersController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Milk Data", style: TextStyle(color: Colors.white70),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: litersController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white), // Set text color to white
                decoration: InputDecoration(
                  labelText: "Milk Liters Gathered",
                  labelStyle: TextStyle(color: Colors.white), // Set label color to white
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Outline border color when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // Outline border color when focused
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Date: ${_dateFormat.format(selectedDate)}", style: TextStyle(color: Colors.white70),),
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text("Select Date", style: TextStyle(color: Colors.white70),),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final liters = double.tryParse(litersController.text);
                if (liters != null && liters > 0) {
                  setState(() {
                    _milkData.add({
                      "date": selectedDate,
                      "liters": liters,
                    });
                    _milkData.sort((a, b) => a["date"].compareTo(b["date"]));
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Enter a valid amount of milk!")),
                  );
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  List<FlSpot> _generateChartData() {
    return _milkData.asMap().entries.map((entry) {
      int index = entry.key;
      double liters = entry.value["liters"];
      return FlSpot(index.toDouble(), liters);
    }).toList();
  }

  List<FlSpot> _generatePredictiveData() {
    if (_milkData.isEmpty) return [];

    final lastIndex = _milkData.length - 1;
    final double lastValue = _milkData[lastIndex]["liters"];
    final double averageChange = lastIndex > 0
        ? (_milkData[lastIndex]["liters"] - _milkData[0]["liters"]) / lastIndex
        : 0;

    return List.generate(5, (index) {
      return FlSpot((lastIndex + index + 1).toDouble(),
          lastValue + averageChange * (index + 1));
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Milk Monitoring"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Styles.fontHighlight,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _milkData.isEmpty
                  ? Center(
                child: Text(
                  "No data available. Add milk data to see the chart.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : LineChart(
                LineChartData(
                  minX: 0,
                  maxX: _milkData.length.toDouble() + 4,
                  minY: 0,
                  maxY: _milkData.map((data) => data["liters"] as double).reduce((a, b) => a > b ? a : b) + 20,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _milkData.length) {
                            return Text(
                              _dateFormat.format(
                                  _milkData[value.toInt()]["date"]),
                              style: TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 40,
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10),
                        ),
                        interval: 10,
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      spots: _generateChartData(),
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.yellow,
                      barWidth: 2,
                      spots: _generatePredictiveData(),
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 10,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 5),
                    Text("Recorded Milk Collection"),
                  ],
                ),
                SizedBox(width: 20),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 10,
                      color: Colors.yellow,
                    ),
                    SizedBox(width: 5),
                    Text("Predicted Milk Collection"),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddMilkDataForm,
              child: Text("Add Milk Data"),
            ),
          ],
        ),
      ),
    );
  }

}
