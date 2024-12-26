# Parking App

This is a Flutter-based application designed for end users to add and manage their parking spaces. The project includes a simple login functionality and a user-friendly interface for seamless parking management.

## Features

- **User Authentication**: Login and register functionalities for secure access.
- **Parking Management**: Add, view, and manage parking spaces.
- **Reusable Widgets**: Shared components for a consistent experience.

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
   git clone <repository-url>
   cd parking_app
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
├── main.dart             # Entry point of the application
├── auth_service.dart     # Handles authentication logic
├── providers/            # State management and utilities
│   └── theme_notifier.dart
├── utils/                # Utility functions and validators
│   └── validators.dart
├── views/                # Contains all app views
│   ├── home_page.dart
│   ├── login_view.dart
│   ├── logout_view.dart
│   ├── parking_spaces_page.dart
│   ├── parking_view.dart
│   ├── register_view.dart
│   ├── start_view.dart
│   ├── user_view.dart
│   └── vehicles_view.dart
└── widgets/              # Reusable widgets
    └── custom_bottom_nav_bar.dart
```

## Login Functionality

The app includes a simple login and registration system for user authentication. Ensure the `auth_service.dart` file is configured with the necessary logic to handle authentication operations.

## Navigation

The app uses a bottom navigation bar (`custom_bottom_nav_bar.dart`) for easy access to main views like Parking, User Profile, and Home.


 
## Flutter information

- [Flutter Documentation](https://flutter.dev/docs)

