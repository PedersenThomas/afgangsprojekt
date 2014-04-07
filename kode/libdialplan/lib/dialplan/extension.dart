part of Dialplan;

class Extension {
  String comment;
  String name;
  List<Condition> conditions = new List<Condition>();
  List<Action> actions = new List<Action>();

  Extension({String this.name});

  factory Extension.fromJson(Map json) {
    Extension object = new Extension()
      ..name = json['name']
      ..comment = json['comment']
      ..conditions.addAll((json['conditions'] as List).map((c) => new Condition.fromJson(c)))
      ..actions.addAll((json['actions'] as List).map((c) => new Action.fromJson(c)));
    return object;
  }

  Map toJson() {
    Map result =
      {'name': name,
       'conditions': conditions.map((c) => c.toJson()).toList(),
       'actions': actions.map((c) => c.toJson()).toList()};

    return result;
  }
}
