library organizationController;

import 'dart:io';
import 'dart:convert';

import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/organization.dart';


class OrganizationController {
  Database db;
  
  OrganizationController(Database this.db);
  
  void getOrganization(HttpRequest request) {
      int organizationId = pathParameter(request.uri, 'organization');
      
      db.getOrganization(organizationId).then((Organization organization) {
        if(organization == null) {
          request.response.statusCode = 404;
          return writeAndCloseJson(request, JSON.encode({}));
        } else {
          return writeAndCloseJson(request, JSON.encode(organizationAsJson(organization)));
        }
      }).catchError((error) {
        String body = '$error';
        writeAndCloseJson(request, body);
      });
    }
}