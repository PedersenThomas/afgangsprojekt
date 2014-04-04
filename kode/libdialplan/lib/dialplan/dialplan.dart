part of Dialplan;

class Dialplan extends DialplanNode {
  int receptionId;
  List<Extension> Extensions = new List<Extension>();

  factory Dialplan.fromJson(Map json) {

  }

  Map toJson() {
    return {};
  }

  XmlElement toXml() {

  }
}
