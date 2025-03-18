import 'dart:convert';
import 'dart:io';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class BreedDetectionScreen extends StatefulWidget {
  const BreedDetectionScreen({super.key});

  @override
  _BreedDetectionScreenState createState() => _BreedDetectionScreenState();
}

class _BreedDetectionScreenState extends State<BreedDetectionScreen> {
  File? _image;
  String _predictedBreed = "";
  String _breedDetails = "";
  bool _adopted = true; // Default value for the checkbox
  String _breedName = "";

  final ImagePicker _picker = ImagePicker();

  // Breed details Map
  final Map<String, String> breedDetailsMap = {
    'Jersey':
        'BRITISH BREED, DEVELOPED IN JERSEY, CHANNEL ISLANDS\n5500 kg\nTHRIVES IN WARM CLIMATES, REQUIRES GOOD GRAZING PASTURES\nSCOTLAND\nSMALL TO MEDIUM BODY, LIGHT BROWN COLOR',
    'Sahiwal':
        'ORIGINATING IN THE SAHIWAL DISTRICT OF PUNJAB, PAKISTAN\n3000 kg\nADAPTED TO TROPICAL CONDITIONS, HEAT-TOLERANT\nPAKISTAN\nMEDIUM SIZE, REDDISH BROWN COAT',
    'Ayrshire':
        'DEVELOPED IN THE COUNTY OF AYRSHIRE IN SOUTHWESTERN SCOTLAND\n4500 kg\nBEST SUITED TO TEMPERATE CLIMATES\nSCOTLAND\nMEDIUM SIZE, REDDISH-BROWN AND WHITE SPOTS',
    'Zebu':
        'CROSSBREED BETWEEN ZEBU AND EUROPEAN BREEDS (AUSTRALIAN FRIESIAN)\n4000 kg\nTHRIVES IN TROPICAL CONDITIONS, HIGH RESISTANCE TO HEAT\nAUSTRALIA\nMEDIUM-SIZED, ZEBU CHARACTERISTICS, HEAT TOLERANCE',
    'Local Lankan (Lankan White)':
        'CROSSBREED BETWEEN ZEBU AND EUROPEAN BREEDS\n4331 kg\nBEST SUITED TO TEMPERATE CLIMATES\nSRI LANKA\nMEDIUM-SIZED, ZEBU CHARACTERISTICS, HEAT TOLERANT',
    'Friesian':
        'ORIGINATING IN THE FRIESLAND REGION OF THE NETHERLANDS\n6500 kg\nTHRIVES IN TEMPERATE CLIMATES, REQUIRES HIGH-QUALITY FEED AND MANAGEMENT\nNETHERLANDS\nLARGE BODY SIZE, BLACK AND WHITE SPOTTED COAT',
  };

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select Image Source',
            style: TextStyle(
              color: Colors.white,
            )),
        actions: <Widget>[
          TextButton(
            child: const Row(
              children: [
                Icon(Icons.photo_library,
                    color: Colors.white70), // Gallery icon
                SizedBox(width: 20),
                Text('Gallery'),
              ],
            ),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
          TextButton(
            child: const Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.white70), // Camera icon
                SizedBox(width: 20),
                Text('Camera'),
              ],
            ),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    );

    if (source != null) {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _predictedBreed =
              ""; // Reset prediction label when a new image is selected
          _breedDetails = ""; // Reset breed details
        });
      }
    }
  }

  Future<void> _getBreedInsights() async {
    final uri = Uri.parse('${ENVConfig.serverUrl}/insights');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'breed_name': _breedName,
        'adopted': _adopted,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Handle the response here (e.g., show a dialog or display the results)
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            'Breed Insights',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Breed: ${responseData['Breed']}\nAdopted: ${responseData['Adopted']}\nPredicted Origin: ${responseData['Predicted_Origin']}\nRearing Conditions: ${responseData['Rearing_Conditions']}\nTemperament: ${responseData['Temperament']}\nMilk Production: ${responseData['Milk_Production']}\nLifespan: ${responseData['Lifespan']}',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to fetch insights'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Function to upload the image and get breed prediction
  Future<void> _predictBreed(File file) async {
    final uri = Uri.parse('${ENVConfig.serverUrl}/predict-breed');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final predictionData = json.decode(responseData);

      setState(() {
        _predictedBreed =
            predictionData['predicted_label'] ?? 'No prediction available';
        _breedName = _predictedBreed; // Set breed name from prediction
        _breedDetails = breedDetailsMap[_predictedBreed] ??
            'No details available for this breed';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to predict breed'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Container(
          child: Center(
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
                    title: 'Breed Detection',
                    content: 'Upload images and get details on cattle breeds',
                  ),
                ),
                Padding(padding: EdgeInsets.all(20),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: Colors.greenAccent.shade100, // Soft purple background
                      elevation: 5, // Adds depth effect
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Breed Detection Section',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),

                                // Upload button and image preview
                                ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Upload Image'),
                                ),
                                const SizedBox(height: 20),

                                // Image preview
                                if (_image != null) ...[
                                  Image.file(
                                    _image!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                // Upload button to send image and get prediction
                                if (_image != null) ...[
                                  ElevatedButton(
                                    onPressed: () => _predictBreed(_image!),
                                    child: const Text('Classify Breed'),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ],
                            ),

                            // Detection section title


                            // Display prediction label
                            // if (_predictedBreed.isNotEmpty) ...[
                            //   Text(
                            //     'Predicted Breed: $_predictedBreed',
                            //     style: TextStyle(
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.bold,
                            //       color: Colors.blue,
                            //     ),
                            //   ),
                            //   SizedBox(height: 20),
                            //   // Display breed details
                            //   Text(
                            //     _breedDetails,
                            //     style: TextStyle(
                            //       fontSize: 14,
                            //       color: Colors.white70,
                            //     ),
                            //   ),
                            // ],
                            if (_predictedBreed.isNotEmpty) ...[
                              Text(
                                'Predicted Breed: $_predictedBreed',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Styles.secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Breed details
                              Card(
                                color: Styles.successColor, // Darker background color
                                elevation: 4, // Slight shadow effect
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0), // Inner spacing
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _breedDetails.split("\n").map((detail) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0), // Spacing between bullets
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.circle, size: 8, color: Colors.white), // Bullet point
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              detail,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white, // White text for contrast
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Checkbox for "Adopted"
                              Row(
                                children: [
                                  Checkbox(
                                    value: _adopted,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _adopted = value ?? true;
                                      });
                                    },
                                  ),
                                  const Text('Adopted'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Find button to send insights request
                              ElevatedButton(
                                onPressed: _getBreedInsights,
                                child: const Text('Match Insights'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                ),)
              ],
            ),
          )
        )));
  }
}
