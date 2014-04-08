part of Dialplan;

class Time implements Condition {
  String comment;
  String timeOfDay;
  String wday;
  String yday;

  Time();

  Time.fromJson(Map json) {
    if(json.containsKey('time-of-day')) {
      timeOfDay = json['time-of-day'];
    }

    if(json.containsKey('wday')) {
      wday = json['wday'];
    }

    if(json.containsKey('yday')) {
      yday = json['yday'];
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

    if(timeOfDay != null) {
      result['time-of-day'] = timeOfDay;
    }

    if(wday != null) {
      result['wday'] = wday;
    }

    if(yday != null) {
      result['yday'] = yday;
    }

    return result;
  }

  XmlElement toXml() {
    XmlElement node = new XmlElement('condition');

    if(timeOfDay != null && timeOfDay.isNotEmpty) {
      node.attributes['time-of-day'] = timeOfDay;
    }

    if(wday != null && wday.isNotEmpty) {
      node.attributes['wday'] = transformWdayToFreeSwitchFormat(wday);
    }

    if(yday != null && yday.isNotEmpty) {
      node.attributes['yday'] = yday;
    }

    return node;
  }

  static String transformWdayToFreeSwitchFormat(String item) {
    int count = 1;
    String result = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'].fold(item, (String text, String day) => text.replaceAll(day, (count++).toString()));

    return result;
  }
}
