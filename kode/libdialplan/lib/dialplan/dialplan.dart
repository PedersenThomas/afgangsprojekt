part of Dialplan;

class Dialplan {
  int receptionId;
  String entryNumber;
  List<Extension> Extensions = new List<Extension>();

  Dialplan();

  factory Dialplan.fromJson(Map json) {
    Dialplan plan = new Dialplan();
    Extensions.addAll((json['extensions'] as List<Map>).map((Map e) => new Extension.fromJson(e)));
    return plan;
  }

  Map toJson() {
    return {'extension': Extensions.map((e) => e.toJson())};
  }

  List<XmlElement> toXml() => Extensions.map((e) => e.toXml()).toList();
}
