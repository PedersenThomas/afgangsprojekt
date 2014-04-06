part of Dialplan;

class Voicemail implements Action {
  String comment;

  Voicemail.internal();

  factory Voicemail.fromJson(Map json) {
    Voicemail object = new Voicemail.internal();

    return object;
  }

  Map toJson() => {'action': 'voicemail'};
  XmlElement toXml() => null;
}