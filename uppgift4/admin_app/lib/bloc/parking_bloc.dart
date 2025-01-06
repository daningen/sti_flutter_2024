import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'parking_event.dart';
import 'parking_state.dart';
import 'package:shared/shared.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  final VehicleRepository vehicleRepository;
  final ParkingSpaceRepository parkingSpaceRepository;

  ParkingBloc({
    required this.parkingRepository,
    required this.vehicleRepository,
    required this.parkingSpaceRepository,
  }) : super(ParkingLoading()) {
    on<LoadParkings>(_onLoadParkings);
    on<CreateParking>(_onCreateParking);
    on<StopParking>(_onStopParking);
  }

  Future<void> _onLoadParkings(
      LoadParkings event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final parkings = await parkingRepository.getAll();
      final vehicles = await VehicleRepository().getAll(); // Fetch vehicles
      final parkingSpaces =
          await ParkingSpaceRepository().getAll(); // Fetch parking spaces
      final filteredParkings = event.showActiveOnly
          ? parkings.where((p) => p.endTime == null).toList()
          : parkings;
      emit(ParkingLoaded(
        parkings: filteredParkings,
        vehicles: vehicles,
        parkingSpaces: parkingSpaces,
      ));
    } catch (e) {
      emit(ParkingError('Failed to load parkings: $e'));
    }
  }

  Future<void> _onCreateParking(
      CreateParking event, Emitter<ParkingState> emit) async {
    try {
      // Fetch required details
      final vehicle =
          await vehicleRepository.getById(int.parse(event.vehicleId));
      final parkingSpace =
          await parkingSpaceRepository.getById(int.parse(event.parkingSpaceId));

      if (vehicle == null || parkingSpace == null) {
        emit(ParkingError('Vehicle or Parking Space not found.'));
        return;
      }

      // Create new parking
      final parking = Parking(startTime: DateTime.now());
      parking.setDetails(vehicle, parkingSpace);

      await parkingRepository.create(parking);

      // Reload parkings
      add(LoadParkings());
    } catch (e) {
      emit(ParkingError('Failed to create parking: $e'));
    }
  }

  Future<void> _onStopParking(
      StopParking event, Emitter<ParkingState> emit) async {
    try {
      await parkingRepository.stop(event.parkingId);
      add(LoadParkings());
    } catch (e) {
      emit(ParkingError('Failed to stop parking: $e'));
    }
  }
}
