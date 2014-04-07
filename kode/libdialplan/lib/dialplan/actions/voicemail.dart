part of Dialplan;

class Voicemail extends Action {
  Voicemail();

  factory Voicemail.fromJson(Map json) {
    Voicemail object = new Voicemail();

    return object;
  }

  Map toJson() => {'action': 'voicemail'};
  XmlElement toXml() => null;
}
