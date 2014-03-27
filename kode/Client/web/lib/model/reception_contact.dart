part of model;

class ReceptionContact {
  int contactId;
  bool contactEnabled;
  int receptionId;
  bool wantsMessages;
  int distributionListId;
  
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
      'telephonenumbers': priorityListToJson(emailaddresses),
      'workhours': priorityListToJson(workhours),
      'tags': tags
    };
  }
  
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
 
  ReceptionContact ();
  
  factory ReceptionContact.fromJson(Map json) {
    ReceptionContact object = new ReceptionContact();
    object.contactId = json['contact_id'];
    object.contactEnabled = json['contact_enabled'];
    object.receptionId = json['reception_id'];
    object.wantsMessages = json['wants_messages'];
    object.distributionListId = json['distribution_list_id'];
    
    if(json.containsKey('attributes')) {
      Map attributes = json['attributes'];

      object
        ..backup = priorityListFromJson(attributes, 'backup')
        ..emailaddresses = priorityListFromJson(attributes, 'emailaddresses')
        ..handling = priorityListFromJson(attributes, 'handling')
        ..telephonenumbers = priorityListFromJson(attributes, 'telephonenumbers')
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
      'distribution_list_id': distributionListId,
      'enabled': contactEnabled, 
      'attributes': attributes
    };
    
    return JSON.encode(data);
  }
}