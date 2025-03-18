import 'package:chat_app/constants/env.dart';
import 'package:chat_app/models/cattle_data.dart';
import 'package:chat_app/widgets/add_feeding_record.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedingRecordTable extends StatefulWidget {
  final Map<String, dynamic> animal;
  final List<CattleData> feedHistory; // Receive feed history from the previous screen

  const FeedingRecordTable({
    super.key,
    required this.animal,
    required this.feedHistory,
  });

  @override
  State<FeedingRecordTable> createState() => _FeedingRecordTableState();
}

class _FeedingRecordTableState extends State<FeedingRecordTable> {
  late List<CattleData> feedingData;

  @override
  void initState() {
    super.initState();
    feedingData = widget.feedHistory; // Initialize with passed feed history
  }

  void _openAddRecordForm() {
    showDialog(
      context: context,
      builder: (context) {
        return AddFeedingRecordPopup(
          onSubmit: _handleFormSubmit,
          animal: widget.animal,
        );
      },
    );
  }

  Future<void> _handleFormSubmit(Map<String, dynamic> data) async {
    const url = ENVConfig.serverUrl + "/feed-patterns";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        setState(() {
          feedingData.add(CattleData.fromJson(data)); // Convert and add new data
        });
      } else {
        throw Exception('Failed to submit data: ${response.body}');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Styles.secondaryAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Feeding Records",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black54),
                onPressed: _openAddRecordForm,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 400,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(color: Colors.white, width: 1),
                columns: const [
                  DataColumn(label: Text('Cattle Name', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Health Status', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Status', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Morning Food', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Morning Amount (KG)', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Morning Score', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Noon Food', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Noon Amount (KG)', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Noon Score', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Evening Food', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Evening Amount (KG)', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Evening Score', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Feed Platform', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Distance (KM)', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Farmer Name', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Feed Date', style: TextStyle(color: Colors.white))),
                ],
                rows: feedingData.map((data) {
                  return DataRow(cells: [
                    DataCell(Text(data.id, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.healthStatus, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.status, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.foodTypeMorning, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.feedingAmountKgMorning.toString(), style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.scoreMorning.toString(), style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.foodTypeNoon, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.feedingAmountKgNoon.toString(), style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.scoreNoon.toString(), style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.foodTypeEvening, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.feedingAmountKgEvening.toString(), style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.scoreEvening.toString(), style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.feedPlatform, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.travelDistancePerDayKm.toString(), style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.farmerName, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(data.feedDate, style: const TextStyle(color: Colors.white))),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
