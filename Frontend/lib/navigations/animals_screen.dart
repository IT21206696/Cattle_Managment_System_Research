import 'package:chat_app/constants/env.dart';
import 'package:chat_app/navigations/animal_form_screen.dart';
import 'package:chat_app/navigations/animal_summary_screen.dart';
import 'package:chat_app/navigations/breed_comparison_screen.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimalsSummaryScreen extends StatefulWidget {
  const AnimalsSummaryScreen({super.key});

  @override
  State<AnimalsSummaryScreen> createState() => _AnimalsSummaryScreenState();
}

class _AnimalsSummaryScreenState extends State<AnimalsSummaryScreen> {
  List<Map<String, dynamic>> animals = [];
  String username = 'Guest';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAnimals();
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
          animals = List<Map<String, dynamic>>.from(data['animals']);
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

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete", style: TextStyle(color: Colors.white),),
          content: const Text("Are you sure you want to delete this animal?", style: TextStyle(color: Colors.white70),),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAnimal(id);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAnimal(String id) async {
    try {
      final response = await http.delete(Uri.parse('${ENVConfig.serverUrl}/delete-animal/$id'));

      if (response.statusCode == 200) {
        setState(() {
          animals.removeWhere((animal) => animal['id'] == id);
        });
      } else {
        throw Exception('Failed to delete animal');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[800],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: const CustomCard(
                  title: 'Your Cattle Management',
                  content: 'View or add details on cattle',
                ),
              ),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : animals.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: (MediaQuery.of(context).size.height-200)/2,),
                    Text(
                      'No animals found.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AnimalFormScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Animal"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.fontDark,
                      ),
                    ),

                  ],
                ),
              )
                  : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Top Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Styles.secondaryColor,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Animal Avatar
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Styles.primaryAccent,
                                child: const Icon(Icons.pets,
                                    size: 50, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              // Add Animal Text and Button
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "You have ${animals.length} animals",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AnimalFormScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text("Add Animal"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Styles.fontDark,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BreedComparison(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.show_chart),
                                      label: const Text("Compare"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Styles.fontDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Available Animals Section
                      Text(
                        "Available Animals",
                        style: TextStyle(
                          fontSize: 15,
                          color: Styles.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Animals ListView
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: animals.length,
                        itemBuilder: (context, index) {
                          final animal = animals[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: Styles.secondaryAccent,
                            elevation: 5,
                            child: ListTile(
                              trailing: IconButton(
                                icon: const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 18,
                                  child: Icon(Icons.delete, color: Colors.white, size: 20),
                                ),
                                onPressed: () => _confirmDelete(context, animal['id']),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimalDetailsScreen(animal: animal),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                NetworkImage(animal['image']),
                                backgroundColor: Styles.primaryAccent,
                                onBackgroundImageError: (_, __) {
                                  // Fallback icon in case of an image load error
                                },
                              ),
                              title: Text(
                                animal['name'],
                                style:
                                const TextStyle(color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID: ${animal['id']}',
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                  Text(
                                    'Type: ${animal['type']}',
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                  Text(
                                    'Birthdate: ${animal['dob']}',
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                  Text(
                                    'Gender: ${animal['gender']}',
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                  Text(
                                    'Health: ${animal['health']}',
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                              // onTap: () {
                              //   // Navigate to AnimalDetailsScreen and pass the animal data
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           AnimalDetailsScreen(
                              //               animal: animal),
                              //     ),
                              //   );
                              // },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
