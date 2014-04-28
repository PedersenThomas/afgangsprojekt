part of model;

class Phone {
  int id;
  String value;
  String kind;

  Phone();

  factory Phone.fromJson(Map json) {
    Phone object = new Phone();
    object.id = json['id'];
    object.value = json['value'];
    object.kind = json['kind'];

    return object;
  }

  Map toJson() => {
      'id': id,
      'value': value,
      'kind': kind};

}
