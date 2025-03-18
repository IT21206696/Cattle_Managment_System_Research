import 'dart:convert';
import 'dart:io';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PestInspectionScreen extends StatefulWidget {
  @override
  _PestInspectionScreenState createState() => _PestInspectionScreenState();
}

class _PestInspectionScreenState extends State<PestInspectionScreen> {
  File? _image;
  String _predictedLabel = "";

  final ImagePicker _picker = ImagePicker();

  // Remedies for each predicted label
  final Map<String, List<String>> remedies = {
    'Mastitis': [
      'Regularly clean and sanitize the udder.',
      'Administer prescribed antibiotics.',
      'Use anti-inflammatory drugs as recommended by a veterinarian.'
    ],
    'Tick Infestation': [
      'Apply tick repellents or acaricides.',
      'Ensure proper grooming and cleaning of animals.',
      'Consult a veterinarian for systemic treatments if severe.'
    ],
    'Dermatophytosis (RINGWORM)': [
      'Apply antifungal creams or sprays.',
      'Keep the infected area dry and clean.',
      'Avoid sharing grooming tools between animals.'
    ],
    'Fly Strike (MYIASIS)': [
      'Clean wounds promptly to avoid attracting flies.',
      'Apply fly repellents to the animal’s coat.',
      'Seek veterinary treatment for severe infestations.'
    ],
    'Foot and Mouth Disease': [
      'Isolate infected animals to prevent spreading.',
      'Vaccinate animals regularly.',
      'Provide supportive care such as soft feed and hydration.'
    ],
    'Lumpy Skin': [
      'Vaccinate animals against Lumpy Skin Disease (LSD).',
      'Provide supportive care and pain relief.',
      'Control vectors such as flies and mosquitoes.'
    ],
    'Black Quarter (BQ)': [
      'Vaccinate animals against BQ annually.',
      'Avoid grazing animals in areas prone to flooding.',
      'Treat affected animals with antibiotics immediately.'
    ],
    'Parasitic Mange': [
      'Apply medicated dips or sprays as recommended.',
      'Clean and disinfect the living environment.',
      'Provide proper nutrition to boost immunity.'
    ],
  };

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _predictedLabel = ""; // Reset prediction label when a new image is selected
      });
    }
  }

  // Function to upload the image and get prediction
  Future<void> _predictPest(File file) async {
    final uri = Uri.parse(ENVConfig.serverUrl + '/predict-pest');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final predictionData = json.decode(responseData);

      setState(() {
        _predictedLabel = predictionData['predicted_label'] ?? 'No prediction available';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to predict pest'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(

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
                title: 'Pests and Disease Detection',
                content: 'Upload images and get details on cattle diseases',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                child: Card(
                  color: Colors.greenAccent.shade100, // Soft purple background
                  elevation: 5, // Adds depth effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 15,),
                      Text(
                        'Inspection Section',
                        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),

                      // Upload button and image preview
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.upload_file),
                        label: Text('Upload Image'),
                      ),
                      SizedBox(height: 20),

                      // Image preview
                      if (_image != null) ...[
                        Image.file(
                          _image!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 20),
                      ],

                      // Upload button to send image and get prediction
                      if (_image != null) ...[
                        ElevatedButton(
                          onPressed: () => _predictPest(_image!),
                          child: Text('Classify Pest'),
                        ),
                        SizedBox(height: 20),
                      ],

                      // Display prediction label
                      if (_predictedLabel.isNotEmpty) ...[
                        Text(
                          'Predicted Pest: $_predictedLabel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Styles.secondaryColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Display remedies
                        if (remedies.containsKey(_predictedLabel)) ...[
                          Text(
                            'Remedies:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                          ...remedies[_predictedLabel]!.map(
                                (remedy) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '- $remedy',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                )
              )
            ),
          ],
        ),
      )
    );
  }
}
