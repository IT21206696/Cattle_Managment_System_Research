import 'package:chat_app/widgets/custom_bottom_navigation.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import this for Timer
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmManagementScreen extends StatefulWidget {
  final Map<String, dynamic> animal;

  // Constructor to receive the animal data
  FarmManagementScreen({required this.animal});

  @override
  _FarmManagementScreenState createState() => _FarmManagementScreenState();
}

class _FarmManagementScreenState extends State<FarmManagementScreen> {
  late GoogleMapController _mapController;
  final LatLng _initialLocation = LatLng(7.8731, 80.7718);
  Set<Marker> _markers = {};
  Set<Polygon> _polygons = {}; // This will store the geofencing boundary
  List<LatLng> _boundaryCoordinates = [];
  bool _isLoading = true;
  String _distanceKm = "";
  String cattleName = "";
  String cattleBreed = "";
  String status = "";
  String alert = "Normal";
  String batteryHealth = "100%";
  String countInArea = "18 cows";
  String insideBoundary = "Yes";
  String lastFeed = "Yes";
  String farm = "G1";
  String time = "7.15 p.m.";
  int _selectedIndex = 0;
  String username = "Guest";
  String farmName = '';
  String farmDetails = '';
  List<dynamic> _farms = [];
  Set<Polyline> _polylines = {};

  String cattleStatus = 'Subject is inside Marked area';
  bool isIn = true;

