# Admin App

This is a Flutter-based application designed to manage administrative tasks. The project uses the `go_router` package for navigation.

## Features


- **Shared Widgets**: Reusable widgets for streamlined navigation.
- **Constants for Clean Code**: Centralized constants to maintain a clean and consistent codebase.
- **Customizable**: Built with scalability and extensibility in mind.

## Libraries Required

To make the project work, the following libraries are required:

- `shared`
- `client_repositories`
- `server`

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
   git clone https://github.com/daningen/sti_flutter_2024.git
   cd sti_flutter_2024/uppgift3
   ```

2. **Navigate to each library and fetch dependencies**

   ```bash
   cd shared
   flutter pub get
   cd ../client_repositories
   flutter pub get
   cd ../server
   flutter pub get
   cd ../admin_app
   flutter pub get
   ```

3. **Run the application**

   ```bash
   flutter run
   ```

## Project Structure

```plaintext
lib/
├── main.dart          # Entry point of the application
├── app_constants.dart # Centralized constants for cleaner code
├── app_theme.dart     # Theme definitions
├── auth_service.dart  # Authentication services
├── providers/         # State management and utilities
├── utils/             # Utility functions
├── views/             # Contains all app screens/views
│   ├── start_view.dart
│   ├── parking_space_view.dart
│   ├── parking_view.dart
│   ├── user_view.dart
│   ├── start_view.dart
│   ├── statistics_view.dart
│   ├── vehicles_view.dart
│   └── ...            # Other views
├── widgets/           # Reusable widgets
│   └── bottom_action_buttons.dart.dart
```

## Navigation with `go_router`

The app uses the `go_router` package for efficient and structured navigation. Route definitions are centralized in the `routes.dart` file, making it easier to manage and scale the navigation system.

Example:

```dart
final GoRouter _router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const NavRailView(index: 0),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const NavRailView(index: 1),
      ),
```

 

## Flutter documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [go_router Package](https://pub.dev/packages/go_router)

