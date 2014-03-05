import 'dart:async';
import 'dart:io';

import 'package:route/server.dart';

import 'configuration.dart';
import 'controller/reception.dart';
import 'database.dart';

final Pattern receptionId = new UrlPattern(r'/reception/(\d+)');

ReceptionController reception;

void setupRoutes(HttpServer server) {
  Router router = new Router(server)
    ..serve(receptionId).listen(reception.getReception)
    ..defaultStream.listen(NOTFOUND);
}

void NOTFOUND(HttpRequest request) {
  print(request.uri);
  
  request.response
    ..write('NOT FOUND')
    ..close();
}

Future setupDatabase(Configuration config) {
  Database db = new Database(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname);
  return db.start().then((_) => db);
}

void setupControllers(Database db) {
  reception = new ReceptionController(db);
}
