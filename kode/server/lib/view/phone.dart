library adaheads.server.view.phone;

import 'dart:convert';

import '../model.dart';

Map PhoneNumbersAsJsonMap(Phone phonenumber) => phonenumber == null ? {} :
  {'id': phonenumber.id,
   'value': phonenumber.value,
   'kind': phonenumber.kind};

List listPhoneNumbersAsJsonMap(List<Phone> phonenumbers) =>
    phonenumbers.map(PhoneNumbersAsJsonMap).toList();
