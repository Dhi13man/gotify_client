# Gotify Client

[![License](https://img.shields.io/github/license/dhi13man/gotify_client)](https://github.com/Dhi13man/gotify_client/blob/main/LICENSE)
[![Language](https://img.shields.io/badge/language-Dart-blue.svg)](https://dart.dev)
[![Language](https://img.shields.io/badge/language-Flutter-blue.svg)](https://flutter.dev)
[![Contributors](https://img.shields.io/github/contributors-anon/dhi13man/gotify_client?style=flat)](https://github.com/Dhi13man/gotify_client/graphs/contributors)
[![GitHub forks](https://img.shields.io/github/forks/dhi13man/gotify_client?style=social)](https://github.com/Dhi13man/gotify_client/network/members)
[![GitHub Repo stars](https://img.shields.io/github/stars/dhi13man/gotify_client?style=social)](https://github.com/Dhi13man/gotify_client/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/dhi13man/gotify_client)](https://github.com/Dhi13man/gotify_client/commits/main)
[![Build, Format, Test](https://github.com/Dhi13man/gotify_client/workflows/Build,%20Format,%20Test/badge.svg)](https://github.com/Dhi13man/gotify_client/actions)

[!["Buy Me A Coffee"](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20an%20Ego%20boost&emoji=%F0%9F%98%B3&slug=dhi13man&button_colour=FF5F5F&font_colour=ffffff&font_family=Lato&outline_colour=000000&coffee_colour=FFDD00****)](https://www.buymeacoffee.com/dhi13man)

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

   ```sh
   git clone https://github.com/yourusername/gotify_client.git
   cd gotify_client
   ```

2. Install dependencies:

   ```sh
   flutter pub get
   ```

3. Run the app:

   ```sh
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

- *Coming soon*

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
