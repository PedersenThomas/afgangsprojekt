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
  SearchInputElement searchBox;
  UListElement ulReceptionList;
  UListElement ulContactList;
  
  List<Organization> organizations = [];
  int currentOrganizationId = 0;
  
  bool createNew = false;
  
  OrganizationView(DivElement this.element) {
    print('OrganizationView Constructor');
    searchBox = element.querySelector('#organization-search-box');
    uiList = element.querySelector('#organization-list');
    inputName = element.querySelector('#organization-input-name');
    buttonSave = element.querySelector('#organization-save');
    buttonCreate = element.querySelector('#organization-create');
    ulReceptionList = element.querySelector('#organization-reception-list');
    ulContactList = element.querySelector('#organization-contact-list');
    
    registrateEventHandlers();
    
    refreshList();
  }
  
  void registrateEventHandlers() {
    buttonSave.onClick.listen((_) {
      saveChanges();
    });
    
    buttonCreate.onClick.listen((_) {
      currentOrganizationId = 0;
      clearContent();
      createNew = true;
    });
    
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
    });
    
    searchBox.onInput.listen((_) => performSearch());
  }

  void clearContent() {
    inputName.value = '';
  }
  
  void performSearch() {
    String searchText = searchBox.value;
    List<Organization> filteredList = organizations.where(
        (Organization org) => org.full_name.toLowerCase().contains(searchText.toLowerCase())).toList();
    renderOrganizationList(filteredList);
  }
  
  void saveChanges() {
    //TODO Does this make sense? Remove currentOrganizationId?????
    if(currentOrganizationId > 0) {
      Map organization = {'id': currentOrganizationId,
                          'full_name': inputName.value};
      String newOrganization = JSON.encode(organization);
      updateOrganization(currentOrganizationId, newOrganization).then((_) {
        //Show a message that tells the user, that the changes went through.
        refreshList();
      });
    } else if(createNew) {
      Map organization = {'full_name': inputName.value};
      String newOrganization = JSON.encode(organization);
      createOrganization(newOrganization).then((String response) {
        Map json = JSON.decode(response);
        //TODO visable clue that a new organization is created.
        refreshList();
        activateOrganization(json['id']);
      }).catchError((error) {
        print('Tried to create a new Organizaitonbut got: $error');
      });
    }
  }
  
  void refreshList() {
    print('Organization refreshList');
    
    getOrganizationList().then((List<Organization> organizations) {
      organizations.sort((a,b) => a.full_name.compareTo(b.full_name));
      //TODO Skal det være her.
      this.organizations = organizations;
      renderOrganizationList(organizations);
    }).catchError((error) {
      print('Tried to fetch organization but got error: $error');
    });
  }

  void renderOrganizationList(List<Organization> organizations) {
    uiList.children
      ..clear()
      ..addAll(organizations.map(makeOrganizationNode));
  }

  LIElement makeOrganizationNode(Organization organization) {
    return new LIElement()
      ..classes.add('clickable')
      ..value = organization.id
      ..text = '${organization.id} - ${organization.full_name}'
      ..onClick.listen((_) {
        activateOrganization(organization.id);
      });
  }
  
  void activateOrganization(int organizationId) {
    getOrganization(organizationId).then((Organization organization) {
      currentOrganizationId = organizationId;
      createNew = false;
      inputName.value = organization.full_name;
      updateReceptionList(currentOrganizationId);
      updateContactList(currentOrganizationId);
    }).catchError((error) {
      print('Tried to activate organization "$organizationId" but gave error: $error');
    });
  }
  
  void updateReceptionList(int organizationId) {
    getAnOrganizationsReceptionList(organizationId).then((List<Reception> receptions) {
      ulReceptionList.children
        ..clear()
        ..addAll(receptions.map(makeReceptionNode));
    }).catchError((error) {
      print('Tried to fetch the receptionlist Error: $error');
    });
  }

  LIElement makeReceptionNode(Reception reception) {
    LIElement li = new LIElement();
    li
      ..classes.add('clickable')
      ..text = '${reception.full_name}'
      ..onClick.listen((_) {
        Map event = {'window': 'reception',
                     'organization_id': reception.organization_id,
                     'reception_id': reception.id};
        bus.fire(windowChanged, event);
      });
    return li;
  }
  
  void updateContactList(int organizationId) {
    getOrganizationContactList(organizationId).then((List<Contact> contacts) {
      ulContactList.children
        ..clear()
        ..addAll(contacts.map(makeContactNode));
    }).catchError((error) {
      print('Tried to fetch the contactlist from an organization Error: $error');
    });
  }
  
  LIElement makeContactNode(Contact contact) {
    LIElement li = new LIElement();
    li
      ..classes.add('clickable')
      ..text = '${contact.full_name}'
      ..onClick.listen((_) {
        Map event = {'window': 'contact',
                     'contact_id': contact.id};
        bus.fire(windowChanged, event);
      });
    return li;
  }
}
