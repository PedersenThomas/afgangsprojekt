library Adaheads.server.database;

import 'dart:async';

import 'package:postgresql/postgresql_pool.dart';
import 'package:postgresql/postgresql.dart';

class Database {
  Pool pool;
  String user, password, host, database;
  int port, minimumConnections, maximumConnections;
  
  Database(String this.user, String this.password, String this.host, int this.port, String this.database, {int this.minimumConnections: 1, int this.maximumConnections: 2});
  
  Future start() {
    String connectString = 'postgres://${user}:${password}@${host}:${port}/${database}';
    
    Pool pool = new Pool(connectString, min: minimumConnections, max: maximumConnections);
    return pool.start().then((_) => _testConnection());
  }

  Future _testConnection() => pool.connect().then((Connection conn) => conn.close());
  
  Future query(String sql, [Map parameters = null]) => pool.connect()
    .then((Connection conn) => conn.query(sql, parameters).toList()
    .whenComplete(() => conn.close()));

  Future execute(String sql, [Map parameters = null]) => pool.connect()
    .then((Connection conn) => conn.execute(sql, parameters)
    .whenComplete(() => conn.close()));
}

