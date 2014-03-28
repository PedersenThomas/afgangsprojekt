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
  UListElement ulReceptionList;
  List<Contact> contactList = new List<Contact>();
  SearchInputElement searchBox;
  
  InputElement inputName;
  SelectElement inputType;
  CheckboxInputElement inputEnabled;
  
  ButtonElement buttonSave, buttonCreate;
  
  int contactId;
  
  ContactView(DivElement this.element) {
    print('ContactView Constructor');
    ulContactList = element.querySelector('#contact-list');
    
    inputName = element.querySelector('#contact-input-name');
    inputType = element.querySelector('#contact-select-type');
    inputEnabled = element.querySelector('#contact-input-enabled');
    ulReceptionContacts = element.querySelector('#reception-contact');
    ulReceptionList = element.querySelector('#contact-reception-list');

    buttonSave = element.querySelector('#contact-save');
    buttonCreate = element.querySelector('#contact-create');
    searchBox = element.querySelector('#contact-search-box');
    
    registrateEventHandlers();
    
    refreshList();
    
    request.getContacttypeList().then((List<String> typesList) {
      inputType.children.addAll(typesList.map((type) => new OptionElement(data: type, value: type)));
    });
  }
  
  void registrateEventHandlers() {      
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
      if(event.containsKey('contact_id')) {
        activateContact(event['contact_id']);
      }
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
                          .map(makeContactNode));
  }

  LIElement makeContactNode(Contact contact) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = contact.full_name
      ..onClick.listen((_) => activateContact(contact.id));
    return li;
  }
  
  void activateContact(int id) {
    request.getContact(id).then((Contact contact) {
      inputName.value = contact.full_name;
      inputType.options.forEach((option) => option.selected = option.value == contact.type);
      inputEnabled.checked = contact.enabled;
      contactId = contact.id;
      
      return request.getAContactsEveryReception(id).then((List<ReceptionContact_ReducedReception> contacts) {
        UListElement list = element.querySelector('#reception-contacts');
        if(contacts != null) {
          contacts.sort((a, b) => a.receptionName.compareTo(b.receptionName));
          list.children
            ..clear()
            ..addAll(contacts.map(receptionContactBox));
          
          ulReceptionList.children
            ..clear()
            ..addAll(contacts.map(makeReceptionNode));
        }
      });
    }).catchError((error) {
      print('Tried to activate contact "${id}" but gave "${error}"');
    });
  }
  
  LIElement receptionContactBox(ReceptionContact_ReducedReception contact) {
    DivElement div = new DivElement()
      ..classes.add('contact-reception');
    SpanElement header = new SpanElement()
      ..text = contact.receptionName;
    div.children.add(header);
    
    //wants_message
    //enabled
    //attributes.
    InputElement wantMessage = makeCheckBox(div, 'Vil have beskeder', contact.wantsMessages);
    InputElement enabled = makeCheckBox(div, 'Aktiv', contact.wantsMessages);
    
    InputElement department = makeTextBox(div, 'Afdelling', contact.department);
    InputElement info = makeTextBox(div, 'Andet', contact.info);
    InputElement position = makeTextBox(div, 'Stilling', contact.position);
    InputElement relations = makeTextBox(div, 'Relationer', contact.relations);
    InputElement responsibility = makeTextBox(div, 'Ansvar', contact.responsibility);
    
    UListElement backupList = makeListBox(div, 'Backup', contact.backup);
    UListElement emailList = makeListBox(div, 'E-mail', contact.emailaddresses);
    UListElement handlingList = makeListBox(div, 'Håndtering', contact.handling);
    UListElement telephoneNumbersList = makeListBox(div, 'Telefonnumre', contact.telephonenumbers);
    UListElement workhoursList = makeListBox(div, 'Arbejdstid', contact.workhours);
    UListElement tagsList = makeListBox(div, 'Stikord', contact.tags);

    ButtonElement save = new ButtonElement()
      ..text = 'Gem'
      ..onClick.listen((_) {
        ReceptionContact RC = new ReceptionContact()
          ..contactId = contact.contactId
          ..receptionId = contact.receptionId
          ..distributionListId = contact.distributionListId
          ..contactEnabled = enabled.checked
          ..wantsMessages = wantMessage.checked
         
          ..backup = getListValues(backupList)
          ..emailaddresses = getListValues(emailList)
          ..handling = getListValues(handlingList)
          ..telephonenumbers = getListValues(telephoneNumbersList)
          ..workhours = getListValues(workhoursList)
          ..tags = getListValues(tagsList)
          
          ..department = department.value
          ..info = info.value
          ..position = position.value
          ..relations = relations.value
          ..responsibility = responsibility.value;
        
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
        ..type = inputType.selectedOptions.first != null ? inputType.selectedOptions.first.value : inputType.options.first.value
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
      ..type = inputType.selectedOptions.first != null ? inputType.selectedOptions.first.value : inputType.options.first.value
      ..enabled = inputEnabled.checked;
    
    request.createContact(newContact.toJson()).then((_) {
      //TODO Success Show message?
      refreshList();
    }).catchError((error) {
      print('Tried to make a new contact but failed with error "${error}" from body: "${newContact.toJson()}"');
    });
  }
  
  LIElement makeReceptionNode(ReceptionContact_ReducedReception reception) {
    LIElement li = new LIElement();
    li
      ..classes.add('clickable')
      ..text = '${reception.receptionName}'
      ..onClick.listen((_) {
        Map event = {'window': 'reception',
                     'organization_id': reception.organizationId,
                     'reception_id': reception.receptionId};
        bus.fire(windowChanged, event);
      });
    return li;
  }
}