  @override
  void initState() {
    super.initState();
    // Set the animal data to the relevant variables
    cattleName = widget.animal['name'];
    cattleBreed = widget.animal['type'];
    status = widget.animal['status'];
    // Initialize any other fields if necessary
    time = DateFormat.jm().format(DateTime.now());
    _loadLocationData();
    _loadUserFarms();

    // Set up a timer to reload the location data every 60 seconds
    Timer.periodic(Duration(seconds: 20), (Timer t) {
      _loadLocationData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on index
    switch (index) {
      case 0:
      // Navigate to Home
        print("Home Clicked");
        break;
      case 1:
      // Navigate to Settings
        print("Settings Clicked");
        break;
      case 2:
      // Navigate to Profile
        print("Profile Clicked");
        break;
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _boundaryCoordinates.add(position);

      // Add marker for each tap
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(title: "Farm Border"),
        ),
      );

      // Create a polygon if more than two points are added
      if (_boundaryCoordinates.length > 2) {
        _polygons.clear(); // Clear previous polygons
        _polygons.add(
          Polygon(
            polygonId: PolygonId('farm_border'),
            points: _boundaryCoordinates,
            strokeColor: Colors.green,
            strokeWidth: 2,
            fillColor: Colors.green.withOpacity(0.2),
          ),
        );
      }
    });
  }

  Future<void> _saveFarmBorder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
    });
    if (_boundaryCoordinates.isEmpty) {
      print("No boundary points added!");
      return;
    }

    final url = ENVConfig.serverUrl + '/mark-farm-border';
    final requestData = {
      'user': username, // You can get the actual user data here
      'farm_name': farm,
      'details': 'Farm Boundary Details',
      'border': _boundaryCoordinates
          .map((coord) => {'latitude': coord.latitude, 'longitude': coord.longitude})
          .toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Farm border saved: ${data['farm_id']}");
      } else {
        throw Exception('Failed to save farm border');
      }
    } catch (e) {
      print("Error saving farm border: $e");
    }
  }

  Future<void> _showFarmDetailsPopup() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Farm Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Farm Name', labelStyle: TextStyle(color: Colors.white)),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  farmName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Farm Details', labelStyle: TextStyle(color: Colors.white)),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  farmDetails = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveFarmBorder();
              },
              child: Text("Save", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadUserFarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
    });

    final url = ENVConfig.serverUrl + '/farms/$username';  // Replace with your actual API URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          _farms = data['farms'];
          _isLoading = false;
          // Process each farm and its boundary to draw polygons
          _polygons.clear();  // Clear previous polygons
          for (var farm in _farms) {
            List<LatLng> boundaryPoints = [];
            for (var point in farm['border']) {
              boundaryPoints.add(LatLng(point['latitude'], point['longitude']));
            }
            _polygons.add(Polygon(
              polygonId: PolygonId(farm['id']),
              points: boundaryPoints,
              strokeColor: Colors.green, // Border color
              strokeWidth: 3,
              fillColor: Colors.yellow.withOpacity(0.5), // Area color
            ));
          }
        });
      } else {
        throw Exception('Failed to load farms');
      }
    } catch (e) {
      print("Error loading farms: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add boundary points on the map
  void _addBoundaryPoint(LatLng point) {
    setState(() {
      _boundaryCoordinates.add(point);
      _markers.add(Marker(
        markerId: MarkerId('${point.latitude},${point.longitude}'),
        position: point,
        infoWindow: InfoWindow(title: 'Boundary Point'),
      ));

      // Draw a polyline for the boundary
      if (_boundaryCoordinates.length > 1) {
        _polylines.add(Polyline(
          polylineId: PolylineId("boundary"),
          points: _boundaryCoordinates,
          color: Colors.green,
          width: 3,
        ));
      }
    });
  }


  Future<void> _loadLocationData() async {
    final url = ENVConfig.serverUrl + '/location';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final location = data['location'];
        final location24 = data['location_24'];
        final duration = data['duration'];

        if (location != null && location24 != null) {
          final marker1 = Marker(
            markerId: MarkerId("Location (current)"),
            position: LatLng(location['latitude'], location['longitude']),
            infoWindow: InfoWindow(title: "Location (current)"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          );

          final marker2 = Marker(
            markerId: MarkerId("Location"),
            position: LatLng(location24['latitude'], location24['longitude']),
            infoWindow: InfoWindow(title: "Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          );

          bool isInside = isLocationInsidePolygon(LatLng(location['latitude'], location['longitude']));
          if (isInside) {
            print("Current location is inside one of the marked areas.");
          } else {
            print("Current location is outside the marked areas.");
          }

          setState(() {
            _markers = {marker1, marker2};
            _distanceKm = duration != null ? "${duration['distance_km'].toStringAsFixed(3)} km" : "N/A";
            countInArea = duration['distance_km'].toString();
            _isLoading = false;

            if (isInside) {
              isIn = true;
              cattleStatus = "Subject is inside marked area";
            } else {
              isIn = false;
              cattleStatus = "Subject is outside of marked area";
            }
          });

          // Move camera to marker1 location
          _mapController.animateCamera(
            CameraUpdate.newLatLng(LatLng(location['latitude'], location['longitude'])),
          );
        } else {
          throw Exception("No location data available.");
        }
      } else {
        throw Exception("Failed to load location data.");
      }
    } catch (e) {
      print("Error loading location data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool isLocationInsidePolygon(LatLng point) {
    for (var polygon in _polygons) {
      if (_isPointInsidePolygon(polygon.points, point)) {
        return true; // The point is inside the polygon
      }
    }
    return false; // The point is outside all polygons
  }

// Helper function to determine if a point is inside a polygon
  bool _isPointInsidePolygon(List<LatLng> polygonPoints, LatLng point) {
    int n = polygonPoints.length;
    bool inside = false;

    // Ray-casting algorithm to determine if the point is inside the polygon
    for (int i = 0, j = n - 1; i < n; j = i++) {
      LatLng pi = polygonPoints[i];
      LatLng pj = polygonPoints[j];

      bool intersect = (pi.longitude > point.longitude) != (pj.longitude > point.longitude) &&
          (point.latitude < (pj.latitude - pi.latitude) * (point.longitude - pi.longitude) /
              (pj.longitude - pi.longitude) + pi.latitude);

      if (intersect) {
        inside = !inside;
      }
    }
    return inside;
  }


  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Scaffold(
        body: Column(
          children: [
            // Farm Management Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const CustomCard(title: 'Farm Management', content: 'Choose options you want to visit',),
            ),
            SizedBox(height: 10),
            // Container(
            //   padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            //   decoration: BoxDecoration(
            //     color: Colors.green.shade700,
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Text(
            //     "Real Time",
            //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,  // Spacing between buttons
              children: [
                // Green Save Farm Border button
                ElevatedButton(
                  onPressed: _showFarmDetailsPopup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save, color: Colors.white),  // Icon for Save button
                      SizedBox(width: 8),
                      Text(
                        "Save Border",  // Shortened text
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Orange button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _boundaryCoordinates = [];
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,  // Orange color for the button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, color: Colors.white),  // Example icon for the orange button
                      SizedBox(width: 8),
                      Text(
                        "Erase Border",  // Text for the orange button
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Rounded Map Container
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 200,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(target: _initialLocation, zoom: 9),
                  markers: _markers,
                  polygons: _polygons,
                  polylines: _polylines,
                  onTap: _onMapTapped,
                ),
              ),
            ),
            SizedBox(height: 15),


            // Cattle Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoColumn("Cattle Name", cattleName, isBold: true),
                      _infoColumn("Cattle Breed", cattleBreed, isBold: true),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoColumn("Status", status, color: Colors.orange),
                      _infoColumn("Alert", alert, color: Colors.blue),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoColumn("Battery Health", batteryHealth, isBold: true),
                      _infoColumn("Travel Distance (1 day)", countInArea+' km', isBold: true),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoColumn("Inside the Boundary", insideBoundary, color: Colors.green),
                      _infoColumn("Came to Last Feed", lastFeed, color: Colors.green),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoColumn("Farm", farm, isBold: true),
                      _infoColumn("Time", time, isBold: true),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),

            // Search Other Cow Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isIn?Styles.secondaryColor:Styles.dangerColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text(cattleStatus, style: TextStyle(color: Colors.white)),
            ),

            SizedBox(height: 10),

            // Bottom Navigation
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  Widget _infoColumn(String title, String value, {Color? color, bool isBold = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white60),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
