part of model;

class Organization {
  int id;
  String full_name;
  
  Organization();
  
  factory Organization.fromJson(Map json) {
    Organization object = new Organization();
    object.id = json['id'];
    object.full_name = json['full_name'];
    
    return object;
  }
  
  String toJson() {
    Map data = {
      'id': id,
      'full_name': full_name
    };
    
    return JSON.encode(data);
  }
}
