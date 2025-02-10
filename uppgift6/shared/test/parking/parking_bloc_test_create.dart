import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:shared/bloc/parkings/parking_bloc.dart';
import 'package:shared/bloc/parkings/parking_event.dart';
import 'package:shared/bloc/parkings/parking_state.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';

// Define Fakes
class FakeParking extends Fake implements Parking {}

class FakeVehicle extends Fake implements Vehicle {}

class FakeParkingSpace extends Fake implements ParkingSpace {}

// Mock Repositories
class MockParkingRepository extends Mock implements ParkingRepository {}

class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockParkingSpaceRepository extends Mock
    implements ParkingSpaceRepository {}

void main() {
  group('ParkingBloc - CreateParking', () {
    late MockParkingRepository parkingRepository;
    late MockVehicleRepository vehicleRepository;
    late MockParkingSpaceRepository parkingSpaceRepository;

    setUp(() {
      parkingRepository = MockParkingRepository();
      vehicleRepository = MockVehicleRepository();
      parkingSpaceRepository = MockParkingSpaceRepository();

      registerFallbackValue(FakeParking());
      registerFallbackValue(FakeVehicle());
      registerFallbackValue(FakeParkingSpace());
    });

    blocTest<ParkingBloc, ParkingState>(
      'creates a new parking and reloads parkings',
      setUp: () {
        // Mock vehicle and parking space retrieval
        when(() => vehicleRepository.getById(any())).thenAnswer(
          (_) async => Vehicle(
            id: '1', // Ensure the ID is a string
            licensePlate: 'ABC123',
            vehicleType: 'Car',
          ),
        );
        when(() => parkingSpaceRepository.getById(any())).thenAnswer(
          (_) async => ParkingSpace(
            id: '1', // Ensure the ID is a string
            address: 'Main St',
            pricePerHour: 10,
          ),
        );

        // Mock parking creation
        when(() => parkingRepository.create(any())).thenAnswer(
          (_) async => Parking(
            id: '123', // Ensure the ID is a string
            startTime: DateTime.now(),
          ),
        );

        // Mock getAll after creation
        when(() => parkingRepository.getAll()).thenAnswer(
          (_) async => [
            Parking(
              id: '123', // Ensure the ID is a string
              startTime: DateTime.now(),
            ),
          ],
        );

        // Mock other repository fetches
        when(() => vehicleRepository.getAll()).thenAnswer(
          (_) async => [
            Vehicle(
              id: '1', // Ensure the ID is a string
              licensePlate: 'ABC123',
              vehicleType: 'Car',
            ),
          ],
        );
        when(() => parkingSpaceRepository.getAll()).thenAnswer(
          (_) async => [
            ParkingSpace(
              id: '1', // Ensure the ID is a string
              address: 'Main St',
              pricePerHour: 10,
            ),
          ],
        );
      },
      build: () => ParkingBloc(
        parkingRepository: parkingRepository,
        vehicleRepository: vehicleRepository,
        parkingSpaceRepository: parkingSpaceRepository,
      ),
      act: (bloc) =>
          bloc.add(CreateParking(vehicleId: '1', parkingSpaceId: '1')),
      expect: () => [
        isA<ParkingLoading>(),
        isA<ParkingLoaded>(),
      ],
      verify: (_) {
        verify(() => vehicleRepository.getById('1')).called(1);
        verify(() => parkingSpaceRepository.getById('1')).called(1);
        verify(() => parkingRepository.create(any())).called(1);
        verify(() => parkingRepository.getAll()).called(1);
        verify(() => vehicleRepository.getAll()).called(1);
        verify(() => parkingSpaceRepository.getAll()).called(1);
      },
    );
  });
}
