part of Dialplan;

class Extension implements DialplanNode {
  String comment;
  String name;
  List<Condition> Conditions = new List<Condition>();

  Extension.internal();

  factory Extension.fromJson(Map json) {
    Extension object = new Extension.internal();

    return object;
  }

  Map toJson() => {'conditions': Conditions.map((c) => c.toJson())};
  XmlElement toXml() => null;
}
