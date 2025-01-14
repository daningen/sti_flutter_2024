import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'vehicles_event.dart';
import 'vehicles_state.dart';
import 'package:client_repositories/async_http_repos.dart';
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
      debugPrint('Fetched vehicles from [vehiclesbloc]: $vehicles');
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
      );
      newVehicle.setOwner(event.owner); // Set owner using event data
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
      final updatedVehicle = Vehicle(
        id: event.vehicleId,
        licensePlate: event.updatedVehicle.licensePlate,
        vehicleType: event.updatedVehicle.vehicleType,
      );
      updatedVehicle.setOwner(
          event.updatedVehicle.owner.target!); // Ensure owner is updated
      await vehicleRepository.update(event.vehicleId, updatedVehicle);
      debugPrint('Vehicle updated successfully: $updatedVehicle');
      add(LoadVehicles());
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
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
    }
  }
}
