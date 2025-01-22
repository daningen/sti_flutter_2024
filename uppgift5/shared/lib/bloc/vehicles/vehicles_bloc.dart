import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'vehicles_event.dart';
import 'vehicles_state.dart';

import 'package:shared/shared.dart';

class VehiclesBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;

  VehiclesBloc({required this.vehicleRepository}) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<ReloadVehicles>(_onReloadVehicles);
    on<CreateVehicle>(_onCreateVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<SelectVehicle>(_onSelectVehicle);
  }

  Future<void> _onLoadVehicles(
      LoadVehicles event, Emitter<VehicleState> emit) async {
    debugPrint('Loading vehicles...');
    emit(VehicleLoading());
    try {
      final vehicles = await vehicleRepository.getAll();
      debugPrint('Fetched vehicles: $vehicles');
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
      emit(VehicleError('Failed to load vehicles: $e'));
    }
  }

  Future<void> _onReloadVehicles(
      ReloadVehicles event, Emitter<VehicleState> emit) async {
    debugPrint('Reloading vehicles...');
    add(LoadVehicles());
  }

  Future<void> _onCreateVehicle(
      CreateVehicle event, Emitter<VehicleState> emit) async {
    debugPrint(
        'Creating vehicle: LicensePlate: ${event.licensePlate}, Type: ${event.vehicleType}, Owner: ${event.owner.name}');
    try {
      final newVehicle = Vehicle(
        licensePlate: event.licensePlate,
        vehicleType: event.vehicleType,
        owner: event.owner, // Set the owner directly
      );

      await vehicleRepository.create(newVehicle);
      debugPrint('Vehicle created successfully: $newVehicle');
      add(LoadVehicles());
    } catch (e) {
      debugPrint('Error creating vehicle: $e');
      emit(VehicleError('Failed to create vehicle: $e'));
    }
  }

  Future<void> _onUpdateVehicle(
      UpdateVehicle event, Emitter<VehicleState> emit) async {
    debugPrint(
        'Updating vehicle: ID: ${event.vehicleId}, LicensePlate: ${event.updatedVehicle.licensePlate}, Type: ${event.updatedVehicle.vehicleType}');

    try {
      // Ensure the owner is not null
      final owner = event.updatedVehicle.owner;
      if (owner == null) {
        throw Exception("Vehicle owner cannot be null.");
      }

      // Safely update the vehicle
      final updatedVehicle = event.updatedVehicle.copyWith(
        id: event.vehicleId,
        licensePlate: event.updatedVehicle.licensePlate,
        vehicleType: event.updatedVehicle.vehicleType,
        owner: owner, // Update the owner
      );

      await vehicleRepository.update(event.vehicleId, updatedVehicle);
      debugPrint('Vehicle updated successfully: $updatedVehicle');

      add(LoadVehicles());
    } catch (e, stackTrace) {
      debugPrint('Error updating vehicle: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(VehicleError('Failed to update vehicle: $e'));
    }
  }

  Future<void> _onDeleteVehicle(
      DeleteVehicle event, Emitter<VehicleState> emit) async {
    debugPrint('Deleting vehicle with ID: ${event.vehicleId}');
    try {
      await vehicleRepository.delete(event.vehicleId);
      debugPrint('Vehicle deleted successfully: ID: ${event.vehicleId}');
      add(LoadVehicles());
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
      emit(VehicleError('Failed to delete vehicle: $e'));
    }
  }

  Future<void> _onSelectVehicle(
      SelectVehicle event, Emitter<VehicleState> emit) async {
    final currentState = state;
    if (currentState is VehicleLoaded) {
      emit(VehicleLoaded(
        currentState.vehicles,
        selectedVehicle: event.vehicle,
      ));
      debugPrint('Vehicle selected: ${event.vehicle}');
    }
  }
}
