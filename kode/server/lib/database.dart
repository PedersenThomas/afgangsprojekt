library Adaheads.server.database;

import 'dart:async';

import 'package:postgresql/postgresql_pool.dart';
import 'package:postgresql/postgresql.dart';

import 'model.dart';

class Database {
  Pool pool;
  String user, password, host, name;
  int port, minimumConnections, maximumConnections;
  
  Database(String this.user, String this.password, String this.host, int this.port, String this.name, {int this.minimumConnections: 1, int this.maximumConnections: 10});
  
  Future start() {
    String connectString = 'postgres://${user}:${password}@${host}:${port}/${name}';
    
    pool = new Pool(connectString, min: minimumConnections, max: maximumConnections);
    return pool.start().then((_) => _testConnection());
  }

  Future _testConnection() => pool.connect().then((Connection conn) => conn.close());
  
  Future<List<Row>> query(String sql, [Map parameters = null]) => pool.connect()
    .then((Connection conn) => conn.query(sql, parameters).toList()
    .whenComplete(() => conn.close()));
  
  Future<int> execute(String sql, [Map parameters = null]) => pool.connect()
    .then((Connection conn) => conn.execute(sql, parameters)
    .whenComplete(() => conn.close()));

  Future<Reception> getReception(int id) {
    String sql = '''
      SELECT id
      FROM receptions
      WHERE id = @id
    ''';
    
    Map parameters = {'id': id};
    
    return query(sql, parameters).then((rows) {
      if(rows.length != 1) {
        return null;
      } else {
        Row data = rows.first;
        return new Reception(data.id);
      }
    });
  }
}

