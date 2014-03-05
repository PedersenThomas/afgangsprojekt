library Adaheads.server.configuration;

import 'dart:async';

class Configuration {
  Uri        _authUrl;
  String     _configfile = 'config.json';
  int        _httpport   = 8080;
  String     _dbuser;
  String     _dbpassword;
  String     _dbhost     = 'localhost';
  int        _dbport     = 5432;
  String     _dbname;
  
  Uri    get authUrl        => _authUrl;
  String get configfile     => _configfile;
  String get dbuser         => _dbuser;
  String get dbpassword     => _dbpassword;
  String get dbhost         => _dbhost;
  int    get dbport         => _dbport;
  String get dbname         => _dbname;
  int    get httpport       => _httpport;
  
  Future parseConfigFile() {
    
    return null;
  }
}