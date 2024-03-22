import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<String> viewedStations;

  const HistoryPage({Key? key, required this.viewedStations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viewed Stations History'),
      ),
      body: ListView.builder(
        itemCount: viewedStations.length,
        itemBuilder: (context, index) {
          final station = viewedStations[index];
          return ListTile(
            title: Text(station),
            // You can add more details or actions here
          );
        },
      ),
    );
  }
}
