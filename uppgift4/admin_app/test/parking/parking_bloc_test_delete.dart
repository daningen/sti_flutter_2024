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
  group('ParkingBloc - DeleteParking', () {
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

    final fixedTime = DateTime.parse('2025-01-11T12:03:48.000');
    final parkingToDelete = Parking(startTime: fixedTime, id: 1);

    blocTest<ParkingBloc, ParkingState>(
      'deletes a parking session and reloads parkings',
      setUp: () {
        // Mock stop to succeed
        when(() => parkingRepository.stop(parkingToDelete.id))
            .thenAnswer((_) async => Future.value());

        // Mock getAll to return an empty list after deletion
        when(() => parkingRepository.getAll()).thenAnswer((_) async => []);

        // Mock vehicle and parking space repositories
        when(() => vehicleRepository.getAll()).thenAnswer(
            (_) async => [Vehicle(licensePlate: 'ABC123', vehicleType: 'Car')]);
        when(() => parkingSpaceRepository.getAll()).thenAnswer(
            (_) async => [ParkingSpace(address: 'Main St', pricePerHour: 10)]);
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
        verify(() => parkingRepository.stop(parkingToDelete.id)).called(1);
        verify(() => parkingRepository.getAll()).called(1);
        verify(() => vehicleRepository.getAll()).called(1);
        verify(() => parkingSpaceRepository.getAll()).called(1);
      },
    );
  });
}
