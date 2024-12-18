import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  late Future<Map<String, dynamic>> _statisticsFuture;
  final DateFormat timeFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    setState(() {
      _statisticsFuture = _fetchStatistics();
    });
  }

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final parkings = await ParkingRepository().getAll();
    final parkingSpaces = await ParkingSpaceRepository().getAll();

    final activeParkings =
        parkings.where((p) => p.endTime == null).toList().length;

    // Calculate average duration (rounded to nearest int)
    final completedParkings = parkings.where((p) => p.endTime != null).toList();
    final averageParkingDuration = completedParkings.isNotEmpty
        ? completedParkings
                .map((p) => p.endTime!.difference(p.startTime).inMinutes)
                .reduce((a, b) => a + b) ~/
            completedParkings.length
        : 0;

    return {
      'totalParkings': parkings.length,
      'activeParkings': activeParkings,
      'totalParkingSpaces': parkingSpaces.length,
      'averageDuration': averageParkingDuration, // Rounded to int
    };
  }

  Future<List<MapEntry<String, int>>> _getTop3Parkings() async {
    final parkings = await ParkingRepository().getAll();
    final parkingCounts = <String, int>{}; // Use address as key

    for (var parking in parkings) {
      if (parking.parkingSpace.target != null) {
        parkingCounts.update(
          parking.parkingSpace.target!.address, // Use address as key
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return parkingCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  Future<ParkingSpace?> _getLeastUsedParking() async {
    final parkings = await ParkingRepository().getAll();
    final parkingCounts = <ParkingSpace, int>{};

    for (var parking in parkings) {
      if (parking.parkingSpace.target != null) {
        parkingCounts.update(
          parking.parkingSpace.target!,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return parkingCounts.entries.isNotEmpty
        ? parkingCounts.entries.reduce((a, b) => a.value < b.value ? a : b).key
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Statistics'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statisticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final stats = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildStatCard(
                  'Total Parkings', stats['totalParkings'].toString()),
              _buildStatCard(
                  'Active Parkings', stats['activeParkings'].toString()),
              _buildStatCard('Total Parking Spaces',
                  stats['totalParkingSpaces'].toString()),
              _buildStatCard('Average Parking Duration',
                  '${stats['averageDuration']} mins'), // Rounded to int
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Add padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final top3 = await _getTop3Parkings();
                _showTop3Dialog(top3);
              },
              icon: const Icon(Icons.star),
              label: const Text('Top 3 Most Used'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final leastUsed = await _getLeastUsedParking();
                _showLeastUsedDialog(leastUsed);
              },
              icon: const Icon(Icons.low_priority),
              label: const Text('Least Used'),
            ),
            ElevatedButton.icon(
              onPressed: _loadStatistics,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18.0, color: Colors.blueAccent),
        ),
      ),
    );
  }

  void _showTop3Dialog(List<MapEntry<String, int>> top3) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Top 3 Most Used Parking Spaces'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: top3.map((entry) {
              return ListTile(
                title: Text(entry.key), // Display the address directly
                trailing: Text('${entry.value} parkings'),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showLeastUsedDialog(ParkingSpace? space) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Least Used Parking Space'),
          content: space != null
              ? Text('Address: ${space.address}')
              : const Text('No data available'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
