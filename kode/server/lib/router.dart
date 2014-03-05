import 'dart:io';

import 'package:route/server.dart';

import 'controller/reception.dart';
import 'database.dart';

final Pattern receptionId = new UrlPattern(r'/reception/(\d+)');

ReceptionController reception;

void setupRoutes(HttpServer server) {
  Router router = new Router(server)
    ..serve(receptionId).listen(reception.getReception);
}

void setupControllers() {
  String user;
  String password;
  String host;
  int port;
  String database;
  Database db = new Database(user, password, host, port, database);
  
  reception = new ReceptionController();
}
