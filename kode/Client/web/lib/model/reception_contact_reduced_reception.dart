part of model;

class ReceptionContact_ReducedReception {
  int contactId;
  bool wantsMessages;
  int distributionListId;
  bool contactEnabled;
  List<Phone> phoneNumbers;

  int receptionId;
  bool receptionEnabled;
  String receptionName;
  String receptionUri;

  int organizationId;

  List<String> backup;
  List<String> emailaddresses;
  List<String> handling;
  List<String> telephonenumbers;
  List<String> workhours;
  List<String> tags;

  String department;
  String info;
  String position;
  String relations;
  String responsibility;

  Map get attributes => {};

  ReceptionContact_ReducedReception();

  factory ReceptionContact_ReducedReception.fromJson(Map json) {
    ReceptionContact_ReducedReception object = new ReceptionContact_ReducedReception()
      ..contactId = json['contact_id']
      ..wantsMessages = json['contact_wants_messages']
      ..distributionListId = json['contact_distribution_list_id']
      ..contactEnabled = json['contact_enabled']
      ..receptionId = json['reception_id']
      ..receptionEnabled = json['reception_enabled']
      ..receptionName = json['reception_full_name']
      ..receptionUri = json['reception_uri']

      ..organizationId = json['organization_id']

      ..phoneNumbers = (json['contact_phonenumbers'] as List<Map>).map((Map json) => new Phone.fromJson(json)).toList();

    if (json.containsKey('contact_attributes')) {
      Map attributes = json['contact_attributes'];

      object
          ..backup = priorityListFromJson(attributes, 'backup')
          ..emailaddresses = priorityListFromJson(attributes, 'emailaddresses')
          ..handling = priorityListFromJson(attributes, 'handling')
          ..telephonenumbers = priorityListFromJson(attributes,
              'telephonenumbers')
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
}
