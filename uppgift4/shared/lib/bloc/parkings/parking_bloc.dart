import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

      Parking? selectedParking;
      if (state is ParkingLoaded) {
        selectedParking = (state as ParkingLoaded).selectedParking;
      }

      final availableParkingSpaces = parkingSpaces.where((space) {
        final isOccupied = parkings.any((p) =>
            p.endTime == null && p.parkingSpace.target?.id == space.id);
        final isSelected = selectedParking?.parkingSpace.target?.id == space.id;

        debugPrint('Space ${space.address} is ${isOccupied ? "occupied" : "available"}. Selected: $isSelected');

        return !isOccupied || isSelected;
      }).toList();

      emit(ParkingLoaded(
        parkings: filteredParkings,
        vehicles: vehicles,
        parkingSpaces: parkingSpaces,
        availableParkingSpaces: availableParkingSpaces,
        selectedParking: selectedParking,
      ));
      debugPrint('Parkings loaded: $filteredParkings');
    } catch (e) {
      debugPrint('Error loading parkings: $e');
      emit(ParkingError('Failed to load parkings: $e'));
    }
  }

  Future<void> _onCreateParking(
      CreateParking event, Emitter<ParkingState> emit) async {
    debugPrint(
        'Creating parking for Vehicle ID: ${event.vehicleId}, Parking Space ID: ${event.parkingSpaceId}');
    try {
      final vehicle =
          await vehicleRepository.getById(int.parse(event.vehicleId));
      final parkingSpace =
          await parkingSpaceRepository.getById(int.parse(event.parkingSpaceId));

      if (vehicle == null || parkingSpace == null) {
        debugPrint('Vehicle or Parking Space not found.');
        emit(ParkingError('Vehicle or Parking Space not found.'));
        return;
      }

      final parking = Parking(startTime: DateTime.now());
      parking.setDetails(vehicle, parkingSpace);

      await parkingRepository.create(parking);
      debugPrint('Parking created: $parking');
      add(LoadParkings());
    } catch (e) {
      debugPrint('Error creating parking: $e');
      emit(ParkingError('Failed to create parking: $e'));
    }
  }

  Future<void> _onStopParking(
      StopParking event, Emitter<ParkingState> emit) async {
    debugPrint('Stopping parking with ID: ${event.parkingId}');
    try {
      await parkingRepository.stop(event.parkingId);
      debugPrint('Parking stopped: ${event.parkingId}');
      add(LoadParkings());
    } catch (e) {
      debugPrint('Error stopping parking: $e');
      emit(ParkingError('Failed to stop parking: $e'));
    }
  }

  Future<void> _onUpdateParking(
      UpdateParking event, Emitter<ParkingState> emit) async {
    debugPrint('Updating parking: ${event.parking}');
    try {
      emit(ParkingLoading());
      final updatedParking =
          await parkingRepository.update(event.parking.id, event.parking);
      debugPrint('Parking updated: $updatedParking');
      add(LoadParkings());
    } catch (e) {
      debugPrint('Error updating parking: $e');
      emit(ParkingError('Failed to update parking: $e'));
    }
  }

  void _onSelectParking(SelectParking event, Emitter<ParkingState> emit) {
    debugPrint('Selecting parking: ${event.selectedParking}');
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      emit(currentState.copyWith(selectedParking: event.selectedParking));
      debugPrint('Selected parking updated: ${event.selectedParking}');
    }
  }
}
