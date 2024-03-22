import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:evehicle2/history_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  List<String> _viewedStations = [];

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(40.730610, -73.935242),
    zoom: 14,
  );

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);

    final chargingStations = await _getNearbyChargingStations();
    setState(() {
      _markers.clear();
      _markers.addAll(chargingStations);
    });
  }

  Future<Set<Marker>> _getNearbyChargingStations() async {
    // Example API call to get nearby charging stations
    final apiKey = 'AIzaSyCcMymiePQKAypmGYnFUsxJpcALRCrSY3k';
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.730610,-73.935242&radius=1000&type=electric_vehicle_charging_station&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final List<Marker> markers = [];
        for (final place in data['results']) {
          final marker = Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(
              place['geometry']['location']['lat'],
              place['geometry']['location']['lng'],
            ),
            infoWindow: InfoWindow(
              title: place['name'],
              snippet: 'Available: ${place['business_status'] == 'OPERATIONAL'}',
            ),
            onTap: () {
              // Handle marker tap, e.g., show details in a dialog
              _addToViewedStations(place['name']);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(place['name']),
                  content: Text('Available: ${place['business_status'] == 'OPERATIONAL'}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          );
          markers.add(marker);
        }
        return markers.toSet();
      } else {
        throw Exception('Failed to load charging stations');
      }
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }

  void _addToViewedStations(String stationName) {
    if (!_viewedStations.contains(stationName)) {
      setState(() {
        _viewedStations.add(stationName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Charging Stations'),
        centerTitle: true,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: _onMapCreated,
        markers: _markers,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MapScreen(),
  ));
}
