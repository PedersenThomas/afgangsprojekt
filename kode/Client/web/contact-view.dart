library contact_view;

import 'dart:html';
import 'dart:convert';

import 'lib/model.dart';
import 'lib/request.dart' as request;
import 'lib/eventbus.dart';
import 'lib/view_utilities.dart';

class ContactView {
  String viewName = 'contact';
  DivElement element;
  UListElement ulContactList;
  UListElement ulReceptionContacts;
  List<Contact> contactList = new List<Contact>();
  SearchInputElement searchBox;
  
  InputElement inputName;
  InputElement inputType;
  CheckboxInputElement inputEnabled;
  
  ButtonElement buttonSave, buttonCreate;
  
  int contactId;
  
  ContactView(DivElement this.element) {
    print('ContactView Constructor');
    ulContactList = element.querySelector('#contact-list');
    
    inputName = element.querySelector('#contact-input-name');
    inputType = element.querySelector('#contact-input-type');
    inputEnabled = element.querySelector('#contact-input-enabled');
    ulReceptionContacts = element.querySelector('#reception-contact');

    buttonSave = element.querySelector('#contact-save');
    buttonCreate = element.querySelector('#contact-create');
    searchBox = element.querySelector('#contact-search-box');
    
    registrateEventHandlers();
    
    refreshList();
  }
  
  void registrateEventHandlers() {      
    bus.on(windowChanged).listen((String window) {
      element.classes.toggle('hidden', window != viewName);
    });
    
    buttonSave.onClick.listen((_) => saveChanges());
    buttonCreate.onClick.listen((_) => createContact());

    searchBox.onInput.listen((_) => performSearch());
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
    String searchTerm = searchBox.value;
    ulContactList.children
      ..clear()
      ..addAll(contactList.where((e) => e.full_name.toLowerCase().contains(searchTerm.toLowerCase()))
                          .map((c) => new LIElement()..text = c.full_name
                                                     ..onClick.listen((_) => activateContact(c.id))));
  }
  
  void activateContact(int id) {
    request.getContact(id).then((Contact contact) {
      inputName.value = contact.full_name;
      inputType.value = contact.type;
      inputEnabled.checked = contact.enabled;
      contactId = contact.id;
      
      return request.getAContactsEveryReception(id).then((List<ReceptionContact_ReducedReception> contacts) {
        UListElement list = element.querySelector('#reception-contacts');
        if(contacts != null) {
          contacts.sort((a, b) => a.receptionName.compareTo(b.receptionName));
          list.children
            ..clear()
            ..addAll(contacts.map(receptionContactBox));
        }
      });
    }).catchError((error) {
      print('Tried to activate contact "${id}" but gave "${error}"');
    });
  }
  
  LIElement receptionContactBox(ReceptionContact_ReducedReception contact) {
    DivElement div = new DivElement()
      ..style.border = '1px solid grey';
    SpanElement header = new SpanElement()
      ..text = contact.receptionName;
    div.children.add(header);
    
    //wants_message
    //enabled
    //attributes.
    UListElement backupList = makeListBox(div, 'Backup', contact.backup);
    UListElement emailList = makeListBox(div, 'E-mail', contact.emailaddresses);
    UListElement handlingList = makeListBox(div, 'E-mail', contact.handling);
    UListElement telephoneNumbersList = makeListBox(div, 'E-mail', contact.telephonenumbers);
    UListElement workhoursList = makeListBox(div, 'E-mail', contact.workhours);
    UListElement tagsList = makeListBox(div, 'E-mail', contact.tags);
    
    

    ButtonElement save = new ButtonElement()
      ..text = 'Gem'
      ..onClick.listen((_) {
        ReceptionContact RC = new ReceptionContact()
          ..contactId = contact.contactId
          ..receptionId = contact.receptionId
          ..distributionListId = contact.distributionListId
          ..contactEnabled = contact.contactEnabled
          ..wantsMessages = contact.wantsMessages
         
          ..backup = getListValues(backupList)
          ..emailaddresses = getListValues(emailList)
          ..handling = getListValues(handlingList)
          ..telephonenumbers = getListValues(telephoneNumbersList)
          ..workhours = getListValues(workhoursList)
          ..tags = getListValues(tagsList);
        
        request.updateReceptionContact(RC.receptionId, RC.contactId, RC.toJson())
        .catchError((error) {
          print('Tried to update a Reception Contact, but failed with "$error"');
        });
      });
    
    div.children.add(save);    
    
    LIElement li = new LIElement();
    li.children.add(div);
    return li;
  }
  
  UListElement makeListBox(Element container, String labelText, List<String> dataList) {
    LabelElement label = new LabelElement();
    UListElement ul = new UListElement();
    
    label.text = labelText;
    fillList(ul, dataList);
    
    container.children.addAll([label, ul]);
    
    return ul;
  }
  
  InputElement makeTextBox(Element container, String labelText, String data) {
    LabelElement label = new LabelElement();
    InputElement inputText = new InputElement();
    
    label.text = labelText;
    inputText.value = data;
    
    container.children.addAll([label, inputText]);
    
    return inputText;
  }
  
  InputElement makeCheckBox(Element container, String labelText, bool data) {
      LabelElement label = new LabelElement();
      CheckboxInputElement inputText = new CheckboxInputElement();
      
      label.text = labelText;
      inputText.checked = data;
      
      container.children.addAll([label, inputText]);
      
      return inputText;
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