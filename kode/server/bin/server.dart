import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

import '../lib/router.dart';

void main(List<String> args) {
  ArgParser parser = new ArgParser();
  ArgResults parsedArgs = registerAndParseCommandlineArguments(parser, args);
  
  if(parsedArgs['help']) {
    print(parser.getUsage());
  }
  
  setupControllers();
  int port = 8080;
  makeServer(port).then((HttpServer server) {
    setupRoutes(server);
  });
  
}

ArgResults registerAndParseCommandlineArguments(ArgParser parser, List<String> arguments) {
    parser
      ..addFlag  ('help', abbr: 'h', help: 'Output this help')
      ..addOption('authurl',         help: 'The http address for the authentication service. Example http://auth.example.com')
      ..addOption('configfile',      help: 'The JSON configuration file. Defaults to config.json')
      ..addOption('httpport',        help: 'The port the HTTP server listens on.  Defaults to 8080')
      ..addOption('dbuser',          help: 'The database user')
      ..addOption('dbpassword',      help: 'The database password')
      ..addOption('dbhost',          help: 'The database host. Defaults to localhost')
      ..addOption('dbport',          help: 'The database port. Defaults to 5432')
      ..addOption('dbname',          help: 'The database name');
  
  return parser.parse(arguments);
}

Future makeServer(int port) {
  return HttpServer.bind(InternetAddress.ANY_IP_V4, port);
}
