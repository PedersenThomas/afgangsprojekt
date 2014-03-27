library reception_view;

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:html5_dnd/html5_dnd.dart';

import 'lib/model.dart';
import 'lib/request.dart';
import 'lib/eventbus.dart';
import 'lib/view_utilities.dart';

class ReceptionView {
  String addNewLiClass = 'addnew';
  String viewName = 'reception';
  DivElement element;
  InputElement inputFullName, inputUri, inputProduct, inputGreeting, inputOther, inputCostumerstype;
  CheckboxInputElement inputEnabled;
  ButtonElement buttonSave, buttonCreate;
  UListElement ulAddresses, ulAlternatenames, ulBankinginformation, ulCrapcallhandling, ulEmailaddresses, 
               ulHandlings, ulOpeninghours, ulRegistrationnumbers, ulTelephonenumbers, ulWebsites;
  SearchInputElement searchBox;
  UListElement uiReceptionList;
  UListElement ulContactList;

  List<Reception> receptions = [];
  
  int currentReceptionId = 0, currentOrganizationId = 1;
  
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
    
    registrateEventHandlers();
    
    refreshList().then((_) {
      performSearch();
    });
    
    activateReception(0, 0);
  }
  
  void registrateEventHandlers() {
    buttonSave.onClick.listen((_) {
      saveChanges();
    });
    
    buttonCreate.onClick.listen((_) => createReceptionClickHandler());

    bus.on(windowChanged).listen((String window) {
      element.classes.toggle('hidden', window != viewName);
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
    Reception newReception = extractValues();    
    
    createReception(currentOrganizationId, newReception.toJson()).then((String response) {
      Map json = JSON.decode(response);
      //TODO visable clue that a new organization is created.
      return refreshList().then((_) {
        performSearch();
        activateReception(currentOrganizationId, json['id']);
      });
    }).catchError((error) {
      print('Somethin bad happend, more precises "${error}", when i tried to create a new reception based on organization "${currentOrganizationId}" with data "${newReception.toJson()}"');
    });
  }
  
  void saveChanges() {
    if(currentReceptionId > 0) {        
      Reception updatedReception = extractValues();
      
      updateReception(currentOrganizationId, currentReceptionId, updatedReception.toJson()).then((_) {
        //Show a message that tells the user, that the changes went threw.
        refreshList().then((_) {
          performSearch();
        });        
      });
    } else {
      print('Reception out of range: $currentReceptionId');
    }
  }
  
  Reception extractValues() {
    return new Reception()
      ..id = currentReceptionId
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
    });
  }
  
  LIElement makeReceptionNode(Reception reception) {
    return new LIElement()
      ..value = reception.id //TODO Er den brugt?
      ..text = '${reception.id} - ${reception.full_name}'
      ..onClick.listen((_) {
        activateReception(reception.organization_id, reception.id);
      });
  }
  
  void activateReception(int organizationId, int receptionId) {
    currentOrganizationId = organizationId;
    currentReceptionId = receptionId;
    
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
    
//  LIElement simpleListElement(String item) {
//    LIElement li = new LIElement();
//    ButtonElement deleteButton = new ButtonElement()
//      ..text = 'Slet'
//      ..onClick.listen((_) {
//        li.parent.children.remove(li);
//      });
//    SpanElement content = new SpanElement()
//      ..text = item;
//    
//    li..children.addAll([deleteButton, content]);
//    
//    return li;
//  }
  
//  void _fillList(UListElement element, List<String> items) {
//    List<LIElement> children = new List<LIElement>();
//    for(String item in items) {
//      LIElement li = simpleListElement(item);      
//      children.add(li);
//    }
//    
//    SortableGroup sortGroup = new SortableGroup()
//      ..installAll(children)
//      ..onSortUpdate.listen((SortableEvent event) {
//        // do something when user sorted the elements...
//      });
//
//    // Only accept elements from this section.
//    sortGroup.accept.add(sortGroup);
//    
//    InputElement inputNewItem = new InputElement();
//    inputNewItem
//      ..classes.add(addNewLiClass)
//      ..placeholder = 'Add new...'
//      ..onKeyPress.listen((KeyboardEvent event) {
//        KeyEvent key = new KeyEvent.wrap(event);
//        int ENTER = 13;
//        if(key.keyCode == ENTER) {
//          String item = inputNewItem.value;
//          inputNewItem.value = '';
//          
//          LIElement li = simpleListElement(item);
//          int index = element.children.length -1;
//          sortGroup.install(li);
//          element.children.insert(index, li);
//        }
//      });
//    
//    children.add(new LIElement()..children.add(inputNewItem));
//    
//    element.children
//      ..clear()
//      ..addAll(children);
//  }

//  List<String> getListValues(UListElement element) {
//    List<String> texts = new List<String>();
//    for(LIElement e in element.children) {
//      if(!e.classes.contains(addNewLiClass)) {
//        SpanElement content = e.children.firstWhere((elem) => elem is SpanElement, orElse: () => null);
//        if (content != null) {
//          texts.add(content.text);
//        }
//      }
//    }
//    return texts;
//  }
  
  void updateContactList(int receptionId) {
    getReceptionContactList(receptionId).then((List<CustomReceptionContact> contacts) {
      ulContactList.children
        ..clear()
        ..addAll(contacts.map((c) => new LIElement()..text = 'LINK ${c.fullName}'));
    }).catchError((error) {
      print('Tried to fetch the contactlist from an reception Error: $error');
    });
  }
}

/*
  <li>
    <Button>Slet</Button>   //Kan også godt være et billed.
    <span>${Value}</span>
  </li>
  ...
  <li class="addnew">
    <input type="text" onKeyEnter="Add text as new element, wipe clear field.">
  </li>
*/

/*
  Når man henter en bestemt person skal man have information for hver enkel reception personen er i, foruden stamdata fra contacts tabellen.
  I Receptions har man brug for en liste af kontakt personer
 */