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

Map<String, dynamic> parseVersionString(String tag) {
  final map = {
    'tag': tag,
    'isDev': false,
    'devBuild': 0,
    'major': 0,
    'minor': 0,
    'patch': 0,
  };
  List<String> split = (map['tag'] as String).split('_dev_');
  map['isDev'] = (map['tag'] as String).contains('_dev_');
  if (map['isDev'] == true) map['devBuild'] = int.parse(split[1]);
  map['major'] = int.parse(split.first.split('.')[0]);
  map['minor'] = int.parse(split.first.split('.')[1]);
  map['patch'] = int.parse(split.first.split('.')[2]);
  return map;
}
