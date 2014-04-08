part of Dialplan;

class Forward implements Action {
  String comment;
  String number;

  Forward();

  Forward.fromJson(Map json) {
    comment = json['comment'];

    if(json.containsKey('number')) {
      number = json['number'];
    }
  }

  Map toJson() {
    Map result = {};

    if(comment != null) {
      result['comment'] = comment;
    }

    if(number != null) {
      result['number'] = number;
    }

    return result;
  }
}
