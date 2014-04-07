part of Dialplan;

class Condition implements DialplanNode  {
  String comment;
  String field, expression;

  List<Action> actions = new List<Action>();

  Condition();

  factory Condition.fromJson(Map json) {
    Condition object = new Condition();

    return object;
  }

  Map toJson() => {'actions': actions.map((a) => a.toJson())};

  XmlElement toXml() {
    XmlElement node = new XmlElement('condition');
      if(field != null && expression != null) {
        node
          ..attributes['field'] = field
          ..attributes['expression'] = expression;
      }
    node.children.addAll(actions.map((a) => a.toXml()));
    return node;
  }
}
