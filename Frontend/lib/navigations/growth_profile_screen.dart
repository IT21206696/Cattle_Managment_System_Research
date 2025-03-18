import 'dart:convert';
import 'dart:math';

import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GrowthProfileScreen extends StatefulWidget {
  final Map<String, dynamic> animal;

  const GrowthProfileScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _GrowthProfileScreenState createState() => _GrowthProfileScreenState();
}

class _GrowthProfileScreenState extends State<GrowthProfileScreen> {
  bool isActive = false;
  int years = 0;
  int months = 0;
  int _totalMonths = 0;
  String displayAge = "";
  double predictedWeight = 0;
  double receivedHeight = 0;
  List<dynamic> growthRecords = [];
  bool isLoading = true;
  double growthRate = 0;
  double dailyGain = 0;

  Map<String, dynamic>? firstRecord;
  Map<String, dynamic>? lastRecord;
  double growthRateSub = 0;
  double dailyGainSub = 0;


  List<Map<String, dynamic>> cattleData = [
    {
      'name': 'AUSTRALIAN MILKING ZEBU',
      'id': 1,
      'avgGrowthRate': 0.75,
      'avgDailyGain': 0.45
    },
    {
      'name': 'AYRSHIRE',
      'id': 2,
      'avgGrowthRate': 0.85,
      'avgDailyGain': 0.50
    },
    {
      'name': 'FRIESIAN',
      'id': 3,
      'avgGrowthRate': 1.10,
      'avgDailyGain': 0.65
    },
    {
      'name': 'JERSEY',
      'id': 4,
      'avgGrowthRate': 0.70,
      'avgDailyGain': 0.40
    },
    {
      'name': 'LANKA WHITE',
      'id': 5,
      'avgGrowthRate': 0.65,
      'avgDailyGain': 0.38
    },
    {
      'name': 'SAHIWAL',
      'id': 6,
      'avgGrowthRate': 0.90,
      'avgDailyGain': 0.55
    },
    {
      'name': 'nan',
      'id': 7,
      'avgGrowthRate': 0.0,  // No data available
      'avgDailyGain': 0.0
    },
  ];

  List<String> lowWeightCattleAdvice = [
    "Increase Energy Intake: Provide high-quality forage, supplemented with energy-rich grains (corn, barley, sorghum).",
    "Protein Supplementation: Ensure adequate protein intake (soybean meal, alfalfa, cottonseed meal) to promote muscle growth.",
    "Balanced Diet: Include minerals (calcium, phosphorus) and vitamins (A, D, E) to enhance metabolism.",
    "Access to Fresh Water: Ensure clean and abundant water availability to improve digestion and nutrient absorption.",
    "Use Growth-Promoting Additives: Consider probiotics, yeast culture, or rumen buffers to improve feed efficiency.",
    "Deworming & Parasite Control: Internal and external parasites reduce weight gain. Regular deworming is essential.",
    "Disease Prevention: Regular vaccinations and health checkups to prevent infections and digestive issues.",
    "Reduce Stress: Minimize handling stress, ensure proper shelter, and provide comfortable living conditions.",
    "Encourage Frequent Feeding: Provide multiple small meals throughout the day to maximize intake.",
    "Monitor Weight Regularly: Track growth progress and adjust feeding programs as needed."
  ];

  String getRandomAdvice() {
    final random = Random();
    return lowWeightCattleAdvice[random.nextInt(lowWeightCattleAdvice.length)];
  }





