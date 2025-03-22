# Gotify Client

A minimal, cross-platform Gotify client UI built with Flutter.

## About

This app provides a clean and intuitive mobile interface for [Gotify](https://gotify.net/) - a simple server for sending and receiving push notifications. It allows you to receive and manage notifications from your self-hosted Gotify server on both Android and iOS devices.

## Features

- Connect to your self-hosted Gotify server
- View and manage notifications
- Real-time notification delivery via WebSockets
- Local notification support
- Secure credential storage
- Clean, intuitive user interface

## Installation

### Prerequisites

- Flutter SDK (>=2.19.0)
- Android SDK or Xcode (for iOS builds)
- A running Gotify server instance

### Building from source

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/gotify_client.git
   cd gotify_client
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Run the app:
   ```
   flutter run
   ```

## Usage

1. On first launch, enter your Gotify server URL and credentials
2. Once connected, you'll receive notifications in real-time
3. View message history and manage application subscriptions

## Dependencies

- Flutter
- http: ^0.13.5
- provider: ^6.0.5
- shared_preferences: ^2.1.0
- flutter_secure_storage: ^8.0.0
- flutter_local_notifications: ^14.1.0
- web_socket_channel: ^3.0.2
- intl: ^0.18.0
- logging: ^1.3.0

## Screenshots

*Coming soon*

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
