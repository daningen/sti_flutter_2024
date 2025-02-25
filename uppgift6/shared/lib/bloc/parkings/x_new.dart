//  Future<void> _onProlongParking(x2
//     ProlongParking event, Emitter<ParkingState> emit) async {
//   try {
//     // 1. Fetch the EXISTING Parking object from Firestore using its ID.
//     final existingParking = await parkingRepository.getById(event.parkingId);

//     if (existingParking != null) {
//       debugPrint('🚗 [ParkingBloc] Prolonging parking: $existingParking');

//       // 2. Calculate the new end time.
//       final newEndTime = existingParking.endTime == null
//           ? existingParking.startTime.add(prolongationDuration)
//           : existingParking.endTime!.add(prolongationDuration);

//       // 3. Prolong parking in Firestore.
//       await parkingRepository.prolong(event.parkingId);

//       // 4. If notificationId exists, update the notification.
//       if (existingParking.notificationId != null) {
//         debugPrint(
//             '🔔 Updating notification for parking: ${existingParking.notificationId}');

//         await updateParkingNotification(
//           title: "Parking Extended",
//           content: "Your parking has been extended until $newEndTime.",
//           newEndTime: newEndTime,
//           notificationId: existingParking.notificationId!,
//         );
//       } else {
//         debugPrint("⚠️ No existing notification found for prolonging parking.");
        
//         // 🔍 Log all existing notification IDs for debugging
//         final pendingNotifications =
//             await flutterLocalNotificationsPlugin.pendingNotificationRequests();
//         final existingIds = pendingNotifications.map((n) => n.id).toList();
//         debugPrint("🔎 Existing notification IDs: $existingIds");
//       }

//       // 5. Refresh UI by triggering LoadParkings.
//       add(LoadParkings(filter: _currentFilter));
//     } else {
//       emit(ParkingError('Parking not found'));
//     }
//   } catch (e) {
//     emit(ParkingError('Failed to prolong parking: $e'));
//   }
// }