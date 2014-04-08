library configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Configuration {
  String localContextPath;
  String publicPath;

  Future loadFromFile(String path) {
    File file = new File(path);

    return file.readAsString().then((String text) {
      Map rawConfig = JSON.decode(text);
      parseMap(rawConfig);
    }).catchError((error) {
      print('Loading configuration from "${path}" got "${error}"');
    });
  }

  void parseMap(Map configMap) {
    if(configMap.containsKey('localContextPath')) {
      localContextPath = configMap['localContextPath'];
    }

    if(configMap.containsKey('publicPath')) {
      publicPath = configMap['publicPath'];
    }

    check();
  }

  /**
   * Checks if the configuration is valid.
   */
  void check() {
    if(localContextPath == null) {
      throw new InvalidConfigurationException('localContextPath is null');
    } else {
      Directory file = new Directory(localContextPath);
      if(!file.existsSync()) {
        throw new InvalidConfigurationException('localContextPath: "${localContextPath}" does not exists');
      }
    }

    if(publicPath == null) {
      throw new InvalidConfigurationException('publicPath is null');
    } else {
      Directory file = new Directory(publicPath);
      if(!file.existsSync()) {
        throw new InvalidConfigurationException('publicPath: "${publicPath}" does not exists');
      }
    }
  }
}

class InvalidConfigurationException implements Exception {
  final String msg;
  const InvalidConfigurationException([this.msg]);

  String toString() => msg == null ? 'InvalidConfigurationException' : msg;
}
