# Parking App

This is a Flutter-based application designed for end users to add and manage parking, vehicles and users. The project employs the **BLoC (Business Logic Component) pattern** for state management, ensuring a maintainable architecture. The app also shares parts of its BLoC implementation with the `admin_app`.

## Features

- **User Authentication**: Login and register functionalities, for now no particular control of users.
- **Parking Management**: Add, view, and manage parkings.
- **Vehicle Management**: Add and manage vehicles.
- **Reusable Widgets**: Shared components for a consistent experience.
- **Shared BLoC Logic**: The app shares BLoC files with `admin_app` to minimize code duplication.
- **ObjectBox Integration**: Uses ObjectBox for persistent local storage.
- **Consistent Look and Feel**: The app uses `AppTheme` to ensure a uniform look and feel across all views and widgets.

## Getting Started

Follow these instructions to set up and run the project on your local machine.

### Prerequisites

Ensure you have the following tools installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Code editor (e.g., [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio))
- Android Emulator or a physical device for testing

### Installation

1. **Clone the repository**

   ```bash
   git clone git@github.com:daningen/sti_flutter_2024.git
   cd sti_flutter_2024/uppgift4
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**

   ```bash
   flutter run
   ```

## Project Structure

```plaintext
lib/
├── app_constants.dart            # Constants used throughout the app
├── app_theme.dart                # App-wide theme configuration
├── auth/                         # Authentication logic
├── main.dart                     # Entry point of the application
├── providers/                    # State management utilities
│   └── theme_notifier.dart       # Theme mode handling
├── services/                     # Service classes for various operations
│   ├── auth_service.dart         # Authentication service implementation
│   └── auth_service_interface.dart
│   
├── utils/                        # Utility functions and validators
│   └── validators.dart
├── views/                        # Contains all app views
│   ├── home_page.dart            # Home screen
│   ├── login_view.dart           # Login screen
│   ├── logout_view.dart          # Logout confirmation screen
│   ├── parking/                  # Parking-related views and dialogs
│   │   ├── dialog/
│   │   │   └── create_parking_dialog.dart
│   │   ├── parking_navigation_bar.dart
│   │   └── parking_view.dart
│   ├── parking_space/            # Parking space management views
│   │   ├── parking_space_navigation_bar.dart
│   │   └── parking_space_view.dart
│   ├── person/                   # Person management views
│   │   ├── dialog/
│   │   │   └── create_person_dialog.dart
│   │   ├── person_navigation_bar.dart
│   │   └── person_view.dart
│   ├── register_view.dart        # User registration screen
│   ├── start_view.dart           # Initial startup view
│   └── vehicle/                  # Vehicle management views
│       ├── dialog/
│       │   └── create_vehicle_dialog.dart
│       ├── vehicle_navigation_bar.dart
│       └── vehicles_view.dart
├── widgets/                      # Reusable widgets
│   └── custom_bottom_nav_bar.dart
├── objectbox-model.json          # ObjectBox model definition
├── objectbox.g.dart              # Generated ObjectBox code
└── src/
    ├── models/                   # Shared models for data entities
    │   ├── bag.dart
    │   ├── item.dart
    │   ├── parking.dart
    │   ├── parking_space.dart
    │   ├── person.dart
    │   ├── result.dart
    │   └── vehicle.dart
    └── repositories/
        └── repository_interface.dart
```

## BLoC Pattern

The app uses the **BLoC pattern** to manage state across various features. This ensures separation of concerns and makes the app more scalable and testable.

### How BLoC Is Used

Each feature in the app has its own BLoC, event, and state files. For example:

- **Authentication**: `auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`
- **Vehicles**: `vehicles_bloc.dart`, `vehicles_event.dart`, `vehicles_state.dart`
- **Parking**: `parking_bloc.dart`, `parking_event.dart`, `parking_state.dart`

### Shared BLoC Logic

The app shares its BLoC files with the `admin_app` through the `shared` directory. This ensures consistent logic for managing entities like vehicles, parking spaces, and users.

For example:
- `vehicles_bloc.dart`, `vehicles_event.dart`, and `vehicles_state.dart` are used both in this app and the `admin_app` to handle vehicle-related logic.



### State Sharing

The shared BLoC implementation ensures both the `admin_app` and `parking_app` can reuse the same logic for vehicles, parking spaces, and other entities.

---

## ObjectBox Integration

The app uses **ObjectBox** for efficient local storage. It manages data persistence for entities like `Person`, `Vehicle`, and `ParkingSpace`. 

ObjectBox files:
- `objectbox-model.json`: Defines the database schema.
- `objectbox.g.dart`: Generated ObjectBox code for database operations.

---

## Navigation

The app uses a **bottom navigation bar** for easy access to primary views:
- **Home**
- **Parking**
- **Vehicles**
- **Profile**

`personNavigationBar`,`VehicleNavigationBar`,`ParkingNavigationBar` and`ParkingSpaceNavigationBar` are implemented for additional functionality within their respective views.

---

## Flutter Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Library Documentation](https://bloclibrary.dev/#/)

---
