library reception_view;

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:html5_dnd/html5_dnd.dart';

import 'lib/model.dart';
import 'lib/request.dart';
import 'lib/eventbus.dart';
import 'lib/view_utilities.dart';
import 'lib/searchcomponent.dart';

class ReceptionView {
  String addNewLiClass = 'addnew';
  String viewName = 'reception';
  DivElement element;
  InputElement inputFullName, inputUri, inputProduct, inputGreeting, inputOther, inputCostumerstype;
  CheckboxInputElement inputEnabled;
  ButtonElement buttonSave, buttonCreate, buttonDelete;
  UListElement ulAddresses, ulAlternatenames, ulBankinginformation, ulCrapcallhandling, ulEmailaddresses, 
               ulHandlings, ulOpeninghours, ulRegistrationnumbers, ulTelephonenumbers, ulWebsites;
  SearchInputElement searchBox;
  UListElement uiReceptionList;
  UListElement ulContactList;
  DivElement organizationOuterSelector;
  
  List<Reception> receptions = [];
  
  SearchComponent<Organization> SC;
  int currentReceptionId, currentOrganizationId;
  
  ReceptionView(DivElement this.element) {
    searchBox = element.querySelector('#reception-search-box');
    uiReceptionList = element.querySelector('#reception-list');
    ulContactList = element.querySelector('#reception-contact-list');
    
    inputFullName = element.querySelector('#reception-input-name');
    inputUri = element.querySelector('#reception-input-uri');
    inputProduct = element.querySelector('#reception-input-product');
    inputOther = element.querySelector('#reception-input-other');
    inputCostumerstype = element.querySelector('#reception-input-customertype');
    inputGreeting = element.querySelector('#reception-input-greeting');
    inputEnabled = element.querySelector('#reception-input-enabled');
    
    ulAddresses = element.querySelector('#reception-list-addresses');
    ulAlternatenames = element.querySelector('#reception-list-alternatenames');
    ulBankinginformation = element.querySelector('#reception-list-bankinginformation');
    ulCrapcallhandling = element.querySelector('#reception-list-crapcallhandling');
    ulEmailaddresses = element.querySelector('#reception-list-emailaddresses');
    ulHandlings = element.querySelector('#reception-list-handlings');
    ulOpeninghours = element.querySelector('#reception-list-openinghours');
    ulRegistrationnumbers = element.querySelector('#reception-list-registrationnumbers');
    ulTelephonenumbers = element.querySelector('#reception-list-telephonenumbers');
    ulWebsites = element.querySelector('#reception-list-websites');
    
    buttonSave = element.querySelector('#reception-save');
    buttonCreate = element.querySelector('#reception-create');
    buttonDelete = element.querySelector('#reception-delete');
    
    organizationOuterSelector = element.querySelector('#reception-organization-selector');
    
    SC = new SearchComponent<Organization>(organizationOuterSelector, 'reception-organization-searchbox')
      ..listElementToString = organizationToSearchboxString
      ..searchFilter = organizationSearchHandler;
    
    getOrganizationList().then((List<Organization> list) {
      list.sort((a, b) => a.full_name.compareTo(b.full_name));
      SC.updateSourceList(list);
    });
    
    registrateEventHandlers();
    
    refreshList();
    
    //activateReception(0, 0);
  }
  
  String organizationToSearchboxString(Organization organization, String searchterm) {
    return '${organization.full_name}';
  }
  
  bool organizationSearchHandler(Organization element, String searchTerm) {
    return element.full_name.toLowerCase().contains(searchTerm.toLowerCase());
  }
  
