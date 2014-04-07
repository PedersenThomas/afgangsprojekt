part of Dialplan;

class DestinationNumber extends Condition {
  String destination;

  DestinationNumber();

  factory DestinationNumber.fromJson(Map json) {
    DestinationNumber object = new DestinationNumber();

    return object;
  }

  Map toJson() =>
      {'condition': 'destination_number',
       'destination' : destination};

  XmlElement toXml() {
    XmlElement element = new XmlElement('condition')
      ..attributes['field'] = 'destination_number'
      ..attributes['expression'] = destination;
    return element;
  }
}