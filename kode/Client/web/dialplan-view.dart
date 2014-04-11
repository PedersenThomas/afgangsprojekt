library dialplan_view;

import 'dart:html';

import 'lib/eventbus.dart';
import 'lib/logger.dart' as log;
import 'lib/request.dart';
import 'package:libdialplan/libdialplan.dart';

class _ControlLookUp {
  static const int forward = 0;
  static const int receptionist = 1;
  static const int voicemail = 2;
  static const int audiofile = 3;
  static const int ivr = 4;
}

class DialplanView {
  String viewName = 'dialplan';

  DivElement element;
  UListElement controlList;
  UListElement itemsList;
  UListElement extensionList;
  ButtonElement extensionAdd;
  DivElement settingPanel;
  TextAreaElement commentTextarea;

  Dialplan dialplan;

  DialplanView(DivElement this.element) {
    controlList = element.querySelector('#dialplan-control-list');
    itemsList = element.querySelector('#dialplan-items-list');
    extensionList = element.querySelector('#dialplan-extension-list');
    extensionAdd = element.querySelector('#dialplan-extension-add');
    settingPanel = element.querySelector('#dialplan-settings');
    commentTextarea = element.querySelector('#dialplan-comment');

    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
      if(event.containsKey('receptionid')) {
        activateDialplan(event['receptionid']);
      }
    });

    controlList.children.forEach((LIElement li) {
      li.onClick.listen((_) => hanleControlClick(li.value));
    });

    extensionAdd.onClick.listen((_) {
      if(dialplan != null) {
        Extension newExtension = new Extension();

        //Find a new extension name that is not taken.
        int count = 1;
        String genericName = 'extension${count}';
        while(dialplan.Extensions.any((e) => e.name == genericName)) {
          print(count);
          count += 1;
          genericName = 'extension${count}';
        }

        newExtension.name = genericName;
        dialplan.Extensions.add(newExtension);
        UpdateExtensionList();
        activateExtension(newExtension);
      }
    });
  }

  void activateDialplan(int receptionId) {
    getDialplan(receptionId).then((Dialplan value) {
      dialplan = value;

      UpdateExtensionList();

      Extension startExtension = dialplan.Extensions.firstWhere((e) => e.isStart, orElse: () => null);
      if(startExtension != null) {
        activateExtension(startExtension);
      }
    });
  }

  void UpdateExtensionList() {
    extensionList.children.clear();
    if(dialplan != null && dialplan.Extensions != null) {
      extensionList.children.addAll(dialplan.Extensions.map(ExtensionListItem));
    }
  }

  LIElement ExtensionListItem(Extension extension) {
    LIElement li = new LIElement()
      ..text = extension.name
      ..onClick.listen((_) {
      activateExtension(extension);
    });

    return li;
  }

  void hanleControlClick(int value) {
    log.debug(value);
  }

  void activateExtension(Extension extension) {
    if(extension != null) {
      itemsList.children.clear();
      for(Condition condition in extension.conditions) {
        if(condition is Time) {
          itemsList.children.add(new LIElement()..text = 'Tidsstyring');
        }
      }

      for(Action action in extension.actions) {
        LIElement li = new LIElement();
        if(action is Forward) {
          li.text = 'Viderstil';
          li.onClick.listen((_) {
            settingsActionForward(action);
          });

        } else if(action is ExecuteIvr) {
          li.text = 'Ivrmenu';

        } else if(action is PlayAudio) {
          li.text = 'Afspil lyd';

        } else if(action is Receptionists) {
          li.text = 'Reception';
          li.onClick.listen((_) {
            settingsActionReceptionists(action);
          });

        } else if(action is Voicemail) {
          li.text = 'Telefonsvare';

        } else {
          li.text = 'Ukendt';
        }
        itemsList.children.add(li);
      }
    }
  }

  void settingsActionForward(Forward action) {
    settingPanel.children.clear();
    InputElement numberInput = new InputElement()
      ..id = 'extension-setting-number'
      ..value = action.number;

    LabelElement numberLabel = new LabelElement()
      ..text = 'Nummer'
      ..htmlFor = numberInput.id;

    commentTextarea.value = action.comment;

    ButtonElement save = new ButtonElement()
      ..onClick.listen((_) {
      action.number = numberInput.value;
      action.comment = commentTextarea.value;

      //TODO save.
    });

    settingPanel.children.addAll([numberLabel, numberInput, save]);
  }

  void settingsActionReceptionists(Receptionists action) {
    settingPanel.children.clear();
    NumberInputElement sleepTimeInput = new NumberInputElement()
      ..id = 'extension-setting-sleepTime'
      ..value = action.sleepTime.toString();

    LabelElement numberLabel = new LabelElement()
      ..text = 'Ventetid'
      ..htmlFor = sleepTimeInput.id;

    InputElement musicInput = new InputElement()
      ..id = 'extension-setting-music'
      ..value = action.music;

    LabelElement musicLabel = new LabelElement()
      ..text = 'Ventemusik'
      ..htmlFor = musicInput.id;

    commentTextarea.value = action.comment;

    ButtonElement save = new ButtonElement()
      ..onClick.listen((_) {
      action.sleepTime = int.parse(sleepTimeInput.value);
      action.music = musicInput.value;
      action.comment = commentTextarea.value;

      //TODO save.
    });

    settingPanel.children.addAll([numberLabel, sleepTimeInput, save]);
  }
}
