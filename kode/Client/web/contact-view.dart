library contact_view;

import 'dart:html';
import 'dart:convert';

import 'lib/model.dart';
import 'lib/request.dart' as request;
import 'lib/eventbus.dart';

class ContactView {
  String viewName = 'contact';
  DivElement element;
  UListElement uiContactList;
  List<Contact> contactList = new List<Contact>();
  
  InputElement inputName;
  InputElement inputType;
  CheckboxInputElement inputEnabled;
  
  ButtonElement buttonSave, buttonCreate;
  
  int contactId;
  
  ContactView(DivElement this.element) {
    print('ContactView Constructor');
    uiContactList = element.querySelector('#contact-list');
    
    inputName = element.querySelector('#contact-input-name');
    inputType = element.querySelector('#contact-input-type');
    inputEnabled = element.querySelector('#contact-input-enabled');

    buttonSave = element.querySelector('#contact-save');
    buttonCreate = element.querySelector('#contact-create');
    
    registrateEventHandlers();
    
    refreshList();
  }
  
  void registrateEventHandlers() {      
    bus.on(windowChanged).listen((String window) {
      element.classes.toggle('hidden', window != viewName);
    });
    
    buttonSave.onClick.listen((_) => saveChanges());
    buttonCreate.onClick.listen((_) => createContact());
  }
  
  void refreshList() {
    print('Contact refreshList');
        
    request.getEveryContact().then((List<Contact> contacts) {
      contacts.sort((a,b) => a.full_name.compareTo(b.full_name));
      //TODO Skal det være her.
      this.contactList = contacts;
      performSearch();
    }).catchError((error) {
      print('Tried to fetch organization but got error: $error');
    });
  }
  
  void performSearch() {
    uiContactList.children
      ..clear()
      ..addAll(contactList.map((c) => new LIElement()..text = c.full_name
                                                     ..onClick.listen((_) => activateContact(c.id))));
  }
  
  void activateContact(int id) {
    request.getContact(id).then((Contact contact) {
      inputName.value = contact.full_name;
      inputType.value = contact.type;
      inputEnabled.checked = contact.enabled;
      contactId = contact.id;
    }).catchError((error) {
      print('Tried to activate contact "${id}" but gave "${error}"');
    });
  }
  
  void saveChanges() {
    if(contactId != null && contactId > 0) {
      Contact updatedContact = new Contact()
        ..id = contactId
        ..full_name = inputName.value
        ..type = inputType.value
        ..enabled = inputEnabled.checked;
      
      request.updateContact(contactId, updatedContact.toJson()).then((_) {
        //Show a message that tells the user, that the changes went through.
        refreshList();
      }).catchError((error) {
        print('Tried to update a contact but failed with error "${error}" from body: "${updatedContact.toJson()}"');
      });
    }
  }
  
  void createContact() {
    Contact newContact = new Contact()
      ..full_name = inputName.value
      ..type = inputType.value
      ..enabled = inputEnabled.checked;
    
    request.createContact(newContact.toJson()).then((_) {
      //TODO Success Show message?
      refreshList();
    }).catchError((error) {
      print('Tried to make a new contact but failed with error "${error}" from body: "${newContact.toJson()}"');
    });
  }
}