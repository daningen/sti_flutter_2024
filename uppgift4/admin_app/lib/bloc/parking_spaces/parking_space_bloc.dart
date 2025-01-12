import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart'; // Assuming ParkingSpaceRepository is defined here
import 'parking_space_event.dart';
import 'parking_space_state.dart';

class ParkingSpaceBloc extends Bloc<ParkingSpaceEvent, ParkingSpaceState> {
  final ParkingSpaceRepository parkingSpaceRepository;

  ParkingSpaceBloc({required this.parkingSpaceRepository})
      : super(ParkingSpaceInitial()) {
    on<LoadParkingSpaces>(_onLoadParkingSpaces);
    on<CreateParkingSpace>(_onCreateParkingSpace);
    on<EditParkingSpace>(_onEditParkingSpace);
    on<DeleteParkingSpace>(_onDeleteParkingSpace);
  }

  Future<void> _onLoadParkingSpaces(
    LoadParkingSpaces event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    debugPrint('Loading parking spaces...');
    emit(ParkingSpaceLoading());
    try {
      final parkingSpaces = await parkingSpaceRepository.getAll();
      debugPrint('Fetched parking spaces: $parkingSpaces');
      emit(ParkingSpaceLoaded(parkingSpaces: parkingSpaces));
    } catch (e) {
      debugPrint('Error loading parking spaces: $e');
      emit(ParkingSpaceError(message: 'Failed to load parking spaces: $e'));
    }
  }

  Future<void> _onCreateParkingSpace(
    CreateParkingSpace event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    debugPrint(
        'Creating parking space: Address: ${event.address}, Price: ${event.pricePerHour}');
    try {
      final newParkingSpace = ParkingSpace(
        address: event.address,
        pricePerHour: event.pricePerHour,
      );
      await parkingSpaceRepository.create(newParkingSpace);
      debugPrint('Parking space created successfully: $newParkingSpace');
      add(LoadParkingSpaces());
    } catch (e) {
      debugPrint('Error creating parking space: $e');
      emit(ParkingSpaceError(message: 'Failed to create parking space: $e'));
    }
  }

  Future<void> _onEditParkingSpace(
    EditParkingSpace event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    debugPrint(
        'Editing parking space: ID: ${event.id}, Address: ${event.address}, Price: ${event.pricePerHour}');
    try {
      final updatedParkingSpace = ParkingSpace(
        id: event.id,
        address: event.address,
        pricePerHour: event.pricePerHour,
      );
      await parkingSpaceRepository.update(event.id, updatedParkingSpace);
      debugPrint('Parking space updated successfully: $updatedParkingSpace');
      add(LoadParkingSpaces());
    } catch (e) {
      debugPrint('Error editing parking space: $e');
      emit(ParkingSpaceError(message: 'Failed to edit parking space: $e'));
    }
  }

  Future<void> _onDeleteParkingSpace(
    DeleteParkingSpace event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    debugPrint('Deleting parking space with ID: ${event.id}');
    try {
      await parkingSpaceRepository.delete(event.id);
      debugPrint('Parking space deleted successfully: ID: ${event.id}');
      add(LoadParkingSpaces());
    } catch (e) {
      debugPrint('Error deleting parking space: $e');
      emit(ParkingSpaceError(message: 'Failed to delete parking space: $e'));
    }
  }
}
