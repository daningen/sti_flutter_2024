import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
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
    on<LoadMostUsedParkingSpaces>(_onLoadMostUsedParkingSpaces);
    on<LoadLeastUsedParkingSpaces>(_onLoadLeastUsedParkingSpaces);
  }

  Future<void> _onLoadStatistics(
      LoadStatistics event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    try {
      final parkings = await parkingRepository.getAll();
      final parkingSpaces = await parkingSpaceRepository.getAll();

       
     final activeParkings = parkings.where((p) => p.endTime != null && p.endTime!.isAfter(DateTime.now())).length;

final completedParkings = parkings.where((p) => p.endTime != null && p.endTime!.isBefore(DateTime.now())).toList();


      final averageParkingDuration = completedParkings.where((p) => p.endTime != null).isNotEmpty
    ? completedParkings
        .where((p) => p.endTime != null) // Filter out parkings with null endTime
        .map((p) => p.endTime!.difference(p.startTime).inMinutes)
        .reduce((a, b) => a + b) ~/
    completedParkings.where((p) => p.endTime != null).length
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

  Future<void> _onLoadMostUsedParkingSpaces(
      LoadMostUsedParkingSpaces event, Emitter<StatisticsState> emit) async {
    try {
      final parkings = await parkingRepository.getAll();

      final parkingCounts = <String, int>{};

      for (var parking in parkings) {
        final parkingSpace = parking.parkingSpace?.address;
        if (parkingSpace != null) {
          parkingCounts.update(
            parkingSpace,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }

      final sortedParkings = parkingCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      emit(MostUsedParkingSpacesLoaded(sortedParkings));
    } catch (e) {
      emit(StatisticsError(message: 'Failed to load most used parking spaces: $e'));
    }
  }

  Future<void> _onLoadLeastUsedParkingSpaces(
      LoadLeastUsedParkingSpaces event, Emitter<StatisticsState> emit) async {
    try {
      final parkings = await parkingRepository.getAll();

      final parkingCounts = <String, int>{};

      for (var parking in parkings) {
        final parkingSpace = parking.parkingSpace?.address;
        if (parkingSpace != null) {
          parkingCounts.update(
            parkingSpace,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }

      final sortedParkings = parkingCounts.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      emit(LeastUsedParkingSpacesLoaded(sortedParkings));
    } catch (e) {
      emit(StatisticsError(message: 'Failed to load least used parking spaces: $e'));
    }
  }
}
