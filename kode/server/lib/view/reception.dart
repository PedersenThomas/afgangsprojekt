library adaheads.server.view.reception;

import '../model.dart';

Map receptionAsJson(Reception r) => r == null ? {} : 
    {'id': r.id,
     'full_name': r.fullName,
     'uri': r.uri,
     'attributes': r.attributes,
     'extradatauri': r.extradatauri,
     'enabled': r.enabled};

List listReceptionAsJson(List<Reception> receptions) => receptions.map(receptionAsJson).toList();
