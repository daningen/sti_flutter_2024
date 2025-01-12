import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';
import 'package:admin_app/bloc/vehicles/vehicle_bloc.dart';
import 'package:admin_app/bloc/vehicles/vehicle_event.dart';
import 'package:admin_app/bloc/vehicles/vehicle_state.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

class FakeVehicle extends Fake implements Vehicle {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeVehicle());
  });

  group('VehicleBloc - CreateVehicle', () {
    late MockVehicleRepository vehicleRepository;
    late VehicleBloc vehicleBloc;

    setUp(() {
      vehicleRepository = MockVehicleRepository();
      vehicleBloc = VehicleBloc(vehicleRepository: vehicleRepository);
    });

    tearDown(() {
      vehicleBloc.close();
    });

    blocTest<VehicleBloc, VehicleState>(
      'creates a vehicle and reloads vehicles',
      setUp: () {
        // Mock the creation and fetching of vehicles
        when(() => vehicleRepository.create(any())).thenAnswer(
          (_) async =>
              Vehicle(id: 1, licensePlate: 'ABC123', vehicleType: 'Car'),
        );
        when(() => vehicleRepository.getAll()).thenAnswer((_) async => [
              Vehicle(id: 1, licensePlate: 'ABC123', vehicleType: 'Car'),
            ]);
      },
      build: () => vehicleBloc,
      act: (bloc) =>
          bloc.add(CreateVehicle(licensePlate: 'ABC123', vehicleType: 'Car')),
      expect: () => [
        VehicleLoading(),
        VehicleLoaded([
          Vehicle(id: 1, licensePlate: 'ABC123', vehicleType: 'Car'),
        ]),
      ],
      verify: (_) {
        verify(() => vehicleRepository.create(any())).called(1);
        verify(() => vehicleRepository.getAll()).called(1);
      },
    );
  });
}
