part of Dialplan;

class Extension implements DialplanNode {
  String comment;
  String name;
  List<Condition> Conditions = new List<Condition>();

  Map toJson() => {'conditions': Conditions.map((c) => c.toJson())};
  XmlElement toXml() => null;
}
