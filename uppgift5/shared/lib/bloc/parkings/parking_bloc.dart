import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'parking_event.dart';
import 'parking_state.dart';
import 'package:shared/shared.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  final VehicleRepository vehicleRepository;
  final ParkingSpaceRepository parkingSpaceRepository;

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
  }

  Future<void> _onLoadParkings(
    LoadParkings event,
    Emitter<ParkingState> emit,
  ) async {
    debugPrint('Loading parkings...');
    emit(ParkingLoading());
    try {
      final parkings = await parkingRepository.getAll();
      final vehicles = await vehicleRepository.getAll();
      final parkingSpaces = await parkingSpaceRepository.getAll();

      debugPrint('Fetched parkings: $parkings');
      debugPrint('Fetched vehicles: $vehicles');
      debugPrint('Fetched parking spaces: $parkingSpaces');

      final filteredParkings = event.showActiveOnly
          ? parkings.where((p) => p.endTime == null).toList()
          : parkings;

      Parking? selectedParking = (state is ParkingLoaded)
          ? (state as ParkingLoaded).selectedParking
          : null;

      final availableVehicles = vehicles.where((vehicle) {
        final isOccupied = parkings.any(
          (p) => p.endTime == null && p.vehicle?.id == vehicle.id,
        );
        return !isOccupied;
      }).toList();

      final availableParkingSpaces = parkingSpaces.where((space) {
        final isOccupied = parkings.any(
          (p) => p.endTime == null && p.parkingSpace?.id == space.id,
        );
        final isSelected = selectedParking?.parkingSpace?.id == space.id;
        return !isOccupied || isSelected;
      }).toList();

      emit(ParkingLoaded(
        parkings: filteredParkings,
        vehicles: vehicles,
        parkingSpaces: parkingSpaces,
        availableVehicles: availableVehicles,
        availableParkingSpaces: availableParkingSpaces,
        selectedParking: selectedParking,
        isFilteringActive: event.showActiveOnly,
      ));
    } catch (e) {
      debugPrint('Error loading parkings: $e');
      emit(ParkingError('Failed to load parkings: $e'));
    }
  }

  Future<void> _onCreateParking(
    CreateParking event,
    Emitter<ParkingState> emit,
  ) async {
    debugPrint(
        'Creating parking for Vehicle ID: ${event.vehicleId}, Parking Space ID: ${event.parkingSpaceId}');
    try {
      final vehicle = await vehicleRepository.getById(event.vehicleId);
      final parkingSpace =
          await parkingSpaceRepository.getById(event.parkingSpaceId);

      if (vehicle == null || parkingSpace == null) {
        emit(ParkingError('Vehicle or Parking Space not found.'));
        return;
      }

      final parking = Parking(
        id: const Uuid().v4(), // Assign a unique ID
        startTime: DateTime.now(),
        vehicle: vehicle,
        parkingSpace: parkingSpace,
      );

      await parkingRepository.create(parking);
      debugPrint('Parking created: $parking');
      add(LoadParkings());
    } catch (e) {
      debugPrint('Error creating parking: $e');
      emit(ParkingError('Failed to create parking: $e'));
    }
  }

  Future<void> _onStopParking(
    StopParking event,
    Emitter<ParkingState> emit,
  ) async {
    debugPrint('Stopping parking with ID: ${event.parkingId}');
    try {
      await parkingRepository.stop(event.parkingId);
      add(LoadParkings());
    } catch (e) {
      debugPrint('Error stopping parking: $e');
      emit(ParkingError('Failed to stop parking: $e'));
    }
  }

  Future<void> _onUpdateParking(
    UpdateParking event,
    Emitter<ParkingState> emit,
  ) async {
    debugPrint('Updating parking: ${event.parking}');
    try {
      final updatedParking = event.parking.copyWith(); // Create updated parking
      await parkingRepository.update(updatedParking.id, updatedParking);
      add(LoadParkings());
    } catch (e) {
      debugPrint('Error updating parking: $e');
      emit(ParkingError('Failed to update parking: $e'));
    }
  }

  void _onSelectParking(
    SelectParking event,
    Emitter<ParkingState> emit,
  ) {
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      emit(currentState.copyWith(selectedParking: event.selectedParking));
    }
  }
}
