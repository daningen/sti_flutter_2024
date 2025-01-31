import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'parking_space_event.dart';
import 'parking_space_state.dart';

class ParkingSpaceBloc extends Bloc<ParkingSpaceEvent, ParkingSpaceState> {
  final ParkingSpaceRepository parkingSpaceRepository;
  late final Stream<List<ParkingSpace>> _parkingSpaceStream;

  ParkingSpaceBloc({required this.parkingSpaceRepository})
      : super(ParkingSpaceInitial()) {
    on<LoadParkingSpaces>(_onLoadParkingSpaces);
    on<CreateParkingSpace>(_onCreateParkingSpace);
    on<UpdateParkingSpace>(_onUpdateParkingSpace);
    on<DeleteParkingSpace>(_onDeleteParkingSpace);
    on<SelectParkingSpace>(_onSelectParkingSpace);

    // **Subscribe to Firestore real-time parking space updates**
    _parkingSpaceStream = parkingSpaceRepository.parkingSpacesStream();
    _parkingSpaceStream.listen((updatedParkingSpaces) {
      debugPrint(
          'Firestore detected parking space update: $updatedParkingSpaces');

      // INSTEAD, TRIGGER EVENT TO UPDATE STATE
      add(LoadParkingSpaces()); // This correctly updates state inside Bloc
    });
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

  Future<void> _onSelectParkingSpace(
    SelectParkingSpace event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    final currentState = state;
    if (currentState is ParkingSpaceLoaded) {
      emit(ParkingSpaceLoaded(
        parkingSpaces: currentState.parkingSpaces,
        selectedParkingSpace: event.parkingSpace,
      ));
      if (event.parkingSpace != null) {
        debugPrint(
            'Selected parking space: ${event.parkingSpace!.address}, Price: ${event.parkingSpace!.pricePerHour}');
      } else {
        debugPrint('⚪ No parking space selected.');
      }
    }
  }

  Future<void> _onCreateParkingSpace(
    CreateParkingSpace event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    debugPrint(
        '➕ Creating parking space: ${event.address}, Price: ${event.pricePerHour}');
    try {
      final newParkingSpace = ParkingSpace(
        address: event.address,
        pricePerHour: event.pricePerHour,
      );
      await parkingSpaceRepository.create(newParkingSpace);
      debugPrint('Parking space created successfully: $newParkingSpace');
      // **No need to manually reload, as Firestore updates via stream**
    } catch (e) {
      debugPrint('Error creating parking space: $e');
      emit(ParkingSpaceError(message: 'Failed to create parking space: $e'));
    }
  }

  Future<void> _onUpdateParkingSpace(
    UpdateParkingSpace event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    debugPrint('🛠 Received UpdateParkingSpace event for ID: ${event.id}');
    try {
      final existingParkingSpace = await parkingSpaceRepository.getById(event.id);
      if (existingParkingSpace == null) {
        debugPrint('❌ Parking space not found. ID: ${event.id}');
        emit(ParkingSpaceError(message: 'Parking space not found.'));
        return;
      }

      debugPrint('✅ Existing parking space found: $existingParkingSpace');

      final updatedParkingSpace = existingParkingSpace.copyWith(
        address: event.updatedSpace.address,
        pricePerHour: event.updatedSpace.pricePerHour,
      );

      debugPrint('⬆️ Updating Firestore with: $updatedParkingSpace');

      await parkingSpaceRepository.update(event.id, updatedParkingSpace);

      debugPrint('🎉 Parking space updated successfully: $updatedParkingSpace');
      // No need to manually reload; Firestore stream updates automatically.
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating parking space: $e\n$stackTrace');
      emit(ParkingSpaceError(message: 'Failed to update parking space: $e'));
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
      // **Firestore stream automatically triggers updates**
    } catch (e) {
      debugPrint('Error deleting parking space: $e');
      emit(ParkingSpaceError(message: 'Failed to delete parking space: $e'));
    }
  }
}
