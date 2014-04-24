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

  String toJson() {
    Map data = {
      'id': id,
      'value': value,
      'kind': kind
    };

    return JSON.encode(data);
  }
}
