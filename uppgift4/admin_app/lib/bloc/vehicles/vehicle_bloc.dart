// vehicle_bloc.dart
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
    emit(VehicleLoading());
    try {
      final vehicles = await vehicleRepository.getAll();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError('Failed to load vehicles: $e'));
    }
  }

  Future<void> _onCreateVehicle(
      CreateVehicle event, Emitter<VehicleState> emit) async {
    try {
      final newVehicle = Vehicle(
        licensePlate: event.licensePlate,
        vehicleType: event.vehicleType, // Ensure it matches the model field
      );
      await vehicleRepository.create(newVehicle);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError('Failed to create vehicle: $e'));
    }
  }

  Future<void> _onUpdateVehicle(
      UpdateVehicle event, Emitter<VehicleState> emit) async {
    try {
      final updatedVehicle = Vehicle(
        id: event.vehicleId, // Ensure the ID is passed
        licensePlate: event.updatedVehicle.licensePlate,
        vehicleType: event.updatedVehicle.vehicleType,
      );
      await vehicleRepository.update(event.vehicleId, updatedVehicle);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError('Failed to update vehicle: $e'));
    }
  }

  Future<void> _onDeleteVehicle(
      DeleteVehicle event, Emitter<VehicleState> emit) async {
    try {
      await vehicleRepository.delete(event.vehicleId);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError('Failed to delete vehicle: $e'));
    }
  }
}
