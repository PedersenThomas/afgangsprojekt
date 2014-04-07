part of Dialplan;

class Action implements DialplanNode {
  String comment;
  String application, data;
  bool antiAction = false;

  Action();

  factory Action.fromJson(Map json) {
    Action object = new Action();

    return object;
  }

  Map toJson() => {};
  XmlElement toXml() {
    XmlElement node = new XmlElement(antiAction ? 'anti-action': 'action')
      ..attributes['application'] = application
      ..attributes['data'] = data;
    return node;
  }
}
