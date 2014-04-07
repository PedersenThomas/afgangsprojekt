part of Dialplan;

class Voicemail implements Action {
  String comment;
  String email;

  Voicemail();

  Voicemail.fromJson(Map json) {
    comment = json['comment'];

    if(json.containsKey('email')) {
      email = json['email'];
    }
  }

  Map toJson() {
    Map result = {'action': 'voicemail'};

    if(comment != null) {
      result['comment'] = comment;
    }

    if(email != null) {
      result['email'] = email;
    }

    return result;
  }
}
