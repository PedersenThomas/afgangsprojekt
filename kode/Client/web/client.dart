import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'organization-view.dart' as orgView;
import 'reception-view.dart' as recView;
import 'menu.dart';
import 'lib/auth.dart';

void main() {
  if(handleToken()) {
    new orgView.OrganizationView(querySelector('#organization-page'));
    new recView.ReceptionView(querySelector('#reception-page'));
    new Menu(querySelector('nav#navigation'));
  }
}
