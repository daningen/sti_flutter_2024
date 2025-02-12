import 'dart:async';

import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'parking_event.dart';
import 'parking_state.dart';
import 'package:shared/shared.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  final VehicleRepository vehicleRepository;
  final ParkingSpaceRepository parkingSpaceRepository;

  // Maintain filter state at the class level
  ParkingFilter _currentFilter = ParkingFilter.active;

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

    // Load initial data
    add(LoadParkings(filter: _currentFilter));
  }

  Future<void> _onLoadParkings(
      LoadParkings event, Emitter<ParkingState> emit) async {
    debugPrint('🔄 Loading parkings with filter: ${event.filter}');

    // Update the filter state
    _currentFilter = event.filter;

    await emit.forEach<List<Parking>>(
      parkingRepository.getParkingsStream(), // Firestore real-time stream
      onData: (parkings) {
        debugPrint("🔥 Real-time update received. Updating parkings...");

        final now = DateTime.now();

        final filteredParkings = _currentFilter == ParkingFilter.active
            ? parkings.where((p) => p.endTime!.isAfter(now)).toList()
            : parkings.where((p) => p.endTime!.isBefore(now)).toList();

        debugPrint("✅ Filtered parkings count: ${filteredParkings.length}");

        return ParkingLoaded(
          parkings: filteredParkings,
          vehicles: [],
          parkingSpaces: [],
          availableVehicles: [],
          availableParkingSpaces: [],
          filter: _currentFilter,
        );
      },
      onError: (error, stackTrace) {
        debugPrint('❌ Error loading parkings from stream: $error');
        return ParkingError('Failed to load parkings from stream: $error');
      },
    );
  }

  void _onChangeFilter(ChangeFilter event, Emitter<ParkingState> emit) {
    debugPrint('🔀 Changing filter to: ${event.filter}');
    _currentFilter = event.filter;
    add(LoadParkings(filter: _currentFilter));
  }

  Future<void> _onCreateParking(
      CreateParking event, Emitter<ParkingState> emit) async {
    debugPrint('➕ [ParkingBloc] Creating parking...');
    try {
      await parkingRepository.create(event.parking);
      debugPrint('✅ [ParkingBloc] Parking created');
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
    } catch (e) {
      debugPrint('❌ [ParkingBloc] Error stopping parking: $e');
      emit(ParkingError('Failed to stop parking: $e'));
    }
  }

  Future<void> _onUpdateParking(
      UpdateParking event, Emitter<ParkingState> emit) async {
    debugPrint('✏️ [ParkingBloc] Updating parking: ${event.parking}');
    try {
      await parkingRepository.update(event.parking.id, event.parking);
      debugPrint('✅ [ParkingBloc] Parking updated');
    } catch (e) {
      debugPrint('❌ [ParkingBloc] Error updating parking: $e');
      emit(ParkingError('Failed to update parking: $e'));
    }
  }

  void _onSelectParking(SelectParking event, Emitter<ParkingState> emit) {
    debugPrint('🚗 [ParkingBloc] Selecting parking: ${event.selectedParking}');
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      emit(currentState.copyWith(selectedParking: event.selectedParking));
    }
  }
}
