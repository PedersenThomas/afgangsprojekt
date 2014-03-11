import 'dart:io';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'controller/reception.dart';
import 'database.dart';
import 'utilities/http.dart';
import 'utilities/logger.dart';

final Pattern anyThing = new UrlPattern(r'/(.*)');
final Pattern receptionIdUrl = new UrlPattern(r'/reception/(\d+)');
final Pattern receptionUrl = new UrlPattern(r'/reception(/?)');
final List<Pattern> Serviceagents = [receptionIdUrl, receptionUrl];

ReceptionController reception;

void setupRoutes(HttpServer server, Configuration config, Logger logger) {
  Router router = new Router(server)
    ..filter(anyThing, (HttpRequest req) => logHit(req, logger))
    ..filter(matchAny(Serviceagents), (HttpRequest req) => authorized(req, config.authUrl, groupName: 'Serviceagent'))
    ..serve(receptionIdUrl, method: 'GET').listen(reception.getReception)
    ..serve(receptionUrl, method: 'GET').listen(reception.getReceptionList)
    ..serve(receptionUrl, method: 'PUT').listen(reception.createReception)
    ..serve(receptionIdUrl, method: 'POST').listen(reception.updateReception)
    ..defaultStream.listen(NOTFOUND);
}

void setupControllers(Database db) {
  reception = new ReceptionController(db);
}
