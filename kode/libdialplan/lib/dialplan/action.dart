part of Dialplan;

class Action implements DialplanNode {
  String comment;

  Action.internal();

  factory Action.fromJson(Map json) {
    Action object = new Action.internal();

    return object;
  }

  Map toJson() => {};
  XmlElement toXml() => null;
}