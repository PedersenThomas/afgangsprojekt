library adaheads.server.view.contact;

import 'dart:convert';

import '../model.dart';

String contactAsJson(Contact contact) => JSON.encode(contact == null ? {} :
    {'id': contact.id,
     'full_name': contact.fullName,
     'contact_type': contact.contactType,
     'enabled': contact.enabled});

String listContactAsJson(List<Contact> contacts) =>
    JSON.encode({'contacts':contacts.map(contactAsJson).toList()});

String contactIdAsJson(int id) => JSON.encode({'id': id});

String contactTypesAsJson(List<String> types) => JSON.encode({'contacttypes': types});
