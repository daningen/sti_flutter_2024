abstract class StatisticsState {}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final int totalParkings;
  final int activeParkings;
  final int totalParkingSpaces;
  final int averageDuration;

  StatisticsLoaded({
    required this.totalParkings,
    required this.activeParkings,
    required this.totalParkingSpaces,
    required this.averageDuration,
  });
}

class MostUsedParkingSpacesLoaded extends StatisticsState {
  final List<MapEntry<String, int>> parkingSpaces;

  MostUsedParkingSpacesLoaded(this.parkingSpaces);
}

class LeastUsedParkingSpacesLoaded extends StatisticsState {
  final List<MapEntry<String, int>> parkingSpaces;

  LeastUsedParkingSpacesLoaded(this.parkingSpaces);
}

class StatisticsError extends StatisticsState {
  final String message;

  StatisticsError({required this.message});
}
