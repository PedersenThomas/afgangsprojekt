library adaheads.server.view.organization;

import '../model.dart';

Map organizationAsJson(Organization organization) => organization == null ? {} : 
    {'id': organization.id,
     'full_name': organization.fullName};

List listOrganizatonAsJson(List<Organization> organizations) => organizations.map(organizationAsJson).toList();
