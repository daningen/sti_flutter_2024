import 'dart:async';

import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  final VehicleRepository vehicleRepository;
  final ParkingSpaceRepository parkingSpaceRepository;

  ParkingFilter _currentFilter = ParkingFilter.active;
  List<Parking> _allParkings = [];

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
    on<ChangeFilter>(_onChangeFilter);

    add(LoadParkings(filter: _currentFilter));
  }

  Future<void> _onLoadParkings(
      LoadParkings event, Emitter<ParkingState> emit) async {
    debugPrint('🔄 Loading parkings with filter: ${event.filter}');

    _currentFilter = event.filter;

    await emit.forEach<List<Parking>>(
      parkingRepository.getParkingsStream(),
      onData: (parkings) {
        debugPrint("🔥 Real-time update received. Updating parkings...");
        debugPrint("Current filter: $_currentFilter");

        _allParkings = parkings;

        final filteredParkings = _filterParkings(parkings, _currentFilter);

        debugPrint("✅ Filtered parkings count: ${filteredParkings.length}");

        return ParkingLoaded(
          parkings: filteredParkings,
          allParkings: parkings, // Pass all parkings here
          vehicles: [],
          parkingSpaces: [],
          availableVehicles: [],
          availableParkingSpaces: [],
          filter: _currentFilter,
        );
      },
      onError: (error, stackTrace) {
        debugPrint('❌ Error loading parkings: $error, Stacktrace: $stackTrace');
        emit(ParkingError('Failed to load parkings: $error'));
        return ParkingError('Failed to load parkings: $error');
      },
    );
  }

  List<Parking> _filterParkings(List<Parking> parkings, ParkingFilter filter) {
    final nowUtc = DateTime.now().toUtc(); // Get current time in UTC

    if (filter == ParkingFilter.all) {
      return parkings;
    } else if (filter == ParkingFilter.active) {
      return parkings.where((p) {
        final endTimeUtc = p.endTime?.toUtc(); // Convert endTime to UTC

        debugPrint("Checking if $endTimeUtc is after $nowUtc (Active Filter)");

        if (endTimeUtc == null) {
          debugPrint("endTime is null, so it's considered active.");
          return true; // Treat null endTime as active
        } 

        final isAfter = endTimeUtc.isAfter(nowUtc); // Compare UTC times
        debugPrint(
            "$endTimeUtc is ${isAfter ? "after" : "before or equal to"} $nowUtc");
        return isAfter;
      }).toList();
    } else {
      return parkings.where((p) {
        final endTimeUtc = p.endTime?.toUtc(); // Convert endTime to UTC

        debugPrint(
            "Checking if $endTimeUtc is before $nowUtc (Inactive Filter)");

        if (endTimeUtc == null) {
          debugPrint("endTime is null, so it's NOT considered inactive.");
          return false; // Treat null endTime as NOT inactive
        }

        final isBefore = endTimeUtc.isBefore(nowUtc); // Compare UTC times
        debugPrint(
            "$endTimeUtc is ${isBefore ? "before" : "after or equal to"} $nowUtc");
        return isBefore;
      }).toList();
    }
  }

  void testFiltering(List<Parking> parkings) {
    final nowUtc = DateTime.now().toUtc(); // Current time in UTC

    debugPrint(
        "Current time (nowUtc): $nowUtc"); // Print the current time being used

    final activeParkings = _filterParkings(parkings, ParkingFilter.active);
    final inactiveParkings = _filterParkings(parkings, ParkingFilter.inactive);
    final allParkings = _filterParkings(parkings, ParkingFilter.all);

    debugPrint("Active Parkings Count: ${activeParkings.length}");
    debugPrint("Inactive Parkings Count: ${inactiveParkings.length}");
    debugPrint("All Parkings Count: ${allParkings.length}");

    // Print endTime details for active parkings
    debugPrint("\nDetails of Active Parkings:");
    for (final parking in activeParkings) {
      debugPrint(
          "Parking ID: ${parking.id}, endTime: ${parking.endTime}, endTime (UTC): ${parking.endTime?.toUtc()}");
    }

    // Print endTime details for inactive parkings
    debugPrint("\nDetails of Inactive Parkings:");
    for (final parking in inactiveParkings) {
      debugPrint(
          "Parking ID: ${parking.id}, endTime: ${parking.endTime}, endTime (UTC): ${parking.endTime?.toUtc()}");
    }

    debugPrint("\nDetails of ALL Parkings:");
    for (final parking in allParkings) {
      debugPrint(
          "Parking ID: ${parking.id}, endTime: ${parking.endTime}, endTime (UTC): ${parking.endTime?.toUtc()}");
    }
  }

  void _onChangeFilter(ChangeFilter event, Emitter<ParkingState> emit) {
    debugPrint('🔀 Changing filter to: ${event.filter}');
    _currentFilter = event.filter;

    final filteredParkings = _filterParkings(_allParkings, _currentFilter);

    emit(ParkingLoaded(
      parkings: filteredParkings,
      allParkings: _allParkings, // Pass all parkings here
      vehicles: [],
      parkingSpaces: [],
      availableVehicles: [],
      availableParkingSpaces: [],
      filter: _currentFilter,
    ));
  }

  Future<void> _onCreateParking(
      CreateParking event, Emitter<ParkingState> emit) async {
    debugPrint('➕ [ParkingBloc] Creating parking...');
    try {
      await parkingRepository.create(event.parking);
      debugPrint('✅ [ParkingBloc] Parking created');
      add(LoadParkings(filter: _currentFilter)); // Refresh the list
    } catch (e) {
      debugPrint('❌ [ParkingBloc] Error creating parking: $e');
      emit(ParkingError('Failed to create parking: $e'));
    }
  }

  Future<void> _onStopParking(
      StopParking event, Emitter<ParkingState> emit) async {
    debugPrint('⏹ [ParkingBloc] Stopping parking with ID: ${event.parkingId}');
    try {
      await parkingRepository.stop(event.parkingId);
      debugPrint('✅ [ParkingBloc] Parking stopped successfully.');
      add(LoadParkings(filter: _currentFilter)); // Refresh the list
    } catch (e) {
      debugPrint('❌ [ParkingBloc] Error stopping parking: $e');
      emit(ParkingError('Failed to stop parking: $e'));
    }
  }

  void _onSelectParking(SelectParking event, Emitter<ParkingState> emit) {
    debugPrint('🚗 [ParkingBloc] Selecting parking: ${event.selectedParking}');
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      emit(currentState.copyWith(selectedParking: event.selectedParking));
    }
  }

  Future<void> _onUpdateParking(
      UpdateParking event, Emitter<ParkingState> emit) async {
    debugPrint('✏️ [ParkingBloc] Updating parking: ${event.parking}');
    try {
      await parkingRepository.update(event.parking.id, event.parking);
      debugPrint('✅ [ParkingBloc] Parking updated');
      add(LoadParkings(filter: _currentFilter)); // Refresh the list
    } catch (e) {
      debugPrint('❌ [ParkingBloc] Error updating parking: $e');
      emit(ParkingError('Failed to update parking: $e'));
    }
  }
}
