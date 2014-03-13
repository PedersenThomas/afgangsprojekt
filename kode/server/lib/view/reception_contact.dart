library adaheads.server.view.receptionContact;

import '../model.dart';

Map receptionContactAsJson(ReceptionContact contact) => contact == null ? {} : 
    {'reception_id': contact.receptionId,
     'contact_id': contact.contactId,
     'wants_messages': contact.wants_messages,
     'distribution_list_id': contact.distribution_list_id,
     'attributes': contact.attributes,
     'enabled': contact.enabled};

List listReceptionContactAsJson(List<ReceptionContact> contacts) => contacts.map(receptionContactAsJson).toList();
