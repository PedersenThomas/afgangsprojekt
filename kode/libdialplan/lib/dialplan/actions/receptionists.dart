part of Dialplan;

class Receptionists implements Action {
  String comment;
  int sleepTime;
  String music;
  String welcomeFile;

  Receptionists();

  Receptionists.fromJson(Map json) {
    comment = json['comment'];

    if (json.containsKey('sleeptime')) {
      sleepTime = json['sleeptime'];
    }

    if (json.containsKey('music')) {
      music = json['music'];
    }

    if (json.containsKey('welcomefile')) {
      welcomeFile = json['welcomefile'];
    }
  }

  Map toJson() {
    Map result = {
      'action': 'receptionists'
    };

    if (comment != null) {
      result['comment'] = comment;
    }

    if (sleepTime != null) {
      result['sleeptime'] = sleepTime;
    }

    if (music != null) {
      result['music'] = music;
    }

    if (welcomeFile != null) {
      result['welcomefile'] = welcomeFile;
    }
    return result;
  }
}
