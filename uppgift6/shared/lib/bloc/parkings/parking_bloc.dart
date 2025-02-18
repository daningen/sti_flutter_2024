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
  List<Vehicle> _allVehicles = [];
  List<ParkingSpace> _allParkingSpaces = [];

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

  Future<void> _onLoadParkings(LoadParkings event, Emitter<ParkingState> emit) async {
    debugPrint('🔄 Loading parkings with filter: ${event.filter}');
    _currentFilter = event.filter;
    try {
      _allVehicles = await vehicleRepository.getAll();
      _allParkingSpaces = await parkingSpaceRepository.getAll();

      await emit.forEach<List<Parking>>(
        parkingRepository.getParkingsStream(),
        onData: (parkings) {
          _allParkings = List.from(parkings);
          final filteredParkings = _filterParkings(_allParkings, _currentFilter);

          final availableVehicles = _allVehicles.where((vehicle) => !_allParkings.any((p) => p.vehicle?.id == vehicle.id && p.endTime == null)).toList();
          final availableParkingSpaces = _allParkingSpaces.where((space) => !_allParkings.any((p) => p.parkingSpace?.id == space.id && p.endTime == null)).toList();

          return ParkingLoaded(
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
          emit(ParkingError('Failed to load parkings: $error'));
          return ParkingError('Failed to load parkings: $error');
        },
      );
    } catch (error) {
      emit(ParkingError('Failed to load parkings: $error'));
    }
  }

  List<Parking> _filterParkings(List<Parking> parkings, ParkingFilter filter) {
    final nowUtc = DateTime.now().toUtc();

    if (filter == ParkingFilter.all) {
      return parkings;
    } else if (filter == ParkingFilter.active) {
      return parkings.where((p) {
        final endTimeUtc = p.endTime?.toUtc();
        return endTimeUtc == null || endTimeUtc.isAfter(nowUtc);
      }).toList();
    } else {
      return parkings.where((p) {
        final endTimeUtc = p.endTime?.toUtc();
        return endTimeUtc != null && endTimeUtc.isBefore(nowUtc);
      }).toList();
    }
  }

  void _onChangeFilter(ChangeFilter event, Emitter<ParkingState> emit) {
    _currentFilter = event.filter;
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      final filteredParkings = _filterParkings(currentState.allParkings, _currentFilter);
      emit(currentState.copyWith(parkings: filteredParkings, filter: _currentFilter));
    } else {
      add(LoadParkings(filter: _currentFilter));
    }
  }

  Future<void> _onCreateParking(CreateParking event, Emitter<ParkingState> emit) async {
    try {
      await parkingRepository.create(event.parking);
      debugPrint('✅ [ParkingBloc] Parking created');
      debugPrint("🚗 New Parking Created - ID: ${event.parking.id}, EndTime: ${event.parking.endTime}");

      if (event.parking.endTime != null) {
        final reminderTimeUtc = event.parking.endTime!.subtract(const Duration(minutes: 3));
        debugPrint("🔔 Scheduling notification for: $reminderTimeUtc (UTC)");

        if (reminderTimeUtc.isAfter(DateTime.now().toUtc())) {
          debugPrint("✅ [ParkingBloc] Notification scheduled at: $reminderTimeUtc");

          add(ScheduleParkingNotification(
            title: "Parking Reminder",
            content: "Your parking at ${event.parking.parkingSpace?.address} expires soon!",
            deliveryTime: reminderTimeUtc,
            parkingId: event.parking.id,
          ));
        } else {
          debugPrint("⚠️ Notification time is in the past. No notification scheduled.");
        }
      } else {
        debugPrint("🚨 ERROR: Parking was created with `endTime` = null!");
      }

      add(LoadParkings(filter: _currentFilter));
    } catch (e) {
      emit(ParkingError('Failed to create parking: $e'));
    }
  }

  Future<void> _onStopParking(StopParking event, Emitter<ParkingState> emit) async {
    try {
      await parkingRepository.stop(event.parkingId);
      add(LoadParkings(filter: _currentFilter));
    } catch (e) {
      emit(ParkingError('Failed to stop parking: $e'));
    }
  }

  void _onSelectParking(SelectParking event, Emitter<ParkingState> emit) {
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      emit(currentState.copyWith(selectedParking: event.selectedParking));
    }
  }

  Future<void> _onUpdateParking(UpdateParking event, Emitter<ParkingState> emit) async {
    try {
      await parkingRepository.update(event.parking.id, event.parking);
      add(LoadParkings(filter: _currentFilter));
    } catch (e) {
      emit(ParkingError('Failed to update parking: $e'));
    }
  }

  Future<void> _onScheduleParkingNotification(ScheduleParkingNotification event, Emitter<ParkingState> emit) async {
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
