import 'package:admin_app/bloc/parking_spaces/parking_space_bloc.dart';
import 'package:admin_app/bloc/parking_spaces/parking_space_event.dart';
import 'package:admin_app/bloc/parking_spaces/parking_space_state.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:shared/shared.dart';

class MockParkingSpaceRepository extends Mock
    implements ParkingSpaceRepository {}

void main() {
  group('ParkingSpaceBloc - DeleteParkingSpace', () {
    late MockParkingSpaceRepository parkingSpaceRepository;
    late ParkingSpaceBloc parkingSpaceBloc;

    setUp(() {
      parkingSpaceRepository = MockParkingSpaceRepository();
      parkingSpaceBloc =
          ParkingSpaceBloc(parkingSpaceRepository: parkingSpaceRepository);

      registerFallbackValue(ParkingSpace(address: '', pricePerHour: 0));
    });

    tearDown(() {
      parkingSpaceBloc.close();
    });

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'deletes a parking space and reloads parking spaces',
      setUp: () {
        // Mock deletion and subsequent fetch
        when(() => parkingSpaceRepository.delete(any())).thenAnswer((_) async {
          return null;
        });
        when(() => parkingSpaceRepository.getAll()).thenAnswer((_) async => []);
      },
      build: () => parkingSpaceBloc,
      act: (bloc) => bloc.add(DeleteParkingSpace(id: 1)),
      expect: () => [
        ParkingSpaceLoading(),
        ParkingSpaceLoaded(parkingSpaces: const []),
      ],
      verify: (_) {
        verify(() => parkingSpaceRepository.delete(1)).called(1);
        verify(() => parkingSpaceRepository.getAll()).called(1);
      },
    );
  });
}
