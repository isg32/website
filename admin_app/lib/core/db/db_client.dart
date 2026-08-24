import 'package:postgres/postgres.dart';

/// Direct connection to the Neon Postgres database using the scoped
/// `app_writer` role (SELECT/INSERT/UPDATE/DELETE only — never DDL; schema
/// changes are owned entirely by the SvelteKit side's Drizzle migrations).
///
/// Credentials are injected at build time via --dart-define, never
/// hardcoded here — see admin_app/README.md for the exact command.
class DbClient {
  DbClient._();

  static final DbClient instance = DbClient._();

  static const _host = String.fromEnvironment('DB_HOST');
  static const _port = int.fromEnvironment('DB_PORT', defaultValue: 5432);
  static const _database = String.fromEnvironment('DB_DATABASE', defaultValue: 'neondb');
  static const _username = String.fromEnvironment('DB_USERNAME', defaultValue: 'app_writer');
  static const _password = String.fromEnvironment('DB_PASSWORD');

  Connection? _connection;

  Future<Connection> _open() async {
    final existing = _connection;
    if (existing != null && existing.isOpen) return existing;

    if (_host.isEmpty || _password.isEmpty) {
      throw StateError(
        'DB_HOST/DB_PASSWORD were not provided at build time. '
        'Run with --dart-define=DB_HOST=... --dart-define=DB_PASSWORD=... '
        '(see admin_app/README.md).',
      );
    }

    final connection = await Connection.open(
      Endpoint(
        host: _host,
        port: _port,
        database: _database,
        username: _username,
        password: _password,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.require),
    );
    _connection = connection;
    return connection;
  }

  /// Runs a query and returns each row as a column-name-keyed map.
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    Map<String, dynamic> parameters = const {},
  ]) async {
    final connection = await _open();
    final result = await connection.execute(Sql.named(sql), parameters: parameters);
    return result.map((row) => row.toColumnMap()).toList();
  }

  /// Runs a statement (INSERT/UPDATE/DELETE) and returns affected rows as
  /// column-name-keyed maps (relies on a RETURNING clause for inserts/updates
  /// that need the resulting row back).
  Future<List<Map<String, dynamic>>> execute(
    String sql, [
    Map<String, dynamic> parameters = const {},
  ]) async {
    final connection = await _open();
    final result = await connection.execute(Sql.named(sql), parameters: parameters);
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