  void registrateEventHandlers() {
    buttonSave.onClick.listen((_) {
      saveChanges();
    });
    
    buttonCreate.onClick.listen((_) => createReceptionClickHandler());

    buttonDelete.onClick.listen((_) => deleteCurrentReception());
    
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
      if(event.containsKey('organization_id') && event.containsKey('reception_id')) {
        activateReception(event['organization_id'], event['reception_id']);
      }
    });
    
    searchBox.onInput.listen((_) => performSearch());
  }
  
  void performSearch() {
    String searchText = searchBox.value;
    List<Reception> filteredList = receptions.where(
        (Reception recep) => recep.full_name.toLowerCase().contains(searchText.toLowerCase())).toList();
    renderReceptionList(filteredList);
  }
  
  void renderReceptionList(List<Reception> receptions) {
    uiReceptionList.children
      ..clear()
      ..addAll(receptions.map(makeReceptionNode));
  }

  void createReceptionClickHandler() {
    currentReceptionId = 0;
    currentOrganizationId = 0;
    
    //Clear all fields.
    clearContent();
  }

  void clearContent() {
    inputFullName.value = '';
    inputUri.value = '';
    inputEnabled.checked = true;
    inputCostumerstype.value = '';
    inputGreeting.value = '';
    inputOther.value = '';
    inputProduct.value = '';
    fillList(ulAddresses, []);
    fillList(ulAlternatenames, []);
    fillList(ulBankinginformation, []);
    fillList(ulCrapcallhandling, []);
    fillList(ulEmailaddresses, []);
    fillList(ulHandlings, []);
    fillList(ulOpeninghours, []);
    fillList(ulRegistrationnumbers, []);
    fillList(ulTelephonenumbers, []);
    fillList(ulWebsites, []);
  }
  
  void deleteCurrentReception() {
    if(currentOrganizationId > 0 && currentReceptionId > 0) {
      deleteReception(currentOrganizationId, currentReceptionId).then((_) {
        currentReceptionId = 0;
        currentOrganizationId = 0;
        clearContent();
        refreshList();
      }).catchError((error) {
        print('Failed to delete reception orgId: "${currentOrganizationId}" recId: "${currentReceptionId}" got "${error}"');
      });
    }
  }
  
  void saveChanges() {
    if(currentReceptionId > 0) {        
      Reception updatedReception = extractValues();
      
      updateReception(currentOrganizationId, currentReceptionId, updatedReception.toJson()).then((_) {
        //Show a message that tells the user, that the changes went threw.
        refreshList();        
      });
    } else if(currentReceptionId == 0 && currentOrganizationId == 0) {
      Reception newReception = extractValues();
      if(SC.currentElement != null) {
        int organizationId = SC.currentElement.id;
        createReception(organizationId, newReception.toJson()).then((Map data) {
          if(data != null && data.containsKey('id')) {
            return refreshList().then((_) {
              return activateReception(organizationId, data['id']);
            });
          }
        }).catchError((error) {
          print('Tried to create a new reception but got "$error"');
        });
      }
    }
  }
  
  Reception extractValues() {
    return new Reception()
      ..organization_id = currentOrganizationId
      ..full_name = inputFullName.value
      ..uri = inputUri.value
      ..enabled = inputEnabled.checked

      ..customertype = inputCostumerstype.value
      ..greeting = inputGreeting.value
      ..other = inputOther.value
      ..product = inputProduct.value
      
      ..addresses = getListValues(ulAddresses)
      ..alternatenames = getListValues(ulAlternatenames)
      ..bankinginformation = getListValues(ulBankinginformation)
      ..crapcallhandling = getListValues(ulCrapcallhandling)
      ..emailaddresses = getListValues(ulEmailaddresses)
      ..handlings = getListValues(ulHandlings)
      ..openinghours = getListValues(ulOpeninghours)
      ..registrationnumbers = getListValues(ulRegistrationnumbers)
      ..telephonenumbers = getListValues(ulTelephonenumbers)
      ..websites = getListValues(ulWebsites);
  }
  
  Future refreshList() {
    return getReceptionList().then((List<Reception> receptions) {
      receptions.sort((a, b) => a.full_name.compareTo(b.full_name));
      this.receptions = receptions;
      performSearch();
    }).catchError((error) {
      print('Failed to refreshing the list of receptions in reception window.');
    });
  }
  
  LIElement makeReceptionNode(Reception reception) {
    return new LIElement()
      ..classes.add('clickable')
      ..value = reception.id //TODO Er den brugt?
      ..text = '${reception.id} - ${reception.full_name}'
      ..onClick.listen((_) {
        activateReception(reception.organization_id, reception.id);
      });
  }
  
  void activateReception(int organizationId, int receptionId) {
    currentOrganizationId = organizationId;
    currentReceptionId = receptionId;
    
    SC.selectElement(null, (Organization listItem, _) {
      return listItem.id == organizationId;
    });
    
    if(organizationId > 0 && receptionId > 0) {
      getReception(currentOrganizationId, currentReceptionId).then((Reception response) {
        inputFullName.value = response.full_name;
        inputUri.value = response.uri;
        inputEnabled.checked = response.enabled;
        
        inputCostumerstype.value = response.customertype;
        inputGreeting.value = response.greeting;
        inputOther.value = response.other;
        inputProduct.value = response.product;
        fillList(ulAddresses, response.addresses);
        fillList(ulAlternatenames, response.alternatenames);
        fillList(ulBankinginformation, response.bankinginformation);
        fillList(ulCrapcallhandling, response.crapcallhandling);
        fillList(ulEmailaddresses, response.emailaddresses);
        fillList(ulHandlings, response.handlings);
        fillList(ulOpeninghours, response.openinghours);
        fillList(ulRegistrationnumbers, response.registrationnumbers);
        fillList(ulTelephonenumbers, response.telephonenumbers);
        fillList(ulWebsites, response.websites);
      });
      
      updateContactList(receptionId);
    } else {
      inputFullName.value = '';
      inputUri.value = '';
      inputEnabled.checked = false;
      
      inputCostumerstype.value = '';
      inputGreeting.value = '';
      inputOther.value = '';
      inputProduct.value = '';
      fillList(ulAddresses, []);
      fillList(ulAlternatenames, []);
      fillList(ulBankinginformation, []);
      fillList(ulCrapcallhandling, []);
      fillList(ulEmailaddresses, []);
      fillList(ulHandlings, []);
      fillList(ulOpeninghours, []);
      fillList(ulRegistrationnumbers, []);
      fillList(ulTelephonenumbers, []);
      fillList(ulWebsites, []);
      updateContactList(receptionId);
    }
  }
  
  void updateContactList(int receptionId) {
    getReceptionContactList(receptionId).then((List<CustomReceptionContact> contacts) {
      ulContactList.children
        ..clear()
        ..addAll(contacts.map(makeContactNode));
    }).catchError((error) {
      print('Tried to fetch the contactlist from an reception Error: $error');
    });
  }
  
  LIElement makeContactNode(CustomReceptionContact contact) {
    LIElement li = new LIElement();
    li
      ..classes.add('clickable')
      ..text = '${contact.fullName}'
      ..onClick.listen((_) {
        Map event = {'window': 'contact',
                     'contact_id': contact.contactId};
        bus.fire(windowChanged, event);
      });
    return li;
  }
}
