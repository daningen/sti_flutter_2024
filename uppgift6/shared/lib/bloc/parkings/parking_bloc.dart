import 'dart:async';

import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:uuid/uuid.dart';
import 'parking_event.dart';
import 'parking_state.dart';
import 'package:shared/shared.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  final VehicleRepository vehicleRepository;
  final ParkingSpaceRepository parkingSpaceRepository;
  late final Stream<List<ParkingSpace>> parkingSpaceStream;
  StreamSubscription? _parkingSpaceSubscription;

  ParkingBloc({
    required this.parkingRepository,
    required this.vehicleRepository,
    required this.parkingSpaceRepository,
  }) : super(ParkingLoading()) {
    on<LoadParkings>(_onLoadParkings);
    on<CreateParking>(_onCreateParking);
    on<StopParking>(_onStopParking);
    on<SelectParking>(_onSelectParking);
    on<UpdateParking>(_onUpdateParking);

    add(LoadParkings()); // Initial load

    parkingSpaceStream = parkingSpaceRepository.parkingSpacesStream();
    _parkingSpaceSubscription =
        parkingSpaceStream.listen((updatedParkingSpaces) {
      debugPrint('Parking spaces updated: $updatedParkingSpaces');
      add(LoadParkings()); // Reload parkings when spaces change
    });
  }

  @override
  Future<void> close() async {
    _parkingSpaceSubscription?.cancel();
    super.close();
  }

  Future<void> _onLoadParkings(
      LoadParkings event, Emitter<ParkingState> emit) async {
    debugPrint('Loading parkings...');
    emit(ParkingLoading());

    try {
      final parkings = await parkingRepository.getAll();
      final vehicles = await vehicleRepository.getAll();
      final parkingSpaces = await parkingSpaceRepository.getAll();

      debugPrint('Fetched parkings');
      debugPrint('Fetched vehicles');
      debugPrint('Fetched parking spaces');

      // *** FILTERING COMMENTED OUT ***
      // final filteredParkings = event.showActiveOnly
      //     ? parkings.where((p) => p.endTime == null).toList()
      //     : parkings;
      final filteredParkings = parkings; // All parkings now

      Parking? selectedParking = (state is ParkingLoaded)
          ? (state as ParkingLoaded).selectedParking
          : null;

      final availableParkingSpaces = parkingSpaces.where((space) {
        final isOccupied = parkings.any(
          (p) => p.endTime == null && p.parkingSpace?.id == space.id,
        );
        return !isOccupied;
      }).toList();

      debugPrint('Available Parking Spaces: $availableParkingSpaces');

      emit(ParkingLoaded(
        parkings: filteredParkings,
        vehicles: vehicles,
        parkingSpaces: parkingSpaces,
        availableVehicles: vehicles,
        availableParkingSpaces: availableParkingSpaces,
        selectedParking: selectedParking,
        // isFilteringActive: false, // Always false now
      ));
    } catch (e) {
      debugPrint('Error loading parkings: $e');
      emit(ParkingError('Failed to load parkings: $e'));
    }
  }

  Future<void> _onCreateParking(
      CreateParking event, Emitter<ParkingState> emit) async {
    debugPrint('[ParkingBloc] Creating parking...');
    try {
      // final vehicle = await vehicleRepository.getById(event.vehicleId);
      // final parkingSpace = await parkingSpaceRepository.getById(event.parkingSpaceId);

      // if (vehicle == null || parkingSpace == null) {
      //   emit(ParkingError('Vehicle or Parking Space not found.'));
      //   return;
      // }

      // Use the Parking object passed in the event:
      final parking = event.parking; // This is the key change!

      await parkingRepository.create(parking);
      debugPrint(
          '[ParkingBloc] Parking created: ${parking.toJson()}'); // Print with toJson()
      add(LoadParkings());
    } catch (e) {
      debugPrint('[ParkingBloc] Error creating parking: $e');
      emit(ParkingError('Failed to create parking: $e'));
    }
  }

  Future<void> _onStopParking(
      StopParking event, Emitter<ParkingState> emit) async {
    debugPrint('[ParkingBloc] Stopping parking with ID: ${event.parkingId}');
    try {
      await parkingRepository.stop(event.parkingId);
      debugPrint('[ParkingBloc] Parking stopped successfully.');
      add(LoadParkings()); // No filter needed here
    } catch (e) {
      debugPrint('[ParkingBloc] Error stopping parking: $e');
      emit(ParkingError('Failed to stop parking: $e'));
    }
  }

  Future<void> _onUpdateParking(
      UpdateParking event, Emitter<ParkingState> emit) async {
    debugPrint('[ParkingBloc] Updating parking: ${event.parking}');
    try {
      final updatedParking = event.parking.copyWith();
      await parkingRepository.update(updatedParking.id, updatedParking);
      debugPrint('[ParkingBloc] Parking updated: $updatedParking');
      add(LoadParkings()); // No filter needed here
    } catch (e) {
      debugPrint('[ParkingBloc] Error updating parking: $e');
      emit(ParkingError('Failed to update parking: $e'));
    }
  }

  void _onSelectParking(SelectParking event, Emitter<ParkingState> emit) {
    debugPrint('[ParkingBloc] Selecting parking: ${event.selectedParking}');
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      emit(currentState.copyWith(selectedParking: event.selectedParking));
    }
  }
}
