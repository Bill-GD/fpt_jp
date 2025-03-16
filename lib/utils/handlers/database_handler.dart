import 'package:mysql_client/mysql_client.dart';

class DatabaseHandler {
  static late final MySQLConnection _db;

  static MySQLConnection get db => _db;

  static Future<void> init() async {
    _db = await MySQLConnection.createConnection(
      host: const String.fromEnvironment("DATABASE_HOST"),
      port: const int.fromEnvironment('DATABASE_PORT'),
      userName: const String.fromEnvironment('DATABASE_USERNAME'),
      password: const String.fromEnvironment("DATABASE_PASSWORD"),
      databaseName: const String.fromEnvironment('DATABASE_NAME'),
    );

    await _db.connect();
  }
}
