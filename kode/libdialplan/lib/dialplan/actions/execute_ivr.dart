part of Dialplan;

class ExecuteIvr implements Action {
  String comment;
  String ivrname;

  ExecuteIvr();

  ExecuteIvr.fromJson(Map json) {
    comment = json['comment'];

    if (json.containsKey('ivrname')) {
      ivrname = json['ivrname'];
    }
  }

  Map toJson() {
    Map result = {'action': 'executeivr'};

    if (comment != null) {
      result['comment'] = comment;
    }

    if (ivrname != null) {
      result['ivrname'] = ivrname;
    }

    return result;
  }
}
