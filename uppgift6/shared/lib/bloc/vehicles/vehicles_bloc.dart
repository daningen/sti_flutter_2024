import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/bloc/auth/auth_firebase_bloc.dart';
import 'vehicles_event.dart';
import 'vehicles_state.dart';
import 'package:shared/shared.dart';

class VehiclesBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;
  final AuthFirebaseBloc authFirebaseBloc; // Add authFirebaseBloc

  VehiclesBloc({
    required this.vehicleRepository,
    required this.authFirebaseBloc, // Initialize it
  }) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<ReloadVehicles>(_onReloadVehicles);
    on<CreateVehicle>(_onCreateVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<SelectVehicle>(_onSelectVehicle);
  }

  /// Handles the LoadVehicles event.
  /// Fetches all vehicles from the repository and emits a VehicleLoaded state.
  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    debugPrint('Loading vehicles...');
    emit(VehicleLoading()); // Emit loading state

    try {
      final vehicles = await vehicleRepository.getAll(); // Fetch vehicles
      for (final vehicle in vehicles) {
        debugPrint('Vehicle: ${vehicle.toJson()}');
      }
      emit(VehicleLoaded(vehicles)); // Emit loaded state with vehicles
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
      emit(VehicleError('Failed to load vehicles: $e')); // Emit error state
    }
  }

  /// Handles the ReloadVehicles event.
  /// Triggers the LoadVehicles event to reload the vehicles.
  Future<void> _onReloadVehicles(
      ReloadVehicles event, Emitter<VehicleState> emit) async {
    debugPrint('Reloading vehicles...');
    add(LoadVehicles()); // Add LoadVehicles event to reload
  }

  /// Handles the CreateVehicle event.
  /// Creates a new vehicle using the repository and updates the state.
  Future<void> _onCreateVehicle(
      CreateVehicle event, Emitter<VehicleState> emit) async {
    debugPrint(
        'Creating vehicle: LicensePlate: ${event.licensePlate}, Type: ${event.vehicleType}, OwnerAuthId: ${event.ownerAuthId}'); // Log ownerAuthId

    try {
      final newVehicle = Vehicle(
        authId: event.authId, // Auth ID of the creator
        licensePlate: event.licensePlate,
        vehicleType: event.vehicleType,
        ownerAuthId: event.ownerAuthId, // Use ownerAuthId
      );

      await vehicleRepository.create(newVehicle); // Create the vehicle
      debugPrint('Vehicle created successfully: $newVehicle');

      // Optimistically update the state
      if (state is VehicleLoaded) {
        final currentState = state as VehicleLoaded;
        final updatedVehicles = currentState.vehicles.toList()..add(newVehicle);
        emit(currentState.copyWith(vehicles: updatedVehicles));
      } else {
        add(LoadVehicles()); // Reload if not in VehicleLoaded state
      }
    } catch (e) {
      debugPrint('Error creating vehicle: $e');
      emit(VehicleError('Failed to create vehicle: $e')); // Emit error state
    }
  }

  /// Handles the UpdateVehicle event.
  /// Updates an existing vehicle using the repository and updates the state.
  Future<void> _onUpdateVehicle(
      UpdateVehicle event, Emitter<VehicleState> emit) async {
    try {
      final updatedVehicle = event.updatedVehicle.copyWith(
        id: event.vehicleId,
      );

      await vehicleRepository.update(event.vehicleId, updatedVehicle); // Update vehicle

      // Optimistically update the state
      if (state is VehicleLoaded) {
        final currentState = state as VehicleLoaded;
        final updatedVehicles = currentState.vehicles
            .map((v) => v.id == event.vehicleId ? updatedVehicle : v)
            .toList();
        emit(currentState.copyWith(vehicles: updatedVehicles));
      } else {
        add(LoadVehicles()); // Reload if not in VehicleLoaded state
      }
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
      emit(VehicleError('Failed to update vehicle: $e')); // Emit error state
    }
  }

  /// Handles the DeleteVehicle event.
  /// Deletes a vehicle using the repository and updates the state.
  Future<void> _onDeleteVehicle(
      DeleteVehicle event, Emitter<VehicleState> emit) async {
    try {
      await vehicleRepository.delete(event.vehicleId); // Delete vehicle

      // Optimistically update the state
      if (state is VehicleLoaded) {
        final currentState = state as VehicleLoaded;
        final updatedVehicles = currentState.vehicles
            .where((v) => v.id != event.vehicleId)
            .toList();
        emit(currentState.copyWith(vehicles: updatedVehicles));
      } else {
        add(LoadVehicles()); // Reload if not in VehicleLoaded state
      }
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
      emit(VehicleError('Failed to delete vehicle: $e')); // Emit error state
    }
  }

  /// Handles the SelectVehicle event.
  /// Updates the selected vehicle in the state.
  Future<void> _onSelectVehicle(
      SelectVehicle event, Emitter<VehicleState> emit) async {
    final currentState = state;
    if (currentState is VehicleLoaded) {
      emit(VehicleLoaded(
        currentState.vehicles,
        selectedVehicle: event.vehicle, // Update selected vehicle
      ));
      debugPrint('Vehicle selected: ${event.vehicle}');
    }
  }
}