part of Dialplan;

class Extension implements DialplanNode {
  String comment;
  String name;
  List<Condition> Conditions = new List<Condition>();

  Extension({String this.name});

  factory Extension.fromJson(Map json) {
    Extension object = new Extension();
    name = json['name'];
    comment = json['comment'];
    Conditions.addAll((json['conditions'] as List).map((c) => new Condition.fromJson(c)));
    return object;
  }

  Map toJson() => {'conditions': Conditions.map((c) => c.toJson())};

  XmlElement toXml() => new XmlElement('extension')
    ..attributes['name'] = name
    ..children.addAll(Conditions.map((c) => c.toXml()));
}
