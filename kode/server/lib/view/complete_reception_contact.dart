library adaheads.server.view.receptionContact;

import 'dart:convert';

import '../model.dart';

String receptionContactAsJson(CompleteReceptionContact contact) => JSON.encode(contact == null ? {} :
    {'reception_id': contact.receptionId,
     'contact_id': contact.id,
     'full_name': contact.fullName,
     'contact_type': contact.contactType,
     'contact_enabled': contact.contactEnabled,
     'wants_messages': contact.wantsMessages,
     'distribution_list_id': contact.distributionListId,
     'attributes': contact.attributes,
     'reception_enabled': contact.receptionEnabled});

String listReceptionContactAsJson(List<CompleteReceptionContact> contacts) =>
    JSON.encode({'receptionContacts': contacts.map(receptionContactAsJson).toList()});
