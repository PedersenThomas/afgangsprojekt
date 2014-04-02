library adaheads.server.view.organization;

import 'dart:convert';

import '../model.dart';

String organizationAsJson(Organization organization) => JSON.encode(organization == null ? {} :
    {'id': organization.id,
     'full_name': organization.fullName});

String listOrganizatonAsJson(List<Organization> organizations) => JSON.encode({'organizations':organizations.map(organizationAsJson).toList()});

String organizationIdAsJson(int id) => JSON.encode({'id': id});
