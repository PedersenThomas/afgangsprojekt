part of Dialplan;

class Action implements DialplanNode {
  bool antiAction = false;
  String comment;

  Action();

  factory Action.fromJson(Map json) {
    Action object = new Action();

    return object;
  }

  Map toJson() => {};
  XmlElement toXml() => null;
}
