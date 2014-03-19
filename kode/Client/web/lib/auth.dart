library auth;

import 'dart:html';

import 'configuration.dart';


bool handleToken() {
  Uri url = Uri.parse(window.location.href);
  //TODO Save to localStorage.
  if(url.queryParameters.containsKey('settoken')) {
    config.token = url.queryParameters['settoken'];
    //Didn't work. try localStorage.
    
    //TODO ask if the user have the right premissions?
//    protocol.userInfo(configuration.token).then((protocol.Response<Map> response) {
//      Map data = response.data;
//      configuration.profile = data;
//      if(data.containsKey('id')) {
//        configuration.userId = data['id'];
//        configuration.userName = data['name'];
//        print('---------- BOB.dart --------- UserId ${configuration.userId}');
//      } else {
//        log.error('bob.dart userInfo did not contain an id');
//      }
//    });
    return true;
  } else {
    login();
    return false;
  }
}

void login() {
  String loginUrl = '${config.authBaseUrl}/token/create?returnurl=${window.location.toString()}';
  window.location.assign(loginUrl);
}
