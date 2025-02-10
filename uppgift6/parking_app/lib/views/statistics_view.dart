import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/bloc/statistics/statistics_bloc.dart';
import 'package:shared/bloc/statistics/statistics_event.dart';
import 'package:shared/bloc/statistics/statistics_state.dart';
import '../widgets/app_bar_actions.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Statistics'),
        actions: const [
          AppBarActions(),
        ],
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StatisticsLoaded) {
            return _buildStatistics(state);
          } else if (state is MostUsedParkingSpacesLoaded) {
            return _buildParkingSpacesList(
              state.parkingSpaces,
              'Most Used Parking Spaces',
            );
          } else if (state is LeastUsedParkingSpacesLoaded) {
            return _buildParkingSpacesList(
              state.parkingSpaces,
              'Least Used Parking Spaces',
            );
          } else if (state is StatisticsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No Data Available'));
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => context
                  .read<StatisticsBloc>()
                  .add(LoadMostUsedParkingSpaces()),
              icon: const Icon(Icons.star),
              label: const Text('Most Used'),
            ),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<StatisticsBloc>()
                  .add(LoadLeastUsedParkingSpaces()),
              icon: const Icon(Icons.low_priority),
              label: const Text('Least Used'),
            ),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<StatisticsBloc>().add(LoadStatistics()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(StatisticsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard('Total Parkings', state.totalParkings.toString()),
          const Divider(),
          _buildStatCard('Active Parkings', state.activeParkings.toString()),
          const Divider(),
          _buildStatCard(
              'Total Parking Spaces', state.totalParkingSpaces.toString()),
          const Divider(),
          _buildStatCard('Average Parking Duration',
              _formatAverageDuration(state.averageDuration)),
        ],
      ),
    );
  }

  Widget _buildParkingSpacesList(
      List<MapEntry<String, int>> parkingSpaces, String title) {
    if (parkingSpaces.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: parkingSpaces.length,
            itemBuilder: (context, index) {
              final entry = parkingSpaces[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${entry.value}', // The parking count
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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

  String _formatAverageDuration(int averageDurationInMinutes) {
    if (averageDurationInMinutes <= 60) {
      return '$averageDurationInMinutes mins';
    } else {
      int hours = averageDurationInMinutes ~/ 60;
      int remainingMinutes = averageDurationInMinutes % 60;
      return '$hours hr $remainingMinutes mins';
    }
  }
}