  void _toggleStatus(bool value) {
    setState(() {
      isActive = value;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchGrowthRecords();
    DateTime dob = DateTime.parse(widget.animal['dob']);
    DateTime now = DateTime.now();
    int totalMonths = (now.year - dob.year) * 12 + (now.month - dob.month);
    years = totalMonths ~/ 12;
    months = totalMonths % 12;
    if(months==0) {
      displayAge = "$years Years";
    } else {
      displayAge = "$years Years and $months months";
    }

    setState(() {
      _totalMonths = totalMonths;
    });
  }

  String calculateAge(int month) {
    // DateTime dob = DateTime.parse(dobString);
    DateTime now = DateTime.now();

    // int totalMonths = months;
    int years = month ~/ 12;
    int months = month % 12;

    return months == 0 ? "$years Years" : "$years Years and $months Months";
  }

  Future<void> fetchGrowthRecords() async {
    final String cattleId = widget.animal['id'];
    final response = await http.get(Uri.parse(ENVConfig.serverUrl+'/growth-records/$cattleId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> records = data['growth_records']; // Ensure it's a list

      setState(() {
        growthRecords = records;
        isLoading = false;

        print(growthRecords);

        if (growthRecords.isNotEmpty) {
          firstRecord = growthRecords.first;
          lastRecord = growthRecords.last;

          double firstWeight = firstRecord!['weight'] ?? 0.0;
          double lastWeight = lastRecord!['weight'] ?? 0.0;
          int lastAge = lastRecord!['age'] ?? 1;

          String animalType = widget.animal['type'].toString().toUpperCase();
          var cattle = cattleData.firstWhere(
                (cattle) => cattle['name'] == animalType,
            orElse: () => {'avgGrowthRate': 0.0, 'avgDailyGain': 0.0},
          );


          if (lastAge > 0) {
            growthRate = ((lastWeight - firstWeight) / firstWeight);
            dailyGain = ((lastWeight - firstWeight) / (lastAge * 30));

            growthRateSub = growthRate - cattle['avgGrowthRate'];
            dailyGainSub = dailyGain - cattle['avgDailyGain'];
          } else {
            growthRate = 0.0;
          }
        } else {
          firstRecord = null;
          lastRecord = null;
          growthRate = 0.0;
        }

        print("First Record: $firstRecord");
        print("Last Record: $lastRecord");
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load growth records');
    }
  }

  List<FlSpot> _generateAvgGrowthRateData() {
    if (growthRecords.isEmpty) return [];

    String animalType = widget.animal['type'].toString().toUpperCase();
    var cattle = cattleData.firstWhere(
          (cattle) => cattle['name'] == animalType,
      orElse: () => {'avgDailyGain': 0.0},
    );

    double avgDailyGain = cattle['avgDailyGain'];
    List<FlSpot> avgGrowthSpots = [];

    for (var record in growthRecords) {
      double age = record['age'].toDouble();
      double weight = growthRecords.first['weight'] + (avgDailyGain * age * 30);
      avgGrowthSpots.add(FlSpot(age, weight));
    }

    return avgGrowthSpots;
  }



  void _submitGrowthRecord(
      BuildContext context,
      int age,
      double weight,
      double height,
      ) async {
    try {
      // Get username from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('username') ?? 'Guest';

      final response = await http.post(
        Uri.parse(ENVConfig.serverUrl+"/growth-records"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "owner": username,
          "cattle": widget.animal['id'],  // Cattle ID from animal data
          "breed": widget.animal['type'], // Cattle breed
          "age": age,
          "weight": weight,
          "height": height,
        }),
      );


      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          growthRecords = [];
        });
        fetchGrowthRecords();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"]), backgroundColor: Colors.green),
        );
      } else {
        throw Exception("Failed to add growth record");
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }


  void _openEstimateForm(BuildContext context) {
    TextEditingController heightController = TextEditingController();
    TextEditingController feedController = TextEditingController();
    String lactationStage = "EARLY";
    String reproductiveStatus = "NOT PREGNANT";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Estimate Weight", style: TextStyle(color: Colors.white),),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Cattle Breed: ${widget.animal['type']}", style: TextStyle(color: Colors.white70),),
                Text("Age (Years): $years", style: TextStyle(color: Colors.white70),),
                const SizedBox(height: 10),
                // Height Input
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Height (cm)"),
                ),
                // Feed Input
                TextField(
                  controller: feedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Feed (kg per day)"),
                ),
                const SizedBox(height: 10),
                // Lactation Stage Dropdown
                DropdownButtonFormField<String>(
                  value: lactationStage,
                  dropdownColor: Colors.black, // Background color of the dropdown menu
                  items: ["EARLY", "MID", "LATE"]
                      .map((stage) => DropdownMenuItem(
                    value: stage,
                    child: Text(
                      stage,
                      style: const TextStyle(color: Colors.white), // Option text color
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      lactationStage = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: "Lactation Stage"),
                  style: const TextStyle(color: Colors.white), // Selected item text color
                ),

                const SizedBox(height: 10),
                // Reproductive Status Dropdown
                DropdownButtonFormField<String>(
                  value: reproductiveStatus,
                  dropdownColor: Colors.black, // Background color of the dropdown menu
                  items: ["NOT PREGNANT", "PREGNANT"]
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white), // Option text color
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      reproductiveStatus = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: "Reproductive Status"),
                  style: const TextStyle(color: Colors.white), // Selected item text color
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _submitCattleData(
                  breed: widget.animal['type'],
                  height: double.tryParse(heightController.text) ?? 0.0,
                  age: years.toDouble(),
                  feed: double.tryParse(feedController.text) ?? 0.0,
                  lactationStage: lactationStage,
                  reproductiveStatus: reproductiveStatus,
                );
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // Function to submit data to the API
  Future<void> _submitCattleData({
    required String breed,
    required double height,
    required double age,
    required double feed,
    required String lactationStage,
    required String reproductiveStatus,
  }) async {
    final url = Uri.parse(ENVConfig.serverUrl+"/predict-growth-weight");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "cattle_breed": breed.toUpperCase(),
        "height_cm": height,
        "age_years": age,
        "feed_kg_per_day": feed,
        "lactation_stage": lactationStage,
        "reproductive_status": reproductiveStatus,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      setState(() {
        predictedWeight = responseData["predicted_weight"];
        receivedHeight = height;
      });
      // Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data submitted successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const CustomCard(title: 'Growth Summary', content: 'Choose options you want to visit',),
            ),
            Padding(padding: EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Styles.secondaryAccent,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Animal Image
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(widget.animal['image']),
                          backgroundColor: Colors.blueAccent,
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 16),
                        // Animal Information Summary
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.animal['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Type: ${widget.animal['type']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Age: $displayAge \n(${widget.animal['dob']})',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Gender: ${widget.animal['gender']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Health: ${widget.animal['health']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              if(predictedWeight != 0) Text(
                                'Predicted Weight: ${predictedWeight.toStringAsFixed(2)}kg',
                                style: const TextStyle(color: Colors.white70),
                              ),

                            ],
                          ),
                        ),
                        // Switch for Active/Inactive Status

                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: (){_openEstimateForm(context);},
                          icon: const Icon(Icons.add),
                          label: const Text("Get Weight"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Styles.fontDark,
                          ),
                        ),
                        if(predictedWeight != 0) ElevatedButton.icon(
                          onPressed: ()=> _submitGrowthRecord(context, _totalMonths, predictedWeight, receivedHeight),
                          icon: const Icon(Icons.add),
                          label: const Text("Record"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Styles.fontDark,
                          ),
                        ),
                      ],
                    )

                  ],
                ),

              ),
            ),),
            // const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Average Growth",
                          style: TextStyle(fontSize: 15, color: Styles.secondaryColor, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Row(children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // Rounded corners
                            ),
                            elevation: 3, // Shadow effect
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${growthRate.toStringAsFixed(2)}", // Large growth rate number
                                    style: TextStyle(
                                      fontSize: 24, // Larger font
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if(growthRateSub>0) Icon(Icons.arrow_upward, color: Colors.green, size: 10) else Icon(Icons.arrow_downward, color: Colors.red, size: 10),

                                      SizedBox(width: 5),
                                      Text(
                                        "${growthRateSub.toStringAsFixed(2)}",
                                        style: TextStyle(fontSize: 14, color: Styles.secondaryColor, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Text(
                                    "Growth Rate", // Title
                                    style: TextStyle(
                                      fontSize: 14, // Smaller font
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // Rounded corners
                            ),
                            elevation: 3, // Shadow effect
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${dailyGain.toStringAsFixed(2)}", // Large growth rate number
                                    style: TextStyle(
                                      fontSize: 24, // Larger font
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if(dailyGainSub>0) Icon(Icons.arrow_upward, color: Colors.green, size: 10) else Icon(Icons.arrow_downward, color: Colors.red, size: 10),

                                      SizedBox(width: 5),
                                      Text(
                                        "${dailyGainSub.toStringAsFixed(2)}",
                                        style: TextStyle(fontSize: 14, color: Styles.secondaryColor, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Text(
                                    "Daily Gain", // Title
                                    style: TextStyle(
                                      fontSize: 14, // Smaller font
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],),
                        SizedBox(height: 10),
                        if(growthRateSub<0)Text(getRandomAdvice(), style: TextStyle(fontSize: 12, color: Styles.secondaryAccent),),
                        if (growthRateSub < 0 || dailyGainSub < 0)
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "⚠ Recommendations for Cattle Health",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text("• Increase protein-rich feed (e.g., soybean meal, alfalfa).",
                                    style: TextStyle(fontSize: 14)),
                                Text("• Ensure adequate water intake (at least 50 liters/day).",
                                    style: TextStyle(fontSize: 14)),
                                Text("• Supplement with minerals (calcium, phosphorus, salt).",
                                    style: TextStyle(fontSize: 14)),
                                Text("• Provide vitamin supplements (A, D, E for better growth).",
                                    style: TextStyle(fontSize: 14)),
                                Text("• Use veterinary-approved weight gain syrups (e.g., Megamilk, BoviGrowth).",
                                    style: TextStyle(fontSize: 14)),
                                Text("• Conduct deworming if weight loss is significant.",
                                    style: TextStyle(fontSize: 14)),
                                Text("• Reduce stress by ensuring proper shelter and hygiene.",
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        SizedBox(height: 10),
                        Text(
                          "Growth Records",
                          style: TextStyle(fontSize: 15, color: Styles.secondaryColor, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(height: 12),
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : growthRecords.isEmpty
                            ? const Text("No records found")
                            : Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.blue.shade100),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Age", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Weight", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Height", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            for (var record in growthRecords)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${calculateAge(record['age'])}"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${record['weight'].toStringAsFixed(2)} kg"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${record['height']} cm"),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                elevation: 5,
                // color: Styles.secondaryAccent,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth Chart',
                        style: TextStyle(
                          fontSize: 15,
                          color: Styles.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 450,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              // LineChartBarData(
                              //   spots: _generateChartData(),
                              //   isCurved: true,
                              //   color: Colors.green,
                              //   barWidth: 4,
                              //   isStrokeCapRound: true,
                              //   belowBarData: BarAreaData(show: false),
                              //   dotData: FlDotData(show: true),
                              // ),

                              LineChartBarData(
                                spots: _generateAvgGrowthRateData(),
                                isCurved: true,
                                color: Colors.orange, // Changed to orange color
                                barWidth: 4,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(show: true),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                axisNameWidget: const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Weight (kg)', // Label for the left axis
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white, // White text for the axis label
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 50, // Adjust based on your data range
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(0),
                                      style: const TextStyle(fontSize: 12, color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameWidget: const Padding(
                                  padding: EdgeInsets.only(top: 0.0),
                                  child: Text(
                                    'Age (months)', // Label for the bottom axis
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white, // White text for the axis label
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 2, // Adjust based on your data range
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 12, color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(width: 1),
                                bottom: BorderSide(width: 1),
                              ),
                            ),
                            gridData: FlGridData(show: true),
                          ),
                        ),
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

  /// Generates chart data for weight (y) over age (x) based on animal type
  List<FlSpot> _generateChartData() {
    Map<String, List<double>> weightData = {
      'Zebu': [30, 50, 75, 100, 125, 150, 175, 200],
      'Jersey': [35, 60, 90, 120, 150, 180, 200, 220],
      'Sahiwal': [40, 137, 252, 323, 389, 410, 440, 450],
      'Ayrshire': [30, 55, 80, 110, 140, 170, 200, 230],
      'Local Lankan': [25, 160, 70, 95, 120, 145, 170, 200],
      'Xenod': [25, 160, 230, 270, 297, 320, 370, 400],
      'Friesian': [40, 80, 120, 160, 200, 240, 280, 300],
    };

    List<double> age = [2, 4, 6, 8, 10, 12, 14, 16]; // Age in months
    String animalType = widget.animal['type'];
    List<double> weights = weightData[animalType] ?? [0]; // Default to 0 if type is not found

    return List.generate(
      age.length,
          (index) => FlSpot(age[index], weights[index]),
    );
  }

  List<FlSpot> _generateDummyData() {
    // Replace this with dynamic data based on the widget.animal
    List<double> age = [1, 2, 3, 4, 5, 6]; // Age in months
    List<double> weight = [30, 47, 67, 79, 111, 120]; // Weight in kg
    return List.generate(age.length, (index) => FlSpot(age[index], weight[index]));
  }

}
