import 'dart:async';

import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'package:notification_utils/notification_utils.dart'; 

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
 on<ScheduleParkingNotification>(_onScheduleParkingNotification); 
    add(LoadParkings(filter: _currentFilter));
  }

  Future<void> _onLoadParkings(
      LoadParkings event, Emitter<ParkingState> emit) async {
    debugPrint('🔄 Loading parkings with filter: ${event.filter}');

    _currentFilter = event.filter;

    try {
      final vehicles = await vehicleRepository.getAll();
      final parkingSpaces = await parkingSpaceRepository.getAll();

      await emit.forEach<List<Parking>>(
        // Stream listening with emit.forEach ensures real-time updates
        parkingRepository.getParkingsStream(),
        onData: (parkings) {
          debugPrint("🔥 Real-time update received. Updating parkings...");

          _allParkings = parkings;
          final filteredParkings = _filterParkings(parkings, _currentFilter);

          // Update available vehicles and parking spaces dynamically whenever the state updates
          final availableVehicles = vehicles
              .where((vehicle) => !_allParkings.any((p) =>
                  p.vehicle?.id == vehicle.id &&
                  p.endTime ==
                      null)) // Only exclude vehicles with active parking
              .toList();

          final availableParkingSpaces = parkingSpaces
              .where((space) => !_allParkings.any((p) =>
                  p.parkingSpace?.id == space.id &&
                  p.endTime == null)) // Only exclude occupied parking spaces
              .toList();

          return ParkingLoaded(
            parkings: filteredParkings,
            allParkings: parkings,
            vehicles: vehicles,
            parkingSpaces: parkingSpaces,
            availableVehicles: availableVehicles,
            availableParkingSpaces: availableParkingSpaces,
            filter: _currentFilter,
          );
        },
        onError: (error, stackTrace) {
          debugPrint('❌ Error loading parkings: $error');
          return ParkingError('Failed to load parkings: $error');
        },
      );
    } catch (error) {
      debugPrint('❌ Failed to fetch vehicles or parking spaces: $error');
      emit(ParkingError('Failed to load parkings: $error'));
    }
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

  Future<void> _onScheduleParkingNotification(
      ScheduleParkingNotification event, Emitter<ParkingState> emit) async {

    debugPrint('🔔 [ParkingBloc] Scheduling notification for parking ID: ${event.parkingId}');

    try {
      await scheduleNotification(
        title: event.title,
        content: event.content,
        deliveryTime: event.deliveryTime,
        id: event.parkingId.hashCode, // Use parkingId.hashCode for unique ID
      );

      debugPrint('✅ [ParkingBloc] Notification scheduled successfully.');

      // Optionally, you can emit a state to indicate that the notification was scheduled
      // emit(NotificationScheduled(parkingId: event.parkingId));

    } catch (e) {
      debugPrint('❌ [ParkingBloc] Error scheduling notification: $e');
      emit(ParkingError('Failed to schedule notification: $e'));
    }
  }
}
