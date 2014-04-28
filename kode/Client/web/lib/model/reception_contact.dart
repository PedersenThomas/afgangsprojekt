part of model;

class ReceptionContact {
  int contactId;
  bool contactEnabled;
  int receptionId;
  bool wantsMessages;
  int distributionListId;
  List<Phone> phoneNumbers;

  Map get attributes {
    return {
      'department': department,
      'info': info,
      'position': position,
      'relations': relations,
      'responsibility': responsibility,
      'backup': priorityListToJson(backup),
      'emailaddresses': priorityListToJson(emailaddresses),
      'handling': priorityListToJson(handling),
      //'telephonenumbers': priorityListToJson(telephonenumbers),
      'workhours': priorityListToJson(workhours),
      'tags': tags
    };
  }

  List<String> backup;
  List<String> emailaddresses;
  List<String> handling;
  //List<String> telephonenumbers;
  List<String> workhours;
  List<String> tags;

  String department;
  String info;
  String position;
  String relations;
  String responsibility;

  ReceptionContact();

  factory ReceptionContact.fromJson(Map json) {
    ReceptionContact object = new ReceptionContact()
      ..contactId = json['contact_id']
      ..contactEnabled = json['contact_enabled']
      ..receptionId = json['reception_id']
      ..wantsMessages = json['wants_messages']
      ..distributionListId = json['distribution_list_id']
      ..phoneNumbers = (json['contact_phonenumbers'] as List<Map>).map((Map json) => new Phone.fromJson(json)).toList();

    if (json.containsKey('attributes')) {
      Map attributes = json['attributes'];

      object
          ..backup = priorityListFromJson(attributes, 'backup')
          ..emailaddresses = priorityListFromJson(attributes, 'emailaddresses')
          ..handling = priorityListFromJson(attributes, 'handling')
//          ..telephonenumbers = priorityListFromJson(attributes, 'telephonenumbers')
          ..workhours = priorityListFromJson(attributes, 'workhours')
          ..tags = attributes['tags']

          ..department = stringFromJson(attributes, 'department')
          ..info = stringFromJson(attributes, 'info')
          ..position = stringFromJson(attributes, 'position')
          ..relations = stringFromJson(attributes, 'relations')
          ..responsibility = stringFromJson(attributes, 'responsibility');
    }

    return object;
  }

  String toJson() {
    Map data = {
      'contact_id': contactId,
      'reception_id': receptionId,
      'wants_messages': wantsMessages,
      'enabled': contactEnabled,
      'phonenumbers' : phoneNumbers,
      'attributes': attributes
    };

    return JSON.encode(data);
  }
}
