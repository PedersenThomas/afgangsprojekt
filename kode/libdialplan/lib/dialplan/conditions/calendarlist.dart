part of Dialplan;

class CalendarList implements Condition {
  String comment;
  String listid;

  CalendarList();

  CalendarList.fromJson(Map json) {
    if (json.containsKey('listid')) {
      listid = json['listid'];
    }

    if (json.containsKey('comment')) {
      comment = json['comment'];
    }
  }

  Map toJson() {
    Map result = {
      'condition': 'time'
    };

    if (comment != null) {
      result['comment'] = comment;
    }

    if (listid != null) {
      result['listid'] = listid;
    }

    return result;
  }
}
