import 'package:connectivity_plus/connectivity_plus.dart';

import '../handlers/log_handler.dart';

Future<bool> checkInternetConnection([List<ConnectivityResult>? result]) async {
  final connectivityResult = result ?? await Connectivity().checkConnectivity();
  final isInternetConnected = !connectivityResult.contains(ConnectivityResult.none);
  LogHandler.log('Internet connected: $isInternetConnected');
  return isInternetConnected;
}
