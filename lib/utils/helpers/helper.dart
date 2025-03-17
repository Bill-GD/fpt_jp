import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' show Response, get;

import '../handlers/log_handler.dart';
import 'globals.dart';

Future<bool> checkInternetConnection([List<ConnectivityResult>? result]) async {
  final connectivityResult = result ?? await Connectivity().checkConnectivity();
  final isInternetConnected = !connectivityResult.contains(ConnectivityResult.none);
  LogHandler.log('Internet connected: $isInternetConnected');
  return isInternetConnected;
}

Future<Response> githubAPIQuery(String query) {
  const baseApiUrl = 'https://api.github.com/repos/Bill-GD/fpt_jp';
  LogHandler.log('Querying from GitHub: $query');
  return get(
    Uri.parse('$baseApiUrl$query'),
    headers: {'Authorization': 'Bearer ${Globals.githubToken}'},
  );
}
