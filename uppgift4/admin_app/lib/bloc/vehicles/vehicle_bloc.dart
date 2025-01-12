import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;

  VehicleBloc({required this.vehicleRepository}) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<CreateVehicle>(_onCreateVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
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

  Future<void> _onCreateVehicle(
      CreateVehicle event, Emitter<VehicleState> emit) async {
    debugPrint(
        'Creating vehicle: LicensePlate: ${event.licensePlate}, Type: ${event.vehicleType}');
    try {
      final newVehicle = Vehicle(
        licensePlate: event.licensePlate,
        vehicleType: event.vehicleType,
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
      final updatedVehicle = Vehicle(
        id: event.vehicleId,
        licensePlate: event.updatedVehicle.licensePlate,
        vehicleType: event.updatedVehicle.vehicleType,
      );
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
}
