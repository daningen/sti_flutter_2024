# Shared Logic Overview

This project shares its **BLoC (Business Logic Component)** implementation and other critical components across multiple applications, including `parking_app` and `admin_app`. By centralizing these features, the project ensures consistent functionality and reduces duplication.

## Shared Components

### BLoC Logic

The shared BLoC files manage state for various features:

- **Authentication**:
  - `auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`
  - Manages user login and registration.

- **Parking**:
  - `parking_bloc.dart`, `parking_event.dart`, `parking_state.dart`
  - Handles parking-related operations.

- **Parking Spaces**:
  - `parking_space_bloc.dart`, `parking_space_event.dart`, `parking_space_state.dart`
  - Provides logic for managing parking space entities.

- **Vehicles**:
  - `vehicles_bloc.dart`, `vehicles_event.dart`, `vehicles_state.dart`
  - Manages adding, editing, and removing vehicles.

- **Person Management**:
  - `person_bloc.dart`, `person_event.dart`, `person_state.dart`
  - Handles person data for ownership and associations.

- **Statistics**:
  - `statistics_bloc.dart`, `statistics_event.dart`, `statistics_state.dart`
  - Tracks and displays application statistics.

### Shared Models

The `src/models` directory contains shared data models:

- `Person`: Represents users or owners.
- `Vehicle`: Represents vehicles associated with users.
- `ParkingSpace`: Represents parking space entities.
- `Parking`: Represents parking data.
- Other entities: `Bag`, `Item`, `Result`.

### Shared Repositories

The `src/repositories` directory includes reusable repository interfaces for accessing and managing data:

- `repository_interface.dart`: Defines the structure for repositories.

## Benefits of Sharing Logic

- **Consistency**: Ensures the same logic is applied across `parking_app` and `admin_app`.
- **Maintainability**: Reduces code duplication, making it easier to update and debug.
- **Scalability**: Centralized logic can be extended for future applications.

## Example Usage

### Vehicles

The shared `VehiclesBloc` is used in the `vehicles_view.dart` file:

```dart
final _vehicleBloc = VehiclesBloc(vehicleRepository: VehicleRepository());

@override
void initState() {
  super.initState();
  _vehicleBloc.add(LoadVehicles()); // Load vehicles on initialization
}

BlocProvider<VehiclesBloc>(
  create: (context) => _vehicleBloc,
  child: BlocBuilder<VehiclesBloc, VehicleState>(
    builder: (context, state) {
      if (state is VehicleLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is VehicleLoaded) {
        return ListView.builder(
          itemCount: state.vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = state.vehicles[index];
            return ListTile(
              title: Text(vehicle.licensePlate),
            );
          },
        );
      } else if (state is VehicleError) {
        return Center(child: Text('Error: ${state.message}'));
      }
      return const SizedBox();
    },
  ),
);
```


---
