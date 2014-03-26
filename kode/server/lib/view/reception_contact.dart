library adaheads.server.view.receptionContact;

import '../model.dart';

Map receptionContactAsJson(ReceptionContact contact) => contact == null ? {} : 
    {'reception_id': contact.receptionId,
     'contact_id': contact.contactId,
     'full_name': contact.fullName,
     'contact_type': contact.contactType,
     'contact_enabled': contact.contactEnabled,
     'wants_messages': contact.wantsMessages,
     'distribution_list_id': contact.distributionListId,
     'attributes': contact.attributes,
     'reception_enabled': contact.receptionEnabled};
     
List listReceptionContactAsJson(List<ReceptionContact> contacts) => contacts.map(receptionContactAsJson).toList();
