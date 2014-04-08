library configuration;

import 'dart:async';
import 'dart:io';

class configuration {
  String outputFolderPath;

  Future loadFromFile(String path) {
    File file = new File(path);

    file.readAsString().then((String text) {

    }).catchError((error) {
      print('Loading configuration from "${path}" got "${error}"');
    });
  }
}