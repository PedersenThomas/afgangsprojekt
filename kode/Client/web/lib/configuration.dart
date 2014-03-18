library configuration;

Configuration config = new Configuration._internal();

class Configuration {
  String _serverUrl = 'http://localhost:4100';
  String _token = 'feedabbadeadbeef0';
  
  String get serverUrl => _serverUrl;
  String get token => _token;
  
  Configuration._internal();
}