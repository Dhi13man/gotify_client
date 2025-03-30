import 'package:gotify_client/clients/gotify_client.dart';
import 'package:gotify_client/clients/http_client_impl.dart';
import 'package:gotify_client/models/exceptions.dart';

/// Factory for creating and managing Gotify client instances
class ClientFactory {
  static final Map<String, GotifyClient> _clients = {};

  /// Returns a client for the specified server URL, creating a new one if needed
  ///
  /// @throws [ClientValidationException] if serverUrl is invalid
  static GotifyClient getClient(String serverUrl) {
    if (serverUrl.isEmpty) {
      throw const ClientValidationException('Server URL cannot be empty');
    }

    final String normalizedUrl = _normalizeUrl(serverUrl);
    if (!_clients.containsKey(normalizedUrl)) {
      _clients[normalizedUrl] = GotifyHttpClient(normalizedUrl);
    }
    return _clients[normalizedUrl]!;
  }

  /// Normalizes server URL by removing trailing slashes
  static String _normalizeUrl(String url) {
    return url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  /// Close and remove a specific client instance
  static Future<void> closeClient(String serverUrl) async {
    final String normalizedUrl = _normalizeUrl(serverUrl);
    if (_clients.containsKey(normalizedUrl)) {
      await _clients[normalizedUrl]!.close();
      _clients.remove(normalizedUrl);
    }
  }

  /// Close and clear all client instances (useful for testing or on logout)
  static Future<void> clearClients() async {
    // Close all client instances to clean up resources
    for (final client in _clients.values) {
      await client.close();
    }
    _clients.clear();
  }
}
