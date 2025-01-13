import 'package:admin_app/bloc/parking_spaces/parking_space_bloc.dart';
import 'package:admin_app/bloc/parking_spaces/parking_space_event.dart';
import 'package:admin_app/bloc/parking_spaces/parking_space_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

// Define Fakes
class FakeParkingSpace extends Fake implements ParkingSpace {}

// Mock Repositories
class MockParkingSpaceRepository extends Mock
    implements ParkingSpaceRepository {}

void main() {
  group('ParkingSpaceBloc - CreateParkingSpace', () {
    late MockParkingSpaceRepository parkingSpaceRepository;

    setUp(() {
      parkingSpaceRepository = MockParkingSpaceRepository();
      registerFallbackValue(FakeParkingSpace());
    });

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'creates a new parking space and reloads parking spaces',
      setUp: () {
        // Mock successful creation and fetching
        when(() => parkingSpaceRepository.create(any())).thenAnswer(
          (_) async => ParkingSpace(
            id: 1,
            address: 'Main St',
            pricePerHour: 10,
          ),
        );
        when(() => parkingSpaceRepository.getAll()).thenAnswer(
          (_) async => [
            ParkingSpace(
              id: 1,
              address: 'Main St',
              pricePerHour: 10,
            ),
          ],
        );
      },
      build: () =>
          ParkingSpaceBloc(parkingSpaceRepository: parkingSpaceRepository),
      act: (bloc) => bloc.add(CreateParkingSpace(
        address: 'Main St',
        pricePerHour: 10,
      )),
      expect: () => [
        isA<ParkingSpaceLoading>(),
        isA<ParkingSpaceLoaded>().having(
          (state) => state.parkingSpaces.length,
          'parkingSpaces length',
          1,
        ),
      ],
      verify: (_) {
        verify(() => parkingSpaceRepository.create(any())).called(1);
        verify(() => parkingSpaceRepository.getAll()).called(1);
      },
    );
  });
}