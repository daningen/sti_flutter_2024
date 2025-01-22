import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final ParkingRepository parkingRepository;
  final ParkingSpaceRepository parkingSpaceRepository;

  StatisticsBloc({
    required this.parkingRepository,
    required this.parkingSpaceRepository,
  }) : super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
      LoadStatistics event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    try {
      final parkings = await parkingRepository.getAll();
      final parkingSpaces = await parkingSpaceRepository.getAll();

      final activeParkings = parkings.where((p) => p.endTime == null).length;

      final completedParkings =
          parkings.where((p) => p.endTime != null).toList();

      final averageParkingDuration = completedParkings.isNotEmpty
          ? completedParkings
                  .map((p) => p.endTime!.difference(p.startTime).inMinutes)
                  .reduce((a, b) => a + b) ~/
              completedParkings.length
          : 0;

      emit(StatisticsLoaded(
        totalParkings: parkings.length,
        activeParkings: activeParkings,
        totalParkingSpaces: parkingSpaces.length,
        averageDuration: averageParkingDuration,
      ));
    } catch (e) {
      emit(StatisticsError(message: 'Failed to load statistics: $e'));
    }
  }
}
