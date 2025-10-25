import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class NetworkUtils {
  static final NetworkUtils _instance = NetworkUtils._internal();
  factory NetworkUtils() => _instance;
  
  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio();

  NetworkUtils._internal() {
    // Configure Dio timeouts
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
    _dio.options.followRedirects = false;
    _dio.options.validateStatus = (status) => true; // interpret statuses manually
  }

  /// Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      // If no connectivity at all
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Probe multiple lightweight endpoints to reduce false negatives
      const probeUrls = <String>[
        'https://www.gstatic.com/generate_204',
        'https://clients3.google.com/generate_204',
        'https://www.google.com/generate_204',
        'https://apple.com',
      ];

      for (final url in probeUrls) {
        try {
          Response<dynamic> response;
          try {
            response = await _dio.head(url);
          } catch (_) {
            response = await _dio.get(url);
          }
          final code = response.statusCode ?? 0;
          // Accept common success/portal statuses
          if (code == 204 || code == 200 || code == 301 || code == 302) {
            return true;
          }
        } catch (_) {
          // try next url
        }
      }

      // If some connectivity is reported but probes failed, be permissive
      return true;
    } catch (_) {
      // On unexpected errors, be permissive if any connectivity is reported
      try {
        final status = await _connectivity.checkConnectivity();
        return status != ConnectivityResult.none;
      } catch (_) {
        return false;
      }
    }
  }

  /// Check connectivity status
  Future<ConnectivityResult> getConnectivityStatus() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;

  /// Get user-friendly connectivity message
  String getConnectivityMessage(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'Connected via WiFi';
      case ConnectivityResult.mobile:
        return 'Connected via Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Connected via Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Connected via Bluetooth';
      case ConnectivityResult.vpn:
        return 'Connected via VPN';
      case ConnectivityResult.other:
        return 'Connected via Other';
      case ConnectivityResult.none:
        return 'No Internet Connection';
    }
  }
}
