import 'package:admin_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

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
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(3).toList(); // Take only the top 3
  }

  Future<List<MapEntry<String, int>>> _getLeastUsedParkings() async {
    // Changed method name
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
      ..sort((a, b) => a.value.compareTo(b.value)) // Sort in ascending order
      ..take(3).toList(); // Take only the top 3
  }

  String _formatAverageDuration(int averageDurationInMinutes) {
    if (averageDurationInMinutes <= 60) {
      return '$averageDurationInMinutes mins';
    } else {
      int hours = averageDurationInMinutes ~/ 60;
      int remainingMinutes = averageDurationInMinutes % 60;
      return '$hours hr $remainingMinutes mins';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Statistics'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ],
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard(
                    'Total Parkings', stats['totalParkings'].toString()),
                const Divider(),
                _buildStatCard(
                    'Active Parkings', stats['activeParkings'].toString()),
                const Divider(),
                _buildStatCard('Total Parking Spaces',
                    stats['totalParkingSpaces'].toString()),
                const Divider(),
                _buildStatCard(
                    'Average Parking Duration',
                    _formatAverageDuration(stats['averageDuration']
                        as int)), // Pass int and format
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Add padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.textColor,
              ),
              onPressed: () async {
                final top3 = await _getTop3Parkings();
                _showTop3Dialog(top3);
              },
              icon: const Icon(Icons.star),
              label: const Text('Most Used'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.textColor,
              ),
              onPressed: () async {
                final leastUsed =
                    await _getLeastUsedParkings(); // Changed method name
                _showLeastUsedDialog(leastUsed);
              },
              icon: const Icon(Icons.low_priority),
              label: const Text('Least Used'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.textColor,
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18.0, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  void _showTop3Dialog(List<MapEntry<String, int>> top3) {
    showDialog(
      context: context,
      builder: (context) {
        final top3Limited = top3.take(3).toList(); // Take only the first 3

        return AlertDialog(
          title: const Text('Top 3 Most Used Parking Spaces'),
          content: SizedBox(
            height: top3Limited.isEmpty
                ? null
                : 200, // Dynamic height or null if empty
            width: 300,
            child: top3Limited.isEmpty
                ? const Center(child: Text('No data available'))
                : ListView.builder(
                    itemCount: top3Limited.length,
                    itemBuilder: (context, index) {
                      final entry = top3Limited[index];
                      return ListTile(
                        title: Text(entry.key),
                        trailing: Text('${entry.value} parkings'),
                      );
                    },
                  ),
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

  void _showLeastUsedDialog(List<MapEntry<String, int>> leastUsed) {
    showDialog(
      context: context,
      builder: (context) {
        // Sort leastUsed in ascending order by value (number of parkings)
        final leastUsedSorted = leastUsed.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        final top3LeastUsed =
            leastUsedSorted.take(3).toList(); // Take only the first 3

        return AlertDialog(
          title: const Text('Least Used Parking Spaces'),
          content: SizedBox(
            height: top3LeastUsed.isEmpty
                ? null
                : 200, // Dynamic height or null if empty
            width: 300,
            child: top3LeastUsed.isEmpty
                ? const Center(child: Text('No data available'))
                : ListView.builder(
                    itemCount: top3LeastUsed.length,
                    itemBuilder: (context, index) {
                      final entry = top3LeastUsed[index];
                      return ListTile(
                        title: Text(entry.key),
                        trailing: Text('${entry.value} parkings'),
                      );
                    },
                  ),
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
}
