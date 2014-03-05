import 'dart:io';

import '../utilities/http.dart';

class ReceptionController {
  
  ReceptionController() {
    
  }  
  
  void getReception(HttpRequest request) {
    int receptionId = pathParameter(request.uri, 'reception');
    
  }
}
