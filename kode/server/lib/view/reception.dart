library adaheads.server.view.reception;

import 'dart:convert';

import '../model.dart';

String receptionAsJson(Reception r) => r == null ? '{}' : JSON.encode(
    {'id': r.id,
     'full_name': r.fullName,
     'uri': r.uri,
     'attributes': r.attributes,
     'extradatauri': r.extradatauri,
     'enabled': r.enabled});
