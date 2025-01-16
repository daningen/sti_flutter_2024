import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';
import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';
import 'package:shared/bloc/vehicles/vehicles_state.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

class FakeVehicle extends Fake implements Vehicle {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeVehicle()); // Register fallback value for Vehicle
  });

  group('VehicleBloc - UpdateVehicle', () {
    late MockVehicleRepository vehicleRepository;
    late VehiclesBloc vehicleBloc;

    setUp(() {
      vehicleRepository = MockVehicleRepository();
      vehicleBloc = VehiclesBloc(vehicleRepository: vehicleRepository);
    });

    tearDown(() {
      vehicleBloc.close();
    });

    blocTest<VehiclesBloc, VehicleState>(
      'updates a vehicle and reloads vehicles',
      setUp: () {
        // Mock the repository methods
        when(() => vehicleRepository.update(any(), any())).thenAnswer(
          (_) async => Vehicle(
            id: 1,
            licensePlate: 'UPDATED123',
            vehicleType: 'Truck',
          ),
        );
        when(() => vehicleRepository.getAll()).thenAnswer((_) async => [
              Vehicle(
                id: 1,
                licensePlate: 'UPDATED123',
                vehicleType: 'Truck',
              ),
            ]);
      },
      build: () => vehicleBloc,
      act: (bloc) => bloc.add(
        UpdateVehicle(
          vehicleId: 1,
          updatedVehicle: Vehicle(
            id: 1,
            licensePlate: 'UPDATED123',
            vehicleType: 'Truck',
          ),
        ),
      ),
      expect: () => [
        VehicleLoading(),
        isA<VehicleLoaded>(),
      ],
      verify: (_) {
        verify(() => vehicleRepository.update(
              1,
              Vehicle(
                id: 1,
                licensePlate: 'UPDATED123',
                vehicleType: 'Truck',
              ),
            )).called(1);
        verify(() => vehicleRepository.getAll()).called(1);
      },
    );
  });
}
