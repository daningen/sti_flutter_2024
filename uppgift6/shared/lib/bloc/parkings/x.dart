

// Future<void> _onProlongParking(x1
//       ProlongParking event, Emitter<ParkingState> emit) async {
//     try {
//       // 1. Fetch the EXISTING Parking object from Firestore using its ID.
//       final existingParking = await parkingRepository.getById(event.parkingId);

//       // 2. Check if the parking exists.  This is important!
//       if (existingParking != null) {
//         debugPrint('🚗 [ParkingBloc] Prolonging parking: $existingParking');

//         // 3. Calculate the new end time.
//         final newEndTime = existingParking.endTime == null
//             ? existingParking.startTime.add(prolongationDuration)
//             : existingParking.endTime!.add(prolongationDuration);

//         // 4. Create a *new* Parking object using copyWith, including the existing notificationId.
//         final updatedParking = existingParking.copyWith(
//           endTime: newEndTime,
//           notificationId: existingParking
//               .notificationId, // Copy the existing notificationId
//         );

//         debugPrint(
//             '🚗 [ParkingBloc] Updated parking: $updatedParking'); // Debug print

//         // 5. Update the Parking object in Firestore using the *ID* and the *updatedParking* object.
//         // await parkingRepository.update(
//         //     event.parkingId, updatedParking); // Use the ID!

//         await parkingRepository.prolong(event.parkingId);

//         // 6. Trigger a LoadParkings event to refresh the UI.
//         add(LoadParkings(filter: _currentFilter));
//       } else {
//         // 7. Handle the case where the Parking object is not found.
//         emit(ParkingError('Parking not found'));
//       }
//     } catch (e) {
//       // 8. Handle any errors.
//       emit(ParkingError('Failed to prolong parking: $e'));
//     }
//   }

  