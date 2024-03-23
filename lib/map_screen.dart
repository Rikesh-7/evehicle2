import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trust_location/trust_location.dart';
import 'package:location_permissions/location_permissions.dart';

class ChargingStation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  ChargingStation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory ChargingStation.fromJson(Map<String, dynamic> json) {
    return ChargingStation(
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _locationMessage = 'Getting location...';
  List<ChargingStation> _chargingStations = const [];
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await LocationPermissions().checkPermissionStatus();
    if (status == PermissionStatus.granted) {
      _fetchLocation();
    } else {
      _requestLocationPermission();
    }
  }

  Future<void> _fetchLocation() async {
    try {
      final location = await TrustLocation.getLocation();
      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        _locationMessage = 'Location fetched successfully';
      });
    } on TrustLocationException catch (e) {
      setState(() {
        _locationMessage = 'Error fetching location: ${e.message}';
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await LocationPermissions().requestPermissions();
    if (status == PermissionStatus.granted) {
      _fetchLocation();
    } else {
      _checkLocationPermission();
    }
  }

  Future<void> _fetchChargingStations() async {
    try {
      final response = await http.get(Uri.parse('https://api.example.com/charging-stations'));
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> jsonStations = jsonBody['charging_stations'];
        final List<ChargingStation> stations = jsonStations.map((json) => ChargingStation.fromJson(json)).toList();
        setState(() {
          _chargingStations = stations;
        });
      } else {
        setState(() {
          _locationMessage = 'Error fetching charging stations';
        });
      }
    } on SocketException {
      setState(() {
        _locationMessage = 'No internet connection';
      });
    } on HttpException {
      setState(() {
        _locationMessage = 'Error fetching charging stations';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charging Stations'),
      ),
      body: _chargingStations.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _chargingStations.length,
              itemBuilder: (context, index) {
                final chargingStation = _chargingStations[index];
                return ListTile(
                  title: Text(chargingStation.name),
                  subtitle: Text(chargingStation.address),
                  leading: Icon(Icons.electric_car),
                  trailing: Text('${chargingStation.latitude}, ${chargingStation.longitude}'),
                );
              },
            ),
    );
  }
}
