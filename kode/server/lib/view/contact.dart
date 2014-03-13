library adaheads.server.view.contact;

import '../model.dart';

Map contactAsJson(Contact contact) => contact == null ? {} : 
    {'id': contact.id,
     'full_name': contact.fullName,
     'contact_type': contact.contactType,
     'enabled': contact.enabled};

List listContactAsJson(List<Contact> contacts) => contacts.map(contactAsJson).toList();
