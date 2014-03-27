part of request;

Future updateReceptionContact(int receptionId, int contactId, String body) {
  final Completer completer  = new Completer();
  
  HttpRequest request;
  String url = '${config.serverUrl}/reception/$receptionId/contact/$contactId?token=${config.token}';

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
