part of Dialplan;

class Transfer extends Action {
  String destination;

  Transfer();

  factory Transfer.fromJson(Map json) {
    Transfer object = new Transfer();

    return object;
  }

  Map toJson() =>
      {'action': 'transfer',
       'destination' : destination};

  XmlElement toXml() {
    XmlElement element = new XmlElement(antiAction ? 'anti-action' : 'action')
      ..attributes['application'] = 'transfer'
      ..attributes['data'] = destination;
    return element;
  }
}