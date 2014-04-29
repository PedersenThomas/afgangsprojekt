library organization_view;

import 'dart:html';
import 'dart:convert';

import 'lib/eventbus.dart';
import 'lib/logger.dart' as log;
import 'lib/model.dart';
import 'lib/request.dart';
import 'notification.dart' as notify;

class OrganizationView {
  String viewName = 'organization';
  DivElement element;
  UListElement uiList;
  InputElement inputName;
  ButtonElement buttonCreate, buttonSave, buttonDelete;
  SearchInputElement searchBox;
  UListElement ulReceptionList;
  UListElement ulContactList;

  bool createNew = false;

  List<Organization> organizations = [];
  int selectedOrganizationId = 0;

  List<Contact> currentContactList = [];
  List<Reception> currentReceptionList = [];

  OrganizationView(DivElement this.element) {
    searchBox = element.querySelector('#organization-search-box');
    uiList = element.querySelector('#organization-list');
    inputName = element.querySelector('#organization-input-name');
    buttonSave = element.querySelector('#organization-save');
    buttonCreate = element.querySelector('#organization-create');
    buttonDelete = element.querySelector('#organization-delete');
    ulReceptionList = element.querySelector('#organization-reception-list');
    ulContactList = element.querySelector('#organization-contact-list');

    buttonSave.disabled = true;
    buttonDelete.disabled = true;

    registrateEventHandlers();

    refreshList();
  }

  void registrateEventHandlers() {
    buttonSave.onClick.listen((_) {
      saveChanges();
    });

    buttonCreate.onClick.listen((_) {
      createOrganizationHandler();
    });

    buttonDelete.onClick.listen((_) {
      if (!createNew && selectedOrganizationId > 0) {
        deleteOrganization(selectedOrganizationId).then((_) {
          notify.info('Organisation blev slettet.');

          currentContactList.clear();
          currentReceptionList.clear();
          bus.fire(Invalidate.organizationRemoved, selectedOrganizationId);
          refreshList();
          clearContent();
          buttonSave.disabled = true;
          buttonDelete.disabled = true;
          selectedOrganizationId = 0;
        }).catchError((error) {
          notify.error('Der skete en fejl i forbindelsen med sletningen.');
          log.error('Failed to delete organization "${selectedOrganizationId}", got "${error}"');
        });
      }
    });

    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
      if (event.containsKey('organization_id')) {
        activateOrganization(event['organization_id']);
      }
    });

    bus.on(Invalidate.receptionAdded).listen((int organizationId) {
      if (organizationId == selectedOrganizationId) {
        activateOrganization(selectedOrganizationId);
      }
    });

    bus.on(Invalidate.receptionRemoved).listen((Map event) {
      if (event['organizationId'] == selectedOrganizationId) {
        activateOrganization(selectedOrganizationId);
      }
    });

    bus.on(Invalidate.receptionContactAdded).listen(handleReceptionContactAdded
        );
    bus.on(Invalidate.receptionContactRemoved).listen(
        handleReceptionContactRemoved);

    searchBox.onInput.listen((_) => performSearch());
  }

  void handleReceptionContactAdded(Map event) {
    int receptionId = event['receptionId'];
    if (currentReceptionList.any((r) => r.id == receptionId)) {
      activateOrganization(selectedOrganizationId);
    }
  }

  void handleReceptionContactRemoved(Map event) {
    int contactId = event['contactId'];
    if (currentContactList.any((contact) => contact.id == contactId)) {
      activateOrganization(selectedOrganizationId);
    }
  }

  void createOrganizationHandler() {
    selectedOrganizationId = 0;
    buttonSave.text = 'Opret';
    buttonSave.disabled = false;
    buttonDelete.disabled = true;
    clearRightBar();
    clearContent();
    createNew = true;
  }

  void clearRightBar() {
    currentContactList.clear();
    currentReceptionList.clear();
    ulContactList.children.clear();
    ulReceptionList.children.clear();
  }

  void clearContent() {
    inputName.value = '';
  }

  void performSearch() {
    String searchText = searchBox.value;
    List<Organization> filteredList = organizations.where((Organization org) =>
        org.full_name.toLowerCase().contains(searchText.toLowerCase())).toList();
    renderOrganizationList(filteredList);
  }

  void saveChanges() {
    //TODO Does this make sense? Remove currentOrganizationId?????
    if (selectedOrganizationId > 0) {
      Map organization = {
        'id': selectedOrganizationId,
        'full_name': inputName.value
      };
      String newOrganization = JSON.encode(organization);
      updateOrganization(selectedOrganizationId, newOrganization).then((_) {
        //Show a message that tells the user, that the changes went through.
        refreshList();
      });
    } else if (createNew) {
      Map organization = {
        'full_name': inputName.value
      };
      String newOrganization = JSON.encode(organization);
      createOrganization(newOrganization).then((Map response) {
        //TODO visable clue that a new organization is created.
        int organizationId = response['id'];
        refreshList();
        activateOrganization(organizationId);
        bus.fire(Invalidate.organizationAdded, null);
      }).catchError((error) {
        log.error('Tried to create a new Organizaitonbut got: $error');
      });
    }
  }

  void refreshList() {
    getOrganizationList().then((List<Organization> organizations) {
      organizations.sort((a, b) => a.full_name.compareTo(b.full_name));
      //TODO Skal det være her.
      this.organizations = organizations;
      renderOrganizationList(organizations);
    }).catchError((error) {
      log.error('Tried to fetch organization but got error: $error');
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
      selectedOrganizationId = organizationId;
      createNew = false;
      buttonSave.disabled = false;
      buttonSave.text = 'Gem';
      buttonDelete.disabled = false;
      inputName.value = organization.full_name;
      updateReceptionList(selectedOrganizationId);
      updateContactList(selectedOrganizationId);
    }).catchError((error) {
      log.error(
          'Tried to activate organization "$organizationId" but gave error: $error');
    });
  }

  void updateReceptionList(int organizationId) {
    getAnOrganizationsReceptionList(organizationId).then((List<Reception>
        receptions) {
      receptions.sort((a, b) => a.full_name.compareTo(b.full_name));
      currentReceptionList = receptions;
      ulReceptionList.children
          ..clear()
          ..addAll(receptions.map(makeReceptionNode));
    }).catchError((error) {
      log.error('Tried to fetch the receptionlist Error: $error');
    });
  }

  LIElement makeReceptionNode(Reception reception) {
    LIElement li = new LIElement()
        ..classes.add('clickable')
        ..text = '${reception.full_name}'
        ..onClick.listen((_) {
          Map event = {
            'window': 'reception',
            'organization_id': reception.organization_id,
            'reception_id': reception.id
          };
          bus.fire(windowChanged, event);
        });
    return li;
  }

  void updateContactList(int organizationId) {
    getOrganizationContactList(organizationId).then((List<Contact> contacts) {
      contacts.sort((a, b) => a.full_name.compareTo(b.full_name));
      currentContactList = contacts;
      ulContactList.children
          ..clear()
          ..addAll(contacts.map(makeContactNode));
    }).catchError((error) {
      log.error(
          'Tried to fetch the contactlist from an organization Error: $error');
    });
  }

  LIElement makeContactNode(Contact contact) {
    LIElement li = new LIElement();
    li
        ..classes.add('clickable')
        ..text = '${contact.full_name}'
        ..onClick.listen((_) {
          Map event = {
            'window': 'contact',
            'contact_id': contact.id
          };
          bus.fire(windowChanged, event);
        });
    return li;
  }
}
