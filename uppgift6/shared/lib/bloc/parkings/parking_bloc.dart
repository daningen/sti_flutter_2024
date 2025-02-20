import 'dart:async';

import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'package:notification_utils/notification_utils.dart';

import '../auth/auth_firebase_bloc.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository; // Parking data repository
  final VehicleRepository vehicleRepository; // Vehicle data repository
  final ParkingSpaceRepository
      parkingSpaceRepository; // Parking space data repository

  ParkingFilter _currentFilter =
      ParkingFilter.active; // Currently applied filter
  List<Parking> _allParkings = []; // All loaded parkings
  List<Vehicle> _allVehicles = []; // All loaded vehicles
  List<ParkingSpace> _allParkingSpaces = []; // All loaded parking spaces

  final AuthFirebaseBloc authFirebaseBloc; // Auth Firebase Bloc

  ParkingBloc({
    required this.parkingRepository,
    required this.vehicleRepository,
    required this.parkingSpaceRepository,
    required this.authFirebaseBloc,
  }) : super(ParkingLoading()) {
    on<LoadParkings>(_onLoadParkings); // Handle LoadParkings event
    on<CreateParking>(_onCreateParking); // Handle CreateParking event
    on<StopParking>(_onStopParking); // Handle StopParking event
    on<SelectParking>(_onSelectParking); // Handle SelectParking event
    on<UpdateParking>(_onUpdateParking); // Handle UpdateParking event
    on<ChangeFilter>(_onChangeFilter); // Handle ChangeFilter event
    on<ScheduleParkingNotification>(
        _onScheduleParkingNotification); // Handle ScheduleParkingNotification event

    add(LoadParkings(filter: _currentFilter)); // Initial data load
  }

  /// Loads parkings data, vehicles, and parking spaces.
  Future<void> _onLoadParkings(
      LoadParkings event, Emitter<ParkingState> emit) async {
    debugPrint(
        '🔄 Loading parkings with filter: ${event.filter}'); // Debug print
    _currentFilter = event.filter; // Update current filter

    final authState = authFirebaseBloc.state; // Access the state directly

    if (authState is AuthAuthenticated) {
      final userRole = authState.person.role;
      final loggedInUserAuthId = authState.person.authId;

      try {
        _allVehicles = await vehicleRepository.getAll(); // Load all vehicles
        _allParkingSpaces =
            await parkingSpaceRepository.getAll(); // Load all parking spaces

        await emit.forEach<List<Parking>>(
          parkingRepository.getParkingsStream(userRole,
              loggedInUserAuthId), // 5. Pass role and ID to the stream
          onData: (parkings) {
            debugPrint(
                'Parkings from stream (before filter): ${_allParkings.length}'); // Debug print before filter

            _allParkings = List.from(parkings); // 6. Update all parkings
            final filteredParkings = _filterParkings(
                _allParkings, _currentFilter); // 7. Apply time-based filter
            debugPrint(
                'Parkings after filter: ${filteredParkings.length}'); // Debug print after filter

            final availableVehicles = _allVehicles
                .where((vehicle) => !_allParkings.any(
                    (p) => p.vehicle?.id == vehicle.id && p.endTime == null))
                .toList(); // 8. Find available vehicles
            final availableParkingSpaces = _allParkingSpaces
                .where((space) => !_allParkings.any(
                    (p) => p.parkingSpace?.id == space.id && p.endTime == null))
                .toList(); // 9. Find available parking spaces

            return ParkingLoaded(
              // 10. Emit ParkingLoaded state
              parkings: filteredParkings,
              allParkings: _allParkings,
              vehicles: _allVehicles,
              parkingSpaces: _allParkingSpaces,
              availableVehicles: availableVehicles,
              availableParkingSpaces: availableParkingSpaces,
              filter: _currentFilter,
            );
          },
          onError: (error, stackTrace) {
            emit(ParkingError(
                'Failed to load parkings: $error')); // 11. Emit ParkingError state
            return ParkingError(
                'Failed to load parkings: $error'); // Return error (for stream handling)
          },
        );
      } catch (error) {
        emit(ParkingError(
            'Failed to load parkings: $error')); // 12. Emit ParkingError state
      }
    }
  }

  /// Filters parkings based on the selected filter (all, active, past).
  List<Parking> _filterParkings(List<Parking> parkings, ParkingFilter filter) {
    final nowUtc = DateTime.now().toUtc(); // Current time in UTC

    if (filter == ParkingFilter.all) {
      debugPrint('Returning all parkings'); // Debug print for all filter
      return parkings; // All parkings
    } else if (filter == ParkingFilter.active) {
      return parkings.where((p) {
        // Active parkings (endTime is null or in the future)
        final endTimeUtc = p.endTime?.toUtc();
        
        return endTimeUtc == null || endTimeUtc.isAfter(nowUtc);
      }).toList();
    } else {
      // Past parkings (endTime is in the past)
      return parkings.where((p) {
        final endTimeUtc = p.endTime?.toUtc();
        return endTimeUtc != null && endTimeUtc.isBefore(nowUtc);
      }).toList();
    }
  }

  /// Handles filter changes.
  void _onChangeFilter(ChangeFilter event, Emitter<ParkingState> emit) {
    _currentFilter = event.filter; // Update current filter

    if (state is ParkingLoaded) {
      // If data is loaded
      final currentState = state as ParkingLoaded;
      final filteredParkings = _filterParkings(
          currentState.allParkings, _currentFilter); // Apply filter
      emit(currentState.copyWith(
          parkings: filteredParkings,
          filter: _currentFilter)); // Emit updated state
    } else {
      add(LoadParkings(filter: _currentFilter)); // Reload data with new filter
    }
  }

  /// Handles parking creation.
  Future<void> _onCreateParking(
      CreateParking event, Emitter<ParkingState> emit) async {
    try {
      await parkingRepository
          .create(event.parking); // Create parking in the repository
      debugPrint('✅ [ParkingBloc] Parking created'); // Debug print
      debugPrint(
          "🚗 New Parking Created - ID: ${event.parking.id}, EndTime: ${event.parking.endTime}"); // Debug print

      // Schedule notification if end time is set and in the future.
      if (event.parking.endTime != null) {
        final reminderTimeUtc = event.parking.endTime!
            .subtract(const Duration(minutes: 3))
            .toUtc(); // Calculate reminder time
        debugPrint(
            "🔔 Scheduling notification for: $reminderTimeUtc (UTC)"); // Debug print

        if (reminderTimeUtc.isAfter(DateTime.now().toUtc())) {
          // Check if reminder time is in the future
          debugPrint(
              "✅ [ParkingBloc] Notification scheduled at: $reminderTimeUtc"); // Debug print

          add(ScheduleParkingNotification(
            // Schedule notification
            title: "Parking Reminder",
            content:
                "Your parking at ${event.parking.parkingSpace?.address} expires soon!",
            deliveryTime: reminderTimeUtc,
            parkingId: event.parking.id,
          ));
        } else {
          debugPrint(
              "⚠️ Notification time is in the past. No notification scheduled."); // Debug print
        }
      } else {
        debugPrint(
            "🚨 ERROR: Parking was created with `endTime` = null!"); // Debug print
      }

      add(LoadParkings(filter: _currentFilter)); // Reload parkings
    } catch (e) {
      emit(ParkingError('Failed to create parking: $e')); // Emit ParkingError
    }
  }

  /// Handles parking stop.
  Future<void> _onStopParking(
      StopParking event, Emitter<ParkingState> emit) async {
    try {
      await parkingRepository
          .stop(event.parkingId); // Stop parking in repository
      add(LoadParkings(filter: _currentFilter)); // Reload parkings
    } catch (e) {
      emit(ParkingError('Failed to stop parking: $e')); // Emit ParkingError
    }
  }

  /// Handles parking selection.
  void _onSelectParking(SelectParking event, Emitter<ParkingState> emit) {
    if (state is ParkingLoaded) {
      // If data is loaded
      final currentState = state as ParkingLoaded;
      emit(currentState.copyWith(
          selectedParking: event.selectedParking)); // Update selected parking
    }
  }

  Future<void> _onUpdateParking(
      UpdateParking event, Emitter<ParkingState> emit) async {
    try {
      await parkingRepository.update(event.parking.id, event.parking);
      add(LoadParkings(filter: _currentFilter));
    } catch (e) {
      emit(ParkingError('Failed to update parking: $e'));
    }
  }

  Future<void> _onScheduleParkingNotification(
      ScheduleParkingNotification event, Emitter<ParkingState> emit) async {
    try {
      await scheduleNotification(
        title: event.title,
        content: event.content,
        deliveryTime: event.deliveryTime,
        id: event.parkingId.hashCode,
      );
    } catch (e) {
      emit(ParkingError('Failed to schedule notification: $e'));
    }
  }
}
