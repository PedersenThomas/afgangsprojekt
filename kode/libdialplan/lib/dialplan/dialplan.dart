part of Dialplan;

class Dialplan {
  int receptionId;
  List<Extension> Extensions = new List<Extension>();

  Dialplan.internal();

  factory Dialplan.fromJson(Map json) {
    Dialplan plan = new Dialplan.internal();

    return plan;
  }

  Map toJson() {
    return {'extension': Extensions.map((e) => e.toJson())};
  }

  List<XmlElement> toXml() => Extensions.map((e) => e.toXml()).toList();
}
