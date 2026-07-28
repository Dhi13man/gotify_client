# Gotify Client

[![License](https://img.shields.io/github/license/dhi13man/gotify_client)](https://github.com/Dhi13man/gotify_client/blob/main/LICENSE)
[![Language](https://img.shields.io/badge/language-Flutter-blue.svg)](https://flutter.dev)
[![Build, Format, Test](https://github.com/Dhi13man/gotify_client/workflows/Build,%20Format,%20Test/badge.svg)](https://github.com/Dhi13man/gotify_client/actions)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/Dhi13man/gotify_client/badge)](https://scorecard.dev/viewer/?uri=github.com/Dhi13man/gotify_client)

A minimal Gotify client UI for macOS, built with Flutter.

## About

This app provides a clean and intuitive macOS interface for
[Gotify](https://gotify.net/) - a simple server for sending and receiving push
notifications. It allows you to send, receive and manage notifications from your
self-hosted Gotify server.

## Features

- Connect to your self-hosted Gotify server
- View and manage notifications
- Real-time notification delivery via WebSockets
- Local notification support
- Secure credential storage
- Clean, intuitive user interface

## Installation

### Prerequisites

- Flutter SDK (>=3.38.1, with Dart >=3.10.0)
- Xcode with macOS development tools
- A running Gotify server instance

### Building from source

1. Clone the repository:

   ```sh
   git clone https://github.com/Dhi13man/gotify_client.git
   cd gotify_client
   ```

2. Install dependencies:

   ```sh
   flutter pub get
   ```

3. Run the app:

   ```sh
   flutter run -d macos
   ```

## Usage

1. On first launch, enter your Gotify server URL and credentials
2. Once connected, you'll receive notifications in real-time
3. View message history and manage application subscriptions

## Dependencies

See [pubspec.yaml](pubspec.yaml) for the current application and development
dependency constraints.

## Support

If this project is useful, you can
[support its maintenance](https://www.buymeacoffee.com/dhi13man).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. See
[CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.
