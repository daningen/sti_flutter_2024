import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';
import 'package:admin_app/bloc/vehicles/vehicles_bloc.dart';
import 'package:admin_app/bloc/vehicles/vehicles_event.dart';
import 'package:admin_app/bloc/vehicles/vehicles_state.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

class FakeVehicle extends Fake implements Vehicle {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeVehicle());
  });

  group('VehicleBloc - CreateVehicle', () {
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
      'creates a vehicle and reloads vehicles',
      setUp: () {
        // Mock the creation and fetching of vehicles
        when(() => vehicleRepository.create(any())).thenAnswer(
          (_) async => Vehicle(
            id: 1,
            licensePlate: 'ABC123',
            vehicleType: 'Car',
          )..setOwner(Person(name: 'John Doe', ssn: '123456')),
        );
        when(() => vehicleRepository.getAll()).thenAnswer((_) async => [
              Vehicle(
                id: 1,
                licensePlate: 'ABC123',
                vehicleType: 'Car',
              )..setOwner(Person(name: 'John Doe', ssn: '123456')),
            ]);
      },
      build: () => vehicleBloc,
      act: (bloc) => bloc.add(
        CreateVehicle(
          licensePlate: 'ABC123',
          vehicleType: 'Car',
          owner: Person(name: 'John Doe', ssn: '123456'),
        ),
      ),
      expect: () => [
        VehicleLoading(),
        VehicleLoaded([
          Vehicle(
            id: 1,
            licensePlate: 'ABC123',
            vehicleType: 'Car',
          )..setOwner(Person(name: 'John Doe', ssn: '123456')),
        ]),
      ],
      verify: (_) {
        verify(() => vehicleRepository.create(any())).called(1);
        verify(() => vehicleRepository.getAll()).called(1);
      },
    );
  });
}
