import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';

class InternetUtils {
  static final Connectivity _connectivity = Connectivity();

  // Current connection status (true if connected, false if not)
  static bool isConnect = true;

  static Future<void> init() async {
    try {
      final initial = await _connectivity.checkConnectivity();
      _updateConnectionStatus(_normalizeResult(initial), source: 'initial');
      _connectivity.onConnectivityChanged.listen(
        (event) => _updateConnectionStatus(_normalizeResult(event), source: 'stream'),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Failed to initialize connectivity monitoring',
        name: 'InternetUtils',
        error: error,
        stackTrace: stackTrace,
      );
      isConnect = true;
    }
  }

  static List<ConnectivityResult> _normalizeResult(dynamic result) {
    if (result is List<ConnectivityResult>) {
      return result;
    }
    if (result is ConnectivityResult) {
      return [result];
    }
    return const [];
  }

  static void _updateConnectionStatus(
    List<ConnectivityResult> result, {
    required String source,
  }) {
    final connected = result.isEmpty
        ? isConnect
        : result.any((connectivity) => connectivity != ConnectivityResult.none);

    isConnect = connected;

    final resultNames = result.map((event) => event.name).toList();
    developer.log(
      'Connectivity update | source=$source | results=$resultNames | isConnect=$isConnect',
      name: 'InternetUtils',
    );
  }

  static bool get isDisconnect {
    if (isConnect) return false;

    // Optionally show toast or handle no internet UI here
    // showErrorToast(message: kInternetNotAvailable);

    return true;
  }

  /// Check if there is internet connection before executing [call]
  static void checkInternet(Function() call) {
    if (isDisconnect) return;
    call();
  }
}
