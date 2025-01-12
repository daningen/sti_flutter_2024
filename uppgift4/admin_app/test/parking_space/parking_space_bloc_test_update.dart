import 'package:admin_app/bloc/parking_spaces/parking_space_bloc.dart';
import 'package:admin_app/bloc/parking_spaces/parking_space_event.dart';
import 'package:admin_app/bloc/parking_spaces/parking_space_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

// Mock Repositories
class MockParkingSpaceRepository extends Mock
    implements ParkingSpaceRepository {}

// Define Fakes
class FakeParkingSpace extends Fake implements ParkingSpace {}

void main() {
  group('ParkingSpaceBloc - UpdateParkingSpace', () {
    late MockParkingSpaceRepository parkingSpaceRepository;

    setUp(() {
      parkingSpaceRepository = MockParkingSpaceRepository();
      registerFallbackValue(FakeParkingSpace());
    });

    final updatedParkingSpace = ParkingSpace(
      id: 1,
      address: 'Updated St',
      pricePerHour: 15,
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'updates a parking space and reloads parking spaces',
      setUp: () {
        when(() =>
                parkingSpaceRepository.update(any<int>(), any<ParkingSpace>()))
            .thenAnswer((_) async => updatedParkingSpace);
        when(() => parkingSpaceRepository.getAll()).thenAnswer((_) async => [
              updatedParkingSpace,
            ]);
      },
      build: () =>
          ParkingSpaceBloc(parkingSpaceRepository: parkingSpaceRepository),
      act: (bloc) => bloc.add(EditParkingSpace(
        id: updatedParkingSpace.id,
        address: updatedParkingSpace.address,
        pricePerHour: updatedParkingSpace.pricePerHour,
      )),
      expect: () => [
        ParkingSpaceLoading(),
        ParkingSpaceLoaded(parkingSpaces: [updatedParkingSpace]),
      ],
      verify: (_) {
        // Use `any` for flexible verification
        verify(() => parkingSpaceRepository.update(
              updatedParkingSpace.id,
              any(),
            )).called(1);

        verify(() => parkingSpaceRepository.getAll()).called(1);
      },
    );
  });
}
