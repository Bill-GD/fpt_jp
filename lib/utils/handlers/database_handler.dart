import 'package:mysql_client/exception.dart';
import 'package:mysql_client/mysql_client.dart';

import 'log_handler.dart';

class DatabaseHandler {
  static late MySQLConnection _db;

  static Future<void> init() async {
    await _connect();
    LogHandler.log('Database initialized');
  }

  static Future<void> _connect() async {
    _db = await MySQLConnection.createConnection(
      host: const String.fromEnvironment("DATABASE_HOST"),
      port: const int.fromEnvironment('DATABASE_PORT'),
      userName: const String.fromEnvironment('DATABASE_USERNAME'),
      password: const String.fromEnvironment("DATABASE_PASSWORD"),
      databaseName: const String.fromEnvironment('DATABASE_NAME'),
    );

    await _db.connect();
  }

  /// A wrapper for [MySQLConnection]'s [execute] method to handle disconnection.
  static Future<IResultSet> execute(
    String query, [
    Map<String, dynamic>? params,
    bool iterable = false,
  ]) async {
    IResultSet? result;
    try {
      result = await _db.execute(query, params, iterable);
    } on Exception catch (e) {
      if (e is MySQLClientException) {
        LogHandler.log('Database connection is reset. Re-connecting...');
        await _connect();
      }
    } finally {
      result ??= await _db.execute(query, params, iterable);
    }
    return result;
  }

  static Future<void> close() async {
    await _db.close();
  }
}
