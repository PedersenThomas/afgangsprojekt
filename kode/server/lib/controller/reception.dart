library receptionController;

import 'dart:io';
import 'dart:convert';

import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/reception.dart';


class ReceptionController {
  Database db;
  
  ReceptionController(Database this.db);
  
  void getReception(HttpRequest request) {
    int organizationId = pathParameter(request.uri, 'organization');
    int receptionId = pathParameter(request.uri, 'reception');
    
    db.getReception(organizationId, receptionId).then((Reception reception) {
      if(reception == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, JSON.encode(receptionAsJson(reception)));
      }
    }).catchError((error) {
      logger.error('get reception Error: "$error"');
      Internal_Error(request);
    });
  }
  
  void getReceptionList(HttpRequest request) {    
    db.getReceptionList().then((List<Reception> list) {
      return writeAndCloseJson(request, JSON.encode({'receptions':listReceptionAsJson(list)}));
    }).catchError((error) {
      logger.error('get reception list Error: "$error"');
      Internal_Error(request);
    });
  }
  
  void getOrganizationReceptionList(HttpRequest request) {
    int organizationId = pathParameter(request.uri, 'organization');
    
    db.getOrganizationReceptionList(organizationId).then((List<Reception> list) {
      return writeAndCloseJson(request, JSON.encode({'receptions':listReceptionAsJson(list)}));
    }).catchError((error) {
      logger.error('get reception list Error: "$error"');
      Internal_Error(request);
    });
  }
  
  void createReception(HttpRequest request) {
    int organizationId = pathParameter(request.uri, 'organization');
    
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createReception(organizationId, data['full_name'], data['uri'], data['attributes'], data['extradatauri'], data['enabled']))
    .then((int id) => writeAndCloseJson(request, JSON.encode({'id': id})))
    .catchError((error) {
      logger.error(error);
      Internal_Error(request);
    });  
  }
  
  void updateReception(HttpRequest request) {
    int organizationId = pathParameter(request.uri, 'organization');
    int receptionId = pathParameter(request.uri, 'reception');
    
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateReception(organizationId, receptionId, data['full_name'], data['uri'], data['attributes'], data['extradatauri'], data['enabled']))
    .then((int id) => writeAndCloseJson(request, JSON.encode({'id': id})))
    .catchError((error) {
      logger.error('updateReception url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });  
  }
  
  void deleteReception(HttpRequest request) {
    int organizationId = pathParameter(request.uri, 'organization');
    int receptionId = pathParameter(request.uri, 'reception');
    
    db.deleteReception(organizationId, receptionId)
    .then((int id) => writeAndCloseJson(request, JSON.encode({'id': id})))
    .catchError((error) {
      logger.error('deleteReception url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });  
  }
}
