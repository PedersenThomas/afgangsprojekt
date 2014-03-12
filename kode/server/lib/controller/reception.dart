import 'dart:io';
import 'dart:convert';

import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/reception.dart';


class ReceptionController {
  Database db;
  String authorizedGroup = '';
  
  ReceptionController(Database this.db);
  
  void getReception(HttpRequest request) {
    int receptionId = pathParameter(request.uri, 'reception');
    
    db.getReception(receptionId).then((Reception reception) {
      if(reception == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, JSON.encode(receptionAsJson(reception)));
      }
    }).catchError((error) {
      String body = '$error';
      writeAndCloseJson(request, body);
    });
  }
  
  void getReceptionList(HttpRequest request) {      
      db.getReceptionList().then((List<Reception> list) {
        return writeAndCloseJson(request, JSON.encode({'receptions':listReceptionAsJson(list)}));
      }).catchError((error) {
        logger.error('$error');
        Internal_Error(request);
      });
    }
  
  void createReception(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createReception(data['full_name'], data['uri'], data['attributes'], data['extradatauri'], data['enabled']))
    .then((int id) => writeAndCloseJson(request, JSON.encode({'id': id})))
    .catchError((error) {
      logger.error(error);
      Internal_Error(request);
    });  
  }
  
  void updateReception(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateReception(pathParameter(request.uri, 'reception'), data['full_name'], data['uri'], data['attributes'], data['extradatauri'], data['enabled']))
    .then((int id) => writeAndCloseJson(request, JSON.encode({'id': id})))
    .catchError((error) {
      logger.error('updateReception url: "${request.uri}" gave error "${error}"');
      request.response.statusCode = 500;
      writeAndCloseJson(request, JSON.encode({'status': 'Internal Server Error'}));
    });  
  }
  
  void deleteReception(HttpRequest request) {
    db.deleteReception(pathParameter(request.uri, 'reception'))
    .then((int id) => writeAndCloseJson(request, JSON.encode({'id': id})))
    .catchError((error) {
      logger.error('updateReception url: "${request.uri}" gave error "${error}"');
      request.response.statusCode = 500;
      writeAndCloseJson(request, JSON.encode({'status': 'Internal Server Error'}));
    });  
  }
}
