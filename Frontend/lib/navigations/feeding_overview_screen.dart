import 'package:chat_app/navigations/feeding_stats_screen.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/widgets/add_feeding_record.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedingOverviewScreen extends StatefulWidget {
  final String farmerId;

  const FeedingOverviewScreen({super.key, required this.farmerId});

  @override
  State<FeedingOverviewScreen> createState() => _FeedingOverviewScreenState();
}

class _FeedingOverviewScreenState extends State<FeedingOverviewScreen> {
  bool isTableView = true;
  bool isExpanded = false;
  List<Map<String, dynamic>> feedingData = [];
  List<Map<String, dynamic>> allData = [];
  TextEditingController cattleIdController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  String? selectedBreed;
  String? selectedFarm;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchFeedingData();
  }

  Future<void> _fetchFeedingData() async {
    final url = '${ENVConfig.serverUrl}/feed-patterns/farmer/${widget.farmerId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          feedingData = List<Map<String, dynamic>>.from(data['data']);
          allData = List<Map<String, dynamic>>.from(data['data']);
          print(feedingData);
        });
      } else {
        throw Exception('Failed to load feeding data');
      }
    } catch (e) {
      print("Error fetching feeding data: $e");
    }
  }



  void _filterFeedingData() async {
    // Reset feeding data by fetching fresh data from the server
    feedingData = allData;

    setState(() {
      String cattleId = cattleIdController.text.trim().toLowerCase();
      String date = dateController.text.trim();

      feedingData = feedingData.where((data) {
        bool matchesCattleId = cattleId.isEmpty || data['cattle_name'].toString().toLowerCase().contains(cattleId);
        bool matchesDate = date.isEmpty || data['feed_date'].toString().contains(date);
        bool matchesBreed = selectedBreed == null || data['type'].toString().toLowerCase() == selectedBreed!.toLowerCase();
        bool matchesStatus = selectedStatus == null || data['status'].toString().toLowerCase() == selectedStatus!.toLowerCase();

        return matchesCattleId && matchesDate && matchesBreed && matchesStatus;
      }).toList();
    });
  }


  void _toggleView() {
    setState(() {
      isTableView = !isTableView;
    });
  }

  void _openAddRecordForm() {
    showDialog(
      context: context,
      builder: (context) {
        return AddFeedingRecordPopup(
          onSubmit: _handleFormSubmit,
          animal: {},
        );
      },
    );
  }

  Future<void> _handleFormSubmit(Map<String, dynamic> data) async {
    const url = '${ENVConfig.serverUrl}/feed-patterns';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        setState(() {
          feedingData.add(data);
        });
      } else {
        throw Exception('Failed to submit data');
      }
    } catch (e) {
      print("Error submitting data: $e");
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
            title: 'Feeding Overview',
            content: 'Previous feeding details',
          ),
        ),
      ),
      backgroundColor: Colors.white70,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isTableView ? _buildTableView() : _buildStatsView(),
      ),
    );
  }

  Widget _buildTableView() {
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
              Text(
                'Feeding Records',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      isTableView ? Icons.bubble_chart : Icons.table_chart,
                      color: Colors.black,
                    ),
                    onPressed: _toggleView,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Logo & Cattle ID Search Field
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // const Text(
              //   "Cowherd",
              //   style: TextStyle(
              //     fontSize: 22,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.orange,
              //   ),
              // ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: TextField(
                    controller: cattleIdController,
                    decoration: InputDecoration(
                      hintText: "Cattle ID",
                      fillColor: Colors.yellow,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Search Filters (Shown when expanded)
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Cattle Breed Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedBreed,
                          decoration: const InputDecoration(
                            labelText: "Cattle Breed",
                            filled: true,
                            fillColor: Colors.black54,
                          ),
                          style: TextStyle(color: Colors.green), // Set the text color to green
                          items: ['Zebu', 'Ayrshire', 'Friesian', 'Jersey', 'Lanka White', 'Sahiwal']
                              .map((String breed) {
                            return DropdownMenuItem(value: breed, child: Text(breed));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedBreed = value;
                            });
                          },
                        ),
                      ),


                      const SizedBox(width: 10),

                      // Date Picker Field
                      Expanded(
                        child: TextField(
                          controller: dateController,
                          readOnly: true,
                          style: TextStyle(color: Colors.green),
                          decoration: InputDecoration(
                            labelText: "Date",
                            fillColor: Colors.black54,
                            filled: true,
                            // Ensure the fillColor is applied
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Cattle Name Field
                      // Expanded(
                      //   child: TextField(
                      //     decoration: const InputDecoration(labelText: "Cattle Name"),
                      //   ),
                      // ),

                      // const SizedBox(width: 10),

                      // Status Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: "Status",
                            filled: true,
                            fillColor: Colors.black54,
                          ),
                          style: TextStyle(color: Colors.green), // Text color for selected value
                          items: ['Pregnant', 'Active', 'Inactive', 'Lactating', 'Heifers', 'Breeding', 'Bulls', 'Calves']
                              .map((String status) {
                            return DropdownMenuItem(value: status, child: Text(status));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Search Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        onPressed: () {
                          _filterFeedingData();
                        },
                        child: const Text("Search"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 10,),
          SizedBox(
            height: 500,
            width: double.infinity,  // Ensure it takes full width
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 20, // Adjust spacing for better readability
                  border: TableBorder.all(color: Colors.white, width: 1),
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(color: Colors.white))),
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
                  ],
                  rows: feedingData.map((data) {
                    return DataRow(cells: [
                      DataCell(Text(data['feed_date'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['cattle_name'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['health_status'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['status'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['food_type_morning'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['feeding_amount_KG_morning'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['score_morning'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['food_type_noon'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['feeding_amount_KG_noon'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['score_noon'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['food_type_evening'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['feeding_amount_KG_evening'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['score_evening'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['feed_platform'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['travel_distance_per_day_KM'].toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(data['farmer_name'].toString(), style: const TextStyle(color: Colors.white))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsView() {
    return Container(
      padding: const EdgeInsets.all(16),
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Feeding Statistics',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Styles.secondaryColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      isTableView ? Icons.bubble_chart : Icons.table_chart,
                      color: Colors.black,
                    ),
                    onPressed: _toggleView,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Wrap FeedingStatsScreen in a SizedBox with fixed height
          SizedBox(
            height: MediaQuery.of(context).size.height-250, // Adjust as needed
            child: FeedingStatsScreen(),
          ),
        ],
      ),
    );
  }


}
