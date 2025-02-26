import 'dart:async';

import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';
import 'package:notification_utils/notification_utils.dart';
import 'package:uuid/uuid.dart';

import '../../app_constants.dart';
import '../auth/auth_firebase_bloc.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  final VehicleRepository vehicleRepository;
  final ParkingSpaceRepository parkingSpaceRepository;

  ParkingFilter _currentFilter =
      ParkingFilter.active; // Currently applied filter
  List<Parking> _allParkings = [];
  List<Vehicle> _allVehicles = [];
  List<ParkingSpace> _allParkingSpaces = [];

  final AuthFirebaseBloc authFirebaseBloc;

  ParkingBloc({
    required this.parkingRepository,
    required this.vehicleRepository,
    required this.parkingSpaceRepository,
    required this.authFirebaseBloc,
  }) : super(ParkingLoading()) {
    on<LoadParkings>(_onLoadParkings);
    on<CreateParking>(_onCreateParking);
    on<StopParking>(_onStopParking);
    on<SelectParking>(_onSelectParking);
    on<UpdateParking>(_onUpdateParking);
    on<ChangeFilter>(_onChangeFilter);
    on<ProlongParking>(_onProlongParking);
    on<CancelParkingNotification>(_onCancelParkingNotification);
    on<ScheduleParkingNotification>(_onScheduleParkingNotification);

    add(LoadParkings(filter: _currentFilter));
  }

  Future<void> _onProlongParking(ProlongParking event, Emitter<ParkingState> emit) async {
  try {
    final existingParking = await parkingRepository.getById(event.parkingId);

    if (existingParking != null && existingParking.notificationId != null) {
      debugPrint('🚗 [ParkingBloc] Prolonging parking: $existingParking');

      final newEndTime = existingParking.endTime != null
          ? existingParking.endTime!.add(prolongationDuration)
          : existingParking.startTime.add(prolongationDuration);

      await parkingRepository.prolong(event.parkingId, newEndTime); // Update endTime in Firestore

      final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      final existingIds = pendingNotifications.map((n) => n.id).toList();

      debugPrint("🔎 Existing pending notification IDs: $existingIds"); // Print ALL pending IDs

      if (existingIds.contains(existingParking.notificationId)) {
        debugPrint('✅ [ParkingBloc] Found notification ID ${existingParking.notificationId}, updating it.');

        await flutterLocalNotificationsPlugin.cancel(existingParking.notificationId!); // Cancel old notification
      } else {
        debugPrint('[ParkingBloc] No pending notification found, scheduling a new one.');
      }

      // Calculate notification time (e.g., 3 minutes before newEndTime)
      final notificationTime = newEndTime.subtract(const Duration(minutes: 3));

      await updateParkingNotification(
        title: "Parking Extended",
        content: "Your parking has been extended until ${DateFormat.Hm().format(newEndTime.toLocal())}",
        newEndTime: newEndTime,
        notificationId: existingParking.notificationId!,
        notificationTime: notificationTime, // Pass the calculated notificationTime
      );

      add(LoadParkings(filter: _currentFilter));
    } else {
      debugPrint('[ParkingBloc] No existing parking or notification ID found.');
      emit(ParkingError('Parking not found or no notification ID'));
    }
  } catch (e) {
    emit(ParkingError('Failed to prolong parking: $e'));
  }
}

  Future<void> _onCancelParkingNotification(
      CancelParkingNotification event, Emitter<ParkingState> emit) async {
    try {
      final parking = await parkingRepository.getById(event.parkingId);
      if (parking != null && parking.notificationId != null) {
        await cancelNotification(parking.notificationId!);
      }
    } catch (e) {
      emit(ParkingError('Failed to cancel notification: $e'));
    }
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

  Future<void> _onCreateParking(
      CreateParking event, Emitter<ParkingState> emit) async {
    print("[_onCreateParking]: CreateParking event received. Parking details:");
    print("[_onCreateParking]: Parking ID: ${event.parking.id}");
    print("[_onCreateParking]: Start Time: ${event.parking.startTime}");
    print("[_onCreateParking]: End Time: ${event.parking.endTime}");
    print(
        "[_onCreateParking]: Vehicle License Plate: ${event.parking.vehicle?.licensePlate}"); // Handle null vehicle
    print(
        "[_onCreateParking]: Parking Space Address: ${event.parking.parkingSpace?.address}"); // Handle null space
    print(
        "[_onCreateParking]: Notification ID: ${event.parking.notificationId}");
    try {
      int? notificationId;
      DateTime? reminderTimeUtc;

      final endTimeUtc = event.parking.endTime;
      debugPrint("🚗 [ParkingBloc] End time: $endTimeUtc");

      if (endTimeUtc != null) {
        reminderTimeUtc = endTimeUtc.subtract(const Duration(minutes: 3));
        if (reminderTimeUtc.isAfter(DateTime.now().toUtc())) {
          final uuid = const Uuid();
          notificationId = uuid.v4().hashCode;
        }
      }

      final parkingToCreate = event.parking
          .copyWith(endTime: endTimeUtc, notificationId: notificationId);
      debugPrint("🚗 [ParkingBloc] Creating parking: $parkingToCreate");

      final createdParking = await parkingRepository.create(parkingToCreate);

      if (reminderTimeUtc != null && notificationId != null) {
        // Check if both are not null
        await scheduleNotification(
          title: "Parking Reminder",
          content:
              "Your parking at ${createdParking.parkingSpace?.address} expires soon!",
          deliveryTime: reminderTimeUtc,
          id: notificationId, // Use the generated UUID
        );
        debugPrint(
            "✅ [ParkingBloc] Notification scheduled with ID: $notificationId");
      } else {
        debugPrint(
            "⚠️ Notification time is in the past or endTime is null. No notification scheduled.");
      }

      add(LoadParkings(filter: _currentFilter));
    } catch (e) {
      emit(ParkingError(
          'Failed to create parking or schedule notification: $e'));
      debugPrint("Error details: $e");
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
        id: event.parkingId.hashCode, // Use event.parkingId.hashCode
      );
    } catch (e) {
      emit(ParkingError('Failed to schedule notification: $e'));
    }
  }
}
