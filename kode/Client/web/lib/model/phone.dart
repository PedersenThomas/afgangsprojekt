part of model;

class Phone {
  int id;
  String value;
  String kind;
  String description;
  String bill_type; //Landline, mobile, which foreign country
  String tag; //tags

  Phone();

  factory Phone.fromJson(Map json) {
    Phone object = new Phone();
    object.id = json['id'];
    object.value = json['value'];
    object.kind = json['kind'];
    object.description = json['description'];
    object.bill_type = json['bill_type'];
    object.tag = json['tag'];

    return object;
  }

  Map toJson() => {
    'id': id,
    'value': value,
    'kind': kind,
    'description': description,
    'bill_type': bill_type,
    'tag': tag};
}
