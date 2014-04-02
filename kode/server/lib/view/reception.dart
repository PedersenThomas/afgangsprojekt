library adaheads.server.view.reception;

import 'dart:convert';

import '../model.dart';

String receptionAsJson(Reception r) => JSON.encode(r == null ? {} :
    {'id': r.id,
     'organization_id': r.organizationId,
     'full_name': r.fullName,
     'uri': r.uri,
     'attributes': r.attributes,
     'extradatauri': r.extradatauri,
     'enabled': r.enabled});

String listReceptionAsJson(List<Reception> receptions) =>
    JSON.encode({'receptions': receptions.map(receptionAsJson).toList()});

String receptionIdAsJson(int id) => JSON.encode({'id': id});
