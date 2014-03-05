library Adaheads.server.Utilities;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

int pathParameter(Uri uri, String key) {
  try {
    return int.parse(uri.pathSegments.elementAt(uri.pathSegments.indexOf(key) + 1));
  } catch(error) {
    //log('utilities.httpserver.pathParameter failed $error Key: $key Uri: $uri');
    print('utilities.httpserver.pathParameter failed $error Key: $key Uri: $uri');
    return null;
  }
}

Future<String> extractContent(HttpRequest request) {
  Completer completer = new Completer();
  List<int> completeRawContent = new List<int>();

  request.listen((List<int> data) {
    completeRawContent.addAll(data);
  }, onError: (error) => completer.completeError(error),
     onDone: () {
    String content = UTF8.decode(completeRawContent);
    completer.complete(content);
  }, cancelOnError: true);

  return completer.future;
}
