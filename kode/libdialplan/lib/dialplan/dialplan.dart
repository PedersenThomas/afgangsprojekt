part of Dialplan;

class Dialplan {
  int receptionId;
  String entryNumber;
  List<Extension> Extensions = new List<Extension>();

  Dialplan();

  factory Dialplan.fromJson(Map json) {
    if (json != null) {
      Dialplan plan = new Dialplan();
      if (json.containsKey('extensions')) {
        plan.Extensions.addAll((json['extensions'] as List<Map>).map((Map e) =>
            new Extension.fromJson(e)));
      }

      if (json.containsKey('number')) {
        plan.entryNumber = json['number'];
      }

      if (json.containsKey('receptionid')) {
        plan.receptionId = json['receptionid'];
      }

      return plan;
    } else {
      return null;
    }
  }

  Map toJson() => {
    'extensions': Extensions.map((Extension e) => e.toJson()).toList()
  };
}
