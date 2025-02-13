// import 'package:firebase_repositories/firebase_repositories.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:shared/shared.dart';
// import 'package:shared/bloc/vehicles/vehicles_bloc.dart';
// import 'package:shared/bloc/vehicles/vehicles_event.dart';
// import 'package:shared/bloc/vehicles/vehicles_state.dart';

// class MockVehicleRepository extends Mock implements VehicleRepository {}

// class FakeVehicle extends Fake implements Vehicle {}

// void main() {
//   setUpAll(() {
//     registerFallbackValue(FakeVehicle()); // Register fallback value for Vehicle
//   });

//   group('VehiclesBloc - CreateVehicle', () {
//     late MockVehicleRepository vehicleRepository;
//     late VehiclesBloc vehicleBloc;

//     setUp(() {
//       vehicleRepository = MockVehicleRepository();
//       vehicleBloc = VehiclesBloc(vehicleRepository: vehicleRepository);
//     });

//     tearDown(() {
//       vehicleBloc.close();
//     });

//     blocTest<VehiclesBloc, VehicleState>(
//       'creates a vehicle and reloads vehicles',
//       setUp: () {
//         // Mock the creation and fetching of vehicles
//         when(() => vehicleRepository.create(any())).thenAnswer(
//           (_) async => Vehicle(
//             id: '1', // Use String ID
//             licensePlate: 'ABC123',
//             vehicleType: 'Car',
//             owner: Person(name: 'Dan Erlandsson', ssn: '123456'),
//           ),
//         );
//         when(() => vehicleRepository.getAll()).thenAnswer((_) async => [
//               Vehicle(
//                 id: '1', // Use String ID
//                 licensePlate: 'ABC123',
//                 vehicleType: 'Car',
//                 owner: Person(name: 'Dan Erlandsson', ssn: '123456'),
//               ),
//             ]);
//       },
//       build: () => vehicleBloc,
//       act: (bloc) => bloc.add(
//         CreateVehicle(
//           licensePlate: 'ABC123',
//           vehicleType: 'Car',
//           owner: Person(name: 'Dan Erlandsson', ssn: '123456'),
//         ),
//       ),
//       expect: () => [
//         isA<VehicleLoading>(),
//         isA<VehicleLoaded>().having(
//           (state) => state.vehicles,
//           'vehicles',
//           [
//             Vehicle(
//               id: '1',
//               licensePlate: 'ABC123',
//               vehicleType: 'Car',
//               owner: Person(name: 'Dan Erlandsson', ssn: '123456'),
//             )
//           ],
//         ),
//       ],
//       verify: (_) {
//         verify(() => vehicleRepository.create(any())).called(1);
//         verify(() => vehicleRepository.getAll()).called(1);
//       },
//     );
//   });
// }
