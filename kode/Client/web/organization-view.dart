library organization_view;

import 'dart:html';
import 'dart:convert';

import 'lib/model.dart';
import 'lib/request.dart';
import 'lib/eventbus.dart';

class OrganizationView {
  String viewName = 'organization';
  DivElement element;
  UListElement uiList;
  InputElement inputName;
  ButtonElement buttonSave;
  ButtonElement buttonCreate;
  
  int currentOrganizationId = 0;
  
  OrganizationView(DivElement this.element) {
    refreshList();
    uiList = querySelector('#organization-list');
    inputName = element.querySelector('#organization-input-name');
    buttonSave = element.querySelector('#organization-save');
    buttonCreate = element.querySelector('#organization-create');
    
    registrateEventHandlers();
  }
  
  void registrateEventHandlers() {
    buttonSave.onClick.listen((_) {
      saveChanges();
    });
    
    buttonCreate.onClick.listen((_) {
      Map organization = {'full_name': inputName.value};
      String newOrganization = JSON.encode(organization);
      createOrganization(newOrganization).then((String response) {
        Map json = JSON.decode(response);
        //TODO visable clue that a new organization is created.
        refreshList();
        activateOrganization(json['id']);
      });
    });
    
    bus.on(windowChanged).listen((String window) {
      element.classes.toggle('hidden', window != viewName);
    });
  }
  
  void saveChanges() {
    if(currentOrganizationId > 0) {
      Map organization = {'id': currentOrganizationId,
                          'full_name': inputName.value};
      String newOrganization = JSON.encode(organization);
      updateOrganization(currentOrganizationId, newOrganization).then((_) {
        //Show a message that tells the user, that the changes went threw.
        refreshList();
      });
    } else {
      print('Organization out of range: $currentOrganizationId');
    }
  }
  
  void refreshList() {
    getOrganizationList().then((List<Organization> organizations) {
      organizations.sort((a,b) => a.full_name.compareTo(b.full_name));
      uiList.children
        ..clear()
        ..addAll(organizations.map(makeOrganizationNode));
    });
  }

  LIElement makeOrganizationNode(Organization organization) {
    return new LIElement()
      ..value = organization.id
      ..text = '${organization.id} - ${organization.full_name}'
      ..onClick.listen((_) {
        activateOrganization(organization.id);
      });
  }
  
  void activateOrganization(int organizationId) {
    getOrganization(organizationId).then((Organization organization) {
      currentOrganizationId = organizationId;
      inputName.value = organization.full_name;
    }).catchError((error) {
      print('Tried to activate organization "$organizationId" but gave error: $error');
    });
  }
}
