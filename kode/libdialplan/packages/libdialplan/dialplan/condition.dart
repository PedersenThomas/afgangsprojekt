part of Dialplan;

class Condition implements DialplanNode  {
  String comment;
  List<Action> actions = new List<Action>();

  Condition.internal();

  factory Condition.fromJson(Map json) {
    Condition object = new Condition.internal();

    return object;
  }

  Map toJson() => {'actions': actions.map((a) => a.toJson())};
  XmlElement toXml() => null;
}
