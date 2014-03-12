library Adaheads.server.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';
import 'package:postgresql/postgresql.dart';

import 'model.dart';
import 'configuration.dart';

Future<Database> setupDatabase(Configuration config) {
  Database db = new Database(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname);
  return db.start().then((_) => db);
}

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
      SELECT id, full_name, uri, attributes, extradatauri, enabled
      FROM receptions
      WHERE id = @id
    ''';
    
    Map parameters = {'id': id};
    
    return query(sql, parameters).then((rows) {
      if(rows.length != 1) {
        return null;
      } else {
        Row data = rows.first;
        return new Reception(data.id, data.full_name, data.uri, JSON.decode(data.attributes), data.extradatauri, data.enabled);
      }
    });
  }
  
  Future<List<Reception>> getReceptionList() {
    String sql = '''
      SELECT id, full_name, uri, attributes, extradatauri, enabled
      FROM receptions
    ''';

    return query(sql).then((rows) {
      List<Reception> receptions = new List<Reception>();
      for(var row in rows) {
        receptions.add(new Reception(row.id, row.full_name, row.uri, JSON.decode(row.attributes), row.extradatauri, row.enabled));
      }
      return receptions;
    });
  }
  
  Future<int> createReception(String fullName, String uri, Map attributes, String extradatauri, bool enabled) {
    String sql = '''
        INSERT INTO receptions (full_name, uri, attributes, extradatauri, enabled)
        VALUES (@full_name, @uri, @attributes, @extradatauri, @enabled)
        RETURNING id;
      ''';

      Map parameters =
        {'full_name'    : fullName,
         'uri'          : uri,
         'attributes'   : attributes == null ? '{}' : JSON.encode(attributes),
         'extradatauri' : extradatauri,
         'enabled'      : enabled};
      
    return query(sql, parameters).then((rows) {
      return rows.first.id;
    });
  }
  
  Future<int> updateReception(int id, String fullName, String uri, Map attributes, String extradatauri, bool enabled) {
    String sql = '''
        UPDATE receptions
        SET full_name=@full_name, uri=@uri, attributes=@attributes, extradatauri=@extradatauri, enabled=@enabled
        WHERE id=@id;
      ''';

      Map parameters =
        {'full_name'    : fullName,
         'uri'          : uri,
         'attributes'   : attributes == null ? '{}' : JSON.encode(attributes),
         'extradatauri' : extradatauri,
         'enabled'      : enabled,
         'id'           : id};
      
    return execute(sql, parameters);
  }

  Future<int> deleteReception(int id) {
    String sql = '''
        DELETE FROM receptions
        WHERE id=@id;
      ''';

    Map parameters = {'id': id};
    return execute(sql, parameters);
  }
}

