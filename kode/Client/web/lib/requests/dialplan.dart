part of request;

Future<Dialplan> getDialplan(int receptionId) {
  final Completer completer  = new Completer();

  HttpRequest request;
  String url = '${config.serverUrl}/reception/$receptionId/dialplan?token=${config.token}';

  request = new HttpRequest()
    ..open(HttpMethod.GET, url)
    ..onLoad.listen((_) {
      if(request.status == 200) {
        completer.complete(new Dialplan.fromJson(JSON.decode(request.responseText)));
      } else {
        completer.completeError('Bad status code. ${request.status}');
      }
    })
    ..onError.listen((e) {
      //TODO logging.
      completer.completeError(e.toString());
    })
    ..send();

  return completer.future;
}
