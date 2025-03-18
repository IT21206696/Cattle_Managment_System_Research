import 'dart:io';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/navigations/animals_screen.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnimalFormScreen extends StatefulWidget {
  const AnimalFormScreen({super.key});

  @override
  _AnimalFormScreenState createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _birthWeightController = TextEditingController();

  String? _gender;
  bool _milkAbility = false;
  File? _selectedImage;
  String? _predictedType;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
      await _predictBreed(File(pickedImage.path));
    }
  }

  Future<void> _predictBreed(File file) async {
    final uri = Uri.parse('${ENVConfig.serverUrl}/predict-breed');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final predictionData = json.decode(responseData);

      setState(() {
        _predictedType = predictionData['predicted_label'];
        _typeController.text = _predictedType ?? "";
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to predict breed'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/dkox7lwxe/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = 'gtnnidje'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final cloudinaryData = json.decode(responseData);
      return cloudinaryData['secure_url'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to upload image to Cloudinary'),
        backgroundColor: Colors.red,
      ));
      return null;
    }
  }

  Future<void> _submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadToCloudinary(_selectedImage!);
      }

      Navigator.of(context).pop();

      if (imageUrl == null && _selectedImage != null) {
        return;
      }

      print(prefs.getString('username'));

      final animalData = {
        "name": _nameController.text,
        "owner": prefs.getString('username')??'Guest',
        "type": _typeController.text,
        "dob": _dobController.text,
        "gender": _gender,
        "milk_ability": _milkAbility,
        "status": "Active",
        "health": "Healthy",
        "image": imageUrl,
      };

      var response = await http.post(
        Uri.parse('${ENVConfig.serverUrl}/add-animal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(animalData),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        String id = decodedResponse['animal_id'];
        double weight = double.parse(_birthWeightController.text);
        _submitGrowthRecord(context, id, _typeController.text, weight);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(decodedResponse['message']),
          backgroundColor: Colors.green,
        ));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AnimalsSummaryScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to add animal'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _submitGrowthRecord(
      BuildContext context,
      String cattle,
      String breed,
      double weight
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
          "cattle": cattle,  // Cattle ID from animal data
          "breed": breed, // Cattle breed
          "age": 0,
          "weight": weight,
          "height": 58.0,
        }),
      );


      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(responseData["message"]), backgroundColor: Colors.green),
        // );
      } else {
        throw Exception("Failed to add growth record");
      }
    } catch (e) {
      print(e);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
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
                  title: 'Cattle Form',
                  content: 'Add Cows to the System',
                ),
              ),
              Padding(padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildRoundedInputField(
                        controller: _nameController,
                        label: "Name",
                        hint: "Enter animal name",
                      ),
                      const SizedBox(height: 16),
                      _buildRoundedInputField(
                        controller: _typeController,
                        label: "Type",
                        hint: "Enter animal type (e.g., Cow, Goat)",
                      ),
                      // if (_predictedType != null) SizedBox(height: 16),
                      // if (_predictedType != null)
                      //   Text(
                      //     "Predicted Type: $_predictedType",
                      //     style: const TextStyle(color: Colors.black54, fontSize: 16),
                      //   ),
                      const SizedBox(height: 16),
                      _buildRoundedInputField(
                        controller: _dobController,
                        label: "Date of Birth",
                        hint: "Enter DOB (YYYY-MM-DD)",
                      ),
                      const SizedBox(height: 16),
                      _buildRoundedInputField(
                        controller: _birthWeightController,
                        label: "Birth Weight",
                        hint: "Enter Birth Weight",
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                        items: ['Male', 'Female']
                            .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(
                            gender,
                            style: TextStyle(color: Styles.secondaryAccent),
                          ),
                        ))
                            .toList(),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.verified_user, color: Colors.black54),
                          labelText: "Gender",
                          labelStyle: const TextStyle(color: Colors.black54),
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.successColor2),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                        ),
                        isExpanded: false,
                        validator: (value) =>
                        value == null ? "Please select a gender" : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _milkAbility,
                            onChanged: (value) {
                              setState(() {
                                _milkAbility = value!;
                              });
                            },
                          ),
                          Text(
                            "Ability to Milk",
                            style: TextStyle(color: Styles.secondaryAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: const Text("Pick Image"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.secondaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          _selectedImage != null
                              ? Image.file(
                            _selectedImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                              : Text("No image selected", style: TextStyle(color: Styles.secondaryAccent),),
                        ],
                      ),
                      SizedBox(height: 30,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: _buildButton('Add new Animal', Styles.successColor2, Colors.black87, _submitForm),

                      ),

                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRoundedInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.read_more_rounded, color: Colors.black54),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Styles.successColor2),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter $label";
        }
        return null;
      },
    );
  }
}
