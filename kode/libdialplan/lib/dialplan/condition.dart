part of Dialplan;

class Condition implements JsonSerializable {
  String comment;
  Condition();

  factory Condition.fromJson(Map json) {
    switch (json['condition'] as String) {
      case 'time':
        return new Time.fromJson(json);
        break;

      default:
        throw ('Unknown condition "${json['condition']}"');
    }
  }

  Map toJson() => null;
}
