# Admin App

The Admin App is a Flutter-based application designed to help administrators manage parking spaces, vehicles, users, and related data. It employs the **BLoC (Business Logic Component) pattern** for state management, ensuring a clean, testable, and maintainable architecture. The app shares components, models, and logic with the `parking_app` for consistency and reusability.

## Features

- **User Management**: Create, edit, and manage users.
- **Parking Management**: Add, edit, and view parking spaces and associated data.
- **Vehicle Management**: Manage vehicle information including creation and updates.
- **Person Management**: Handle person-related data for associations like ownership.
- **Statistics**: View application and usage statistics.
- **Reusable Widgets**: Shared components for consistent functionality.
- **Shared Logic**: Reuses BLoC files and models with the `parking_app` for streamlined development.

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
   cd sti_flutter_2024/admin_app
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
├── bloc/                         # State management using BLoC pattern
├── main.dart                     # Entry point of the application
├── providers/                    # State management utilities
│   └── theme_notifier.dart       # Theme mode handling
├── services/                     # Service classes for various operations
│   └── auth_service.dart         # Authentication service implementation
├── utils/                        # Utility functions and validators
│   └── validators.dart
├── views/                        # Contains all app views
│   ├── example_view.dart         # Example view (demo purposes)
│   ├── items_view.dart           # Item management view (not really used here, but implemented for verifying and testing code from lessons)
│   ├── login_view.dart           # Login screen
│   ├── logout_view.dart          # Logout confirmation screen
│   ├── nav_rail_view.dart        # Navigation rail for sidebar navigation
│   ├── parking/                  # Parking-related views and dialogs
│   │   ├── dialog/
│   │   │   ├── create_parking_dialog.dart
│   │   │   └── edit_parking_dialog.dart
│   │   └── parking_view.dart
│   ├── parking_spaces/           # Parking space management views
│   │   ├── dialog/
│   │   │   ├── create_parking_space_dialog.dart
│   │   │   └── edit_parking_space_dialog.dart
│   │   └── parking_space_view.dart
│   ├── person/                   # Person management views
│   │   ├── dialogs/
│   │   │   ├── create_person_dialog.dart
│   │   │   └── edit_person_dialog.dart
│   │   └── person_view.dart
│   ├── start_view.dart           # Initial startup view
│   ├── statistics_view.dart      # View for application statistics
│   ├── vehicles/                 # Vehicle management views
│   │   ├── dialogs/
│   │   │   ├── create_vehicle_dialog.dart
│   │   │   └── edit_vehicle_dialog.dart
│   │   └── vehicles_view.dart
└── widgets/                      # Reusable widgets
    ├── app_bar_actions.dart      # App bar actions for header controls
    └── bottom_action_buttons.dart # Buttons for bottom actions
```

## Shared Logic and Components

This app shares critical components with the `parking_app` to maintain consistency and reduce duplication:

- **BLoC Files**:
  - Manages state for authentication, parking, parking spaces, vehicles, and users.

- **Models**:
  - Shared models like `Person`, `Vehicle`, and `ParkingSpace` for consistent data handling.

- **Repositories**:
  - Shared repository interfaces for data management.

## BLoC Pattern

The app uses the **BLoC pattern** to manage state across various features, ensuring separation of concerns and a testable architecture. Each feature has its own BLoC, event, and state files. For example:

- **Authentication**:
  - `auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`

- **Parking Management**:
  - `parking_bloc.dart`, `parking_event.dart`, `parking_state.dart`

- **Vehicle Management**:
  - `vehicles_bloc.dart`, `vehicles_event.dart`, `vehicles_state.dart`

## Theming

The app uses `AppTheme` to maintain a consistent look and feel across all views and widgets. Themes can dynamically switch between light and dark modes using `ThemeNotifier`.

---

## Flutter Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Library Documentation](https://bloclibrary.dev/#/)

---
