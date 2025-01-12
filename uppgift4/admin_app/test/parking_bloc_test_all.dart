import 'package:admin_app/bloc/parkings/parking_bloc.dart';
import 'package:admin_app/bloc/parkings/parking_event.dart';
import 'package:admin_app/bloc/parkings/parking_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:client_repositories/async_http_repos.dart';
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
  group('ParkingBloc', () {
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

    group('LoadParkings', () {
      final fixedTime = DateTime.parse('2025-01-11T12:03:48.000');
      final parkings = [Parking(startTime: fixedTime)];
      final vehicles = [Vehicle(licensePlate: 'ABC123', vehicleType: 'Car')];
      final parkingSpaces = [
        ParkingSpace(address: 'Main St', pricePerHour: 10)
      ];

      blocTest<ParkingBloc, ParkingState>(
        'emits ParkingLoaded with parkings, vehicles, and parkingSpaces',
        setUp: () {
          when(() => parkingRepository.getAll())
              .thenAnswer((_) async => parkings);
          when(() => vehicleRepository.getAll())
              .thenAnswer((_) async => vehicles);
          when(() => parkingSpaceRepository.getAll())
              .thenAnswer((_) async => parkingSpaces);
        },
        build: () => ParkingBloc(
          parkingRepository: parkingRepository,
          vehicleRepository: vehicleRepository,
          parkingSpaceRepository: parkingSpaceRepository,
        ),
        act: (bloc) => bloc.add(LoadParkings()),
        expect: () => [
          isA<ParkingLoading>(),
          isA<ParkingLoaded>(),
        ],
        verify: (_) {
          verify(() => parkingRepository.getAll()).called(1);
          verify(() => vehicleRepository.getAll()).called(1);
          verify(() => parkingSpaceRepository.getAll()).called(1);
        },
      );
    });

    blocTest<ParkingBloc, ParkingState>(
      'creates a new parking and reloads parkings',
      setUp: () {
        // Mock the repositories to return valid data
        when(() => vehicleRepository.getById(any())).thenAnswer(
            (_) async => Vehicle(licensePlate: 'ABC123', vehicleType: 'Car'));
        when(() => parkingSpaceRepository.getById(any())).thenAnswer(
            (_) async => ParkingSpace(address: 'Main St', pricePerHour: 10));
        when(() => parkingRepository.create(any()))
            .thenAnswer((_) async => Parking(startTime: DateTime.now()));
        when(() => parkingRepository.getAll()).thenAnswer((_) async => [
              Parking(startTime: DateTime.now(), id: 1),
            ]);
        when(() => vehicleRepository.getAll()).thenAnswer((_) async => [
              Vehicle(licensePlate: 'ABC123', vehicleType: 'Car'),
            ]);
        when(() => parkingSpaceRepository.getAll()).thenAnswer((_) async => [
              ParkingSpace(address: 'Main St', pricePerHour: 10),
            ]);
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
        verify(() => vehicleRepository.getById(any())).called(1);
        verify(() => parkingSpaceRepository.getById(any())).called(1);
        verify(() => parkingRepository.create(any())).called(1);
        verify(() => parkingRepository.getAll()).called(1);
        verify(() => vehicleRepository.getAll()).called(1);
        verify(() => parkingSpaceRepository.getAll()).called(1);
      },
    );

    group('UpdateParking', () {
      final fixedTime = DateTime.parse('2025-01-11T12:03:48.000');
      final existingParking = Parking(startTime: fixedTime, id: 1);
      final updatedParking = Parking(startTime: fixedTime, id: 1);

      blocTest<ParkingBloc, ParkingState>(
        'updates a parking session and reloads parkings',
        setUp: () {
          when(() => parkingRepository.update(any(), any()))
              .thenAnswer((_) async => updatedParking);
          when(() => parkingRepository.getAll())
              .thenAnswer((_) async => [updatedParking]);
        },
        build: () => ParkingBloc(
          parkingRepository: parkingRepository,
          vehicleRepository: vehicleRepository,
          parkingSpaceRepository: parkingSpaceRepository,
        ),
        act: (bloc) => bloc.add(UpdateParking(parking: updatedParking)),
        expect: () => [
          isA<ParkingLoading>(),
          isA<ParkingLoaded>(),
        ],
        verify: (_) {
          verify(() => parkingRepository.update(existingParking.id, any()))
              .called(1);
          verify(() => parkingRepository.getAll()).called(1);
        },
      );
    });

    group('DeleteParking', () {
      final fixedTime = DateTime.parse('2025-01-11T12:03:48.000');
      final parkingToDelete = Parking(startTime: fixedTime, id: 1);

      blocTest<ParkingBloc, ParkingState>(
        'deletes a parking session and reloads parkings',
        setUp: () {
          when(() => parkingRepository.delete(parkingToDelete.id))
              .thenAnswer((_) async => null);
          when(() => parkingRepository.getAll()).thenAnswer((_) async => []);
        },
        build: () => ParkingBloc(
          parkingRepository: parkingRepository,
          vehicleRepository: vehicleRepository,
          parkingSpaceRepository: parkingSpaceRepository,
        ),
        act: (bloc) => bloc.add(StopParking(parkingId: parkingToDelete.id)),
        expect: () => [
          isA<ParkingLoading>(),
          predicate<ParkingLoaded>((state) => state.parkings.isEmpty),
        ],
        verify: (_) {
          verify(() => parkingRepository.delete(parkingToDelete.id)).called(1);
          verify(() => parkingRepository.getAll()).called(1);
        },
      );
    });
  });
}
