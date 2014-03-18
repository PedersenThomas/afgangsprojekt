part of request;

Future<List<Organization>> getOrganizationList() {
  final Completer completer  = new Completer();
  
  HttpRequest request;
  String url = '${config.serverUrl}/organization?token=${config.token}';

  request = new HttpRequest()
  ..open(HttpMethod.GET, url)
  ..onLoad.listen((_) {
    Map rawData = JSON.decode(request.responseText);
    List<Map> rawOrganizations = rawData['organizations'];
    completer.complete(rawOrganizations.map((r) => new Organization.fromJson(r)).toList());
  })
  ..onError.listen((e) {
    //TODO logging.
    completer.completeError(e.toString());
  })
  ..send();

  return completer.future;
}

Future<Organization> getOrganization(int organizationId) {
  final Completer completer  = new Completer();
  
  HttpRequest request;
  String url = '${config.serverUrl}/organization/$organizationId?token=${config.token}';

  request = new HttpRequest()
  ..open(HttpMethod.GET, url)
  ..onLoad.listen((_) {
    completer.complete(new Organization.fromJson(JSON.decode(request.responseText)));
  })
  ..onError.listen((e) {
    //TODO logging.
    completer.completeError(e.toString());
  })
  ..send();

  return completer.future;
}

Future createOrganization(String data) {
  final Completer completer  = new Completer();
  
  HttpRequest request;
  String url = '${config.serverUrl}/organization?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.PUT, url)
    ..onLoad.listen((_) {
      completer.complete(request.responseText);
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error.toString());
    })
    ..send(data);

  return completer.future;
}

Future updateOrganization(int organizationId, String body) {
  final Completer completer  = new Completer();
  
  HttpRequest request;
  String url = '${config.serverUrl}/organization/$organizationId?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.POST, url)
    ..onLoad.listen((_) {
      completer.complete(request.responseText);
    })
    ..onError.listen((error) {
      //TODO logging.
      completer.completeError(error.toString());
    })
    ..send(body);

  return completer.future;
}