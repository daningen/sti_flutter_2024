import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
 
import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
import 'package:shared/bloc/vehicles/vehicles_event.dart';
import 'package:shared/bloc/vehicles/vehicles_state.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

void main() {
  group('VehicleBloc - DeleteVehicle', () {
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
      'deletes a vehicle and reloads vehicles',
      setUp: () {
        when(() => vehicleRepository.delete(any())).thenAnswer((_) async {
          return null;
        });
        when(() => vehicleRepository.getAll()).thenAnswer((_) async => []);
      },
      build: () => vehicleBloc,
      act: (bloc) => bloc.add(DeleteVehicle(vehicleId: 1)),
      expect: () => [
        VehicleLoading(),
        isA<VehicleLoaded>(),
      ],
      verify: (_) {
        verify(() => vehicleRepository.delete(1)).called(1);
        verify(() => vehicleRepository.getAll()).called(1);
      },
    );
  });
}
