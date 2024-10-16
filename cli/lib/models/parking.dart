import 'package:cli/models/parking_space.dart';
import 'package:cli/models/vehicle.dart';

class Parking {
  final Vehicle vehicle;
  final ParkingSpace parkingSpace;
  final DateTime startTime;
  final DateTime? endTime;

  Parking(
      {required this.vehicle,
      required this.parkingSpace,
      required this.startTime,
      required this.endTime});
}
