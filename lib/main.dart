import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Search',
      theme: ThemeData(
        primaryColor: Colors.orange,
        accentColor: Colors.black,
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.orange,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: MapSearchScreen(),
    );
  }
}

class MapSearchScreen extends StatefulWidget {
  @override
  _MapSearchScreenState createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  GoogleMapController mapController;
  Set<Marker> markers = {};
  String baseUrl = "http://<your-ngrok-url>.ngrok.io"; // Replace with your ngrok URL

  void searchLocations(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search-location?query=$query'));
    if (response.statusCode == 200) {
      List<dynamic> locations = json.decode(response.body);
      setState(() {
        markers.clear();
        for (var location in locations) {
          markers.add(Marker(
            markerId: MarkerId(location['name']),
            position: LatLng(location['latitude'], location['longitude']),
            infoWindow: InfoWindow(title: location['name']),
          ));
        }
        if (locations.isNotEmpty) {
          mapController.animateCamera(CameraUpdate.newLatLng(
              LatLng(locations[0]['latitude'], locations[0]['longitude'])));
        }
      });
    } else {
      // Handle errors
      print('Failed to load locations');
    }
  }

  void getNearbyLocations() async {
    final response = await http.get(Uri.parse('$baseUrl/search'));
    if (response.statusCode == 200) {
      List<dynamic> locations = json.decode(response.body);
      setState(() {
        markers.clear();
        for (var location in locations) {
          markers.add(Marker(
            markerId: MarkerId(location['name']),
            position: LatLng(
                location['coords']['latitude'], location['coords']['longitude']),
            infoWindow: InfoWindow(title: location['name']),
          ));
        }
        if (locations.isNotEmpty) {
          mapController.animateCamera(CameraUpdate.newLatLng(
              LatLng(locations[0]['coords']['latitude'], locations[0]['coords']['longitude'])));
        }
      });
    } else {
      // Handle errors
      print('Failed to load nearby locations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Locations'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: LocationSearchDelegate(searchLocations));
            },
          ),
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: getNearbyLocations,
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0), // Default to some position
          zoom: 2,
        ),
      ),
    );
  }
}

class LocationSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  LocationSearchDelegate(this.onSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Show some suggestions if needed
  }
}
