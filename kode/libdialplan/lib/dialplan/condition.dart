part of Dialplan;

class Condition implements DialplanNode  {
  String comment;
  List<Action> actions = new List<Action>();

  Map toJson() => {};
  XmlElement toXml() => null;
}
