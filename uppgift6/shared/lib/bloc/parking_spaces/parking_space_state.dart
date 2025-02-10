  import 'package:equatable/equatable.dart';
  import 'package:shared/shared.dart';  

  abstract class ParkingSpaceState extends Equatable {
    @override
    List<Object?> get props => [];
  }

  class ParkingSpaceInitial extends ParkingSpaceState {}

  class ParkingSpaceLoading extends ParkingSpaceState {}

  class ParkingSpaceLoaded extends ParkingSpaceState {
    final List<ParkingSpace> parkingSpaces;
    final ParkingSpace? selectedParkingSpace;

    ParkingSpaceLoaded({
      required this.parkingSpaces,
      this.selectedParkingSpace,
    });

    @override
    List<Object?> get props => [parkingSpaces, selectedParkingSpace];
  }


  class ParkingSpaceError extends ParkingSpaceState {
    final String message;

    ParkingSpaceError({required this.message});

    @override
    List<Object?> get props => [message];
  }
