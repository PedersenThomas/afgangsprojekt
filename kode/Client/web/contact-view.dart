library contact_view;

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'lib/model.dart';
import 'lib/request.dart' as request;
import 'lib/eventbus.dart';
import 'lib/view_utilities.dart';
import 'lib/searchcomponent.dart';

typedef Future HandleReceptionContact(ReceptionContact receptionContact);
typedef Future LazyFuture();

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

  ButtonElement buttonSave, buttonCreate, buttonDelete, buttonJoinReception;
  DivElement receptionOuterSelector;
  
  SearchComponent<Reception> SC;
  int selectedContactId;
  bool createNew = false;
  
  Map<int, LazyFuture> saveList = new Map<int, LazyFuture>();

  ContactView(DivElement this.element) {
    ulContactList = element.querySelector('#contact-list');

    inputName = element.querySelector('#contact-input-name');
    inputType = element.querySelector('#contact-select-type');
    inputEnabled = element.querySelector('#contact-input-enabled');
    ulReceptionContacts = element.querySelector('#reception-contacts');
    ulReceptionList = element.querySelector('#contact-reception-list');

    buttonSave = element.querySelector('#contact-save');
    buttonCreate = element.querySelector('#contact-create');
    buttonDelete = element.querySelector('#contact-delete');
    buttonJoinReception = element.querySelector('#contact-add');
    searchBox = element.querySelector('#contact-search-box');
    receptionOuterSelector = element.querySelector('#contact-reception-selector');
    
    SC = new SearchComponent<Reception>(receptionOuterSelector, 'contact-reception-searchbox')
      ..listElementToString = receptionToSearchboxString
      ..searchFilter = receptionSearchHandler;
        
    registrateEventHandlers();

    refreshList();

    request.getContacttypeList().then((List<String> typesList) {
      inputType.children.addAll(typesList.map((type) => new OptionElement(data: type, value: type)));
    });
  }
  
  String receptionToSearchboxString(Reception reception, String searchterm) {
    return '${reception.full_name}';
  }
  
  bool receptionSearchHandler(Reception reception, String searchTerm) {
    return reception.full_name.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
      if (event.containsKey('contact_id')) {
        activateContact(event['contact_id']);
      }
    });

    buttonSave.onClick.listen((_) => saveChanges());
    buttonCreate.onClick.listen((_) => createContact());
    buttonJoinReception.onClick.listen((_) => addReceptionToContact());
    buttonDelete.onClick.listen((_) => deleteSelectedContact());
    searchBox.onInput.listen((_) => performSearch());
  }

  void refreshList() {
    request.getEveryContact().then((List<Contact> contacts) {
      contacts.sort((a, b) => a.full_name.compareTo(b.full_name));
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
        ..addAll(contactList.where((e) => e.full_name.toLowerCase().contains(
            searchTerm.toLowerCase())).map(makeContactNode));
  }

  LIElement makeContactNode(Contact contact) {
    LIElement li = new LIElement()
        ..classes.add('clickable')
        ..text = '${contact.id} ${contact.full_name}'
        ..onClick.listen((_) => activateContact(contact.id));
    return li;
  }

  void activateContact(int id) {
    request.getContact(id).then((Contact contact) {
      buttonSave.text = 'Gem';
      buttonSave.disabled = false;
      buttonDelete.disabled = false;
      buttonJoinReception.disabled = false;
      createNew = false;
      
      inputName.value = contact.full_name;
      inputType.options.forEach((option) => option.selected = option.value ==
          contact.type);
      inputEnabled.checked = contact.enabled;
      selectedContactId = contact.id;

      return request.getAContactsEveryReception(id).then((List<ReceptionContact_ReducedReception> contacts) {
        if (contacts != null) {
          saveList.clear();
          contacts.sort((a, b) => a.receptionName.compareTo(b.receptionName));
          ulReceptionContacts.children
              ..clear()
              ..addAll(contacts.map((receptioncontact) => receptionContactBox(receptioncontact, receptionContactUpdate)));

          //Rightbar
          ulReceptionList.children
              ..clear()
              ..addAll(contacts.map(makeReceptionNode));
          
          request.getReceptionList().then((List<Reception> receptions) {
            SC.updateSourceList(receptions);
          });
        }
      });
    }).catchError((error) {
      print('Tried to activate contact "${id}" but gave "${error}"');
    });
  }
  
  Future receptionContactUpdate(ReceptionContact RC) {
    return request.updateReceptionContact(RC.receptionId, RC.contactId, RC.toJson()).catchError((error) {
      print('Tried to update a Reception Contact, but failed with "$error"');
    });
  }
  
  Future receptionContactCreate(ReceptionContact RC) {
    return request.createReceptionContact(RC.receptionId, RC.contactId, RC.toJson()).catchError((error) {
      print('Tried to update a Reception Contact, but failed with "$error"');
    });
  }

  /**
   * Make a [LIElement] that contains field for every information about the Contact in that Reception.
   * If any of the fields changes, save to [saveList] a function that calls [receptionContactHandler] with the changed [ReceptionContact]
   * If you want there to always be this function in [saveList] set alwaysAddToSaveList to true.
   */
  LIElement receptionContactBox(ReceptionContact_ReducedReception contact, HandleReceptionContact receptionContactHandler, [bool alwaysAddToSaveList = false]) {
    DivElement div = new DivElement()..classes.add('contact-reception');
    LIElement li = new LIElement();
    SpanElement header = new SpanElement()
      ..text = contact.receptionName
      ..classes.add('reception-contact-header');
    div.children.add(header);
     
    ButtonElement delete = new ButtonElement()
       ..text = 'fjern'
       ..onClick.listen((_) {
         saveList[contact.receptionId] = () {
           return request.deleteReceptionContact(contact.receptionId, contact.contactId)
               .catchError((error) {
             print('deleteReceptionContact error: "error"');
           });
         };
         li.parent.children.remove(li);
       });

       div.children.add(delete);
    
    InputElement wantMessage, enabled, department, info, position, relations,
        responsibility;
    UListElement backupList, emailList, handlingList, telephoneNumbersList,
        workhoursList, tagsList;

    Function onChange = () {
      if (!saveList.containsKey(contact.receptionId)) {
        saveList[contact.receptionId] = () {
          return new Future(() {
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

          receptionContactHandler(RC);
          });
        };
      }
    };
    
    wantMessage = makeCheckBox(div, 'Vil have beskeder', contact.wantsMessages, onChange: onChange);
    enabled = makeCheckBox(div, 'Aktiv', contact.wantsMessages, onChange: onChange);

    department = makeTextBox(div, 'Afdelling', contact.department, onChange: onChange);
    info = makeTextBox(div, 'Andet', contact.info, onChange: onChange);
    position = makeTextBox(div, 'Stilling', contact.position, onChange: onChange);
    relations = makeTextBox(div, 'Relationer', contact.relations, onChange: onChange);
    responsibility = makeTextBox(div, 'Ansvar', contact.responsibility, onChange: onChange);

    backupList = makeListBox(div, 'Backup', contact.backup, onChange: onChange);
    emailList = makeListBox(div, 'E-mail', contact.emailaddresses, onChange: onChange);
    handlingList = makeListBox(div, 'Håndtering', contact.handling, onChange: onChange);
    telephoneNumbersList = makeListBox(div, 'Telefonnumre', contact.telephonenumbers, onChange: onChange);
    workhoursList = makeListBox(div, 'Arbejdstid', contact.workhours, onChange: onChange);
    tagsList = makeListBox(div, 'Stikord', contact.tags, onChange: onChange);

    //In case of creating. You always want it in saveList.
    if(alwaysAddToSaveList) {
      onChange();
    }

    li.children.add(div);
    return li;
  }

  UListElement makeListBox(Element container, String labelText, List<String> dataList, {Function onChange}) {
    LabelElement label = new LabelElement();
    UListElement ul = new UListElement();

    label.text = labelText;
    fillList(ul, dataList, onChange: onChange);

    container.children.addAll([label, ul]);

    return ul;
  }

  InputElement makeTextBox(Element container, String labelText, String data, {Function onChange}) {
    LabelElement label = new LabelElement();
    InputElement inputText = new InputElement();

    label.text = labelText;
    inputText.value = data;
    
    if(onChange != null) {
      inputText.onChange.listen((_) {
        onChange();
      });
    }
    
    container.children.addAll([label, inputText]);

    return inputText;
  }

  InputElement makeCheckBox(Element container, String labelText, bool data, {Function onChange}) {
    LabelElement label = new LabelElement();
    CheckboxInputElement inputCheckbox = new CheckboxInputElement();

    label.text = labelText;
    inputCheckbox.checked = data;

    if(onChange != null) {
      inputCheckbox.onChange.listen((_) {
        onChange();
      });
    }

    container.children.addAll([label, inputCheckbox]);
    return inputCheckbox;
  }

  void saveChanges() {
    int contactId = selectedContactId;
    if (contactId != null && contactId > 0 && createNew == false) {
      List<Future> work = new List<Future>();
      Contact updatedContact = new Contact()
        ..id = contactId
        ..full_name = inputName.value
        ..type = inputType.selectedOptions.first != null ?
            inputType.selectedOptions.first.value : inputType.options.first.value
        ..enabled = inputEnabled.checked;

      work.add(request.updateContact(contactId, updatedContact.toJson()).then((_) {
        //Show a message that tells the user, that the changes went through.
        refreshList();
      }).catchError((error) {
        print('Tried to update a contact but failed with error "${error}" from body: "${updatedContact.toJson()}"');
      }));
            
      work.addAll(saveList.values.map((f) => f()));
      
      //When all updates are applied. Reload the contact.
      Future.wait(work).then((_) {
        return activateContact(contactId);
      }).catchError((error) {
        print('Contact was appling update for ${contactId} when "$error"');
      });
      
    } else if (createNew) {
      Contact newContact = new Contact()
        ..full_name = inputName.value
        ..type = inputType.selectedOptions.first != null ?
            inputType.selectedOptions.first.value : inputType.options.first.value
        ..enabled = inputEnabled.checked;

    request.createContact(newContact.toJson()).then((Map response) {
      //TODO Success Show message?
      refreshList();
      activateContact(response['id']);
    }).catchError((error) {
      print('Tried to make a new contact but failed with error "${error}" from body: "${newContact.toJson()}"');
    });
    }
  }

  clearContent() {
    inputName.value = '';
    inputType.selectedIndex = 0;
    inputEnabled.checked = true;
    ulReceptionContacts.children.clear();
  }
  
  void createContact() {
    selectedContactId = 0;
    buttonSave.text = 'Opret';
    buttonSave.disabled = false;
    buttonDelete.disabled = true;
    buttonJoinReception.disabled = true;
    ulReceptionList.children.clear();
    clearContent();
    createNew = true;
  }
  
  void addReceptionToContact() {
    if(SC.currentElement != null && selectedContactId > 0) {
      //TODO
      print('Add!');
      
      Reception reception = SC.currentElement;
      
      ReceptionContact_ReducedReception template = new ReceptionContact_ReducedReception()
        ..organizationId = reception.organization_id
      
        ..receptionId = reception.id
        ..receptionName = reception.full_name
        ..receptionUri = reception.uri
        ..receptionEnabled = reception.enabled
        
        ..contactId = selectedContactId
        ..wantsMessages = true
        ..contactEnabled = true
        
        ..department = ''
        ..info = ''
        ..position = ''
        ..relations = ''
        ..responsibility = ''
        
        ..backup = []
        ..emailaddresses = []
        ..handling = []
        ..telephonenumbers = []
        ..workhours = []
        ..tags = [];
      
      ulReceptionContacts.children
        ..add(receptionContactBox(template, receptionContactCreate, true));
    }
  }

  LIElement makeReceptionNode(ReceptionContact_ReducedReception reception) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${reception.receptionName}'
      ..onClick.listen((_) {
        Map event = {
          'window': 'reception',
          'organization_id': reception.organizationId,
          'reception_id': reception.receptionId
        };
        bus.fire(windowChanged, event);
      });
    return li;
  }
  
  void deleteSelectedContact() {
    if(!createNew && selectedContactId > 0) {
      request.deleteContact(selectedContactId).then((_) {
        refreshList();
        clearContent();
        buttonSave.disabled = true;
        buttonDelete.disabled = true;
        buttonJoinReception.disabled = true;
        selectedContactId = 0;
      }).catchError((error) {
        print('Failed to delete contact "${selectedContactId}" got "$error"');
      });
    } else {
      print('Failed to delete. createNew: ${createNew} id: ${selectedContactId}');
    }
  }
}
