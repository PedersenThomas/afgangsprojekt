import 'dart:io';
import 'dart:convert';

import '../utilities/http.dart';
import '../database.dart';
import '../model.dart';

class ReceptionController {
  Database db;
  
  ReceptionController(Database this.db);
  
  void getReception(HttpRequest request) {
    print('GetReception');
    int receptionId = pathParameter(request.uri, 'reception');
    
    db.getReception(receptionId).then((Reception r) {
      return request.response
        ..write(receptionAsJson(r))
        ..close();
    }).catchError((error) {
      print(error);
      request.response
        ..write(error.toString())
        ..close();
    });
  }
}

String receptionAsJson(Reception r) {
  return '${JSON.encode({'id': r.id})}\n';
}
