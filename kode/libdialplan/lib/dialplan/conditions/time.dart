part of Dialplan;

class Time implements Condition {
  String comment;
  String minute_of_day;
  String wday;

  Time();

  Time.fromJson(Map json) {
    if(json.containsKey('minute-of-day')) {
      minute_of_day = json['minute-of-day'];
    }

    if(json.containsKey('wday')) {
      wday = json['wday'];
    }

    if(json.containsKey('comment')) {
      comment = json['comment'];
    }
  }

  Map toJson() {
    Map result = {'condition': 'time'};

    if(comment != null) {
      result['comment'] = comment;
    }

    if(minute_of_day != null) {
      result['minute-of-day'] = minute_of_day;
    }

    if(wday != null) {
      result['wday'] = wday;
    }
    return result;
  }

  XmlElement toXml() {
    XmlElement node = new XmlElement('condition');

    if(minute_of_day != null && minute_of_day.isNotEmpty) {
      node.attributes['minute-of-day'] = minute_of_day;
    }

    if(wday != null && wday.isNotEmpty) {
      node.attributes['wday'] = transformWdayToFreeSwitchFormat(wday);
    }

    return node;
  }

  static String transformWdayToFreeSwitchFormat(String item) {
    int count = 1;
    String result = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'].fold(item, (String text, String day) => text.replaceAll(day, (count++).toString()));

    return result;
  }
}
