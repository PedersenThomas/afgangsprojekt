library dialplan_view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'lib/eventbus.dart';
import 'lib/logger.dart' as log;
import 'lib/request.dart' as request;
import 'package:libdialplan/libdialplan.dart';

class _ControlLookUp {
  static const int timeControl = 0;
  static const int forward = 1;
  static const int receptionist = 2;
  static const int voicemail = 3;
  static const int playAudioFile = 4;
  static const int ivr = 5;
}

class DialplanView {
  String viewName = 'dialplan';
  int selectedReceptionId;

  DivElement element;
  UListElement controlList;
  UListElement itemsList;
  UListElement extensionList;
  ButtonElement extensionAdd;
  DivElement settingPanel;
  TextAreaElement commentTextarea;

  Dialplan dialplan;
  Extension selectedExtension;

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
      if (event.containsKey('receptionid')) {
        activateDialplan(event['receptionid']);
      }
    });

    controlList.children.forEach((LIElement li) {
      li.onClick.listen((_) => hanleControlClick(li.value));
    });

    extensionAdd.onClick.listen((_) {
      if (dialplan != null) {
        Extension newExtension = new Extension();

        //Find a new extension name that is not taken.
        int count = 1;
        String genericName = 'extension${count}';
        while (dialplan.Extensions.any((e) => e.name == genericName)) {
          print(count);
          count += 1;
          genericName = 'extension${count}';
        }

        newExtension.name = genericName;
        dialplan.Extensions.add(newExtension);
        renderExtensionList(dialplan);
        activateExtension(newExtension);

        updateDialplan();
      }
    });
  }

  void activateDialplan(int receptionId) {
    request.getDialplan(receptionId).then((Dialplan value) {
      dialplan = value;
      selectedReceptionId = receptionId;
      renderExtensionList(value);

      Extension startExtension = dialplan.Extensions.firstWhere((e) =>
          e.isStart, orElse: () => null);
      if (startExtension != null) {
        activateExtension(startExtension);
      }
    });
  }

  void renderExtensionList(Dialplan dialplan) {
    extensionList.children.clear();
    if (dialplan != null && dialplan.Extensions != null) {
      extensionList.children.addAll(dialplan.Extensions.map(extensionListItem));
    }
  }

  Future updateDialplan() {
    if (selectedReceptionId != null && selectedReceptionId > 0) {
      return request.updateDialplan(selectedReceptionId, JSON.encode(
          dialplan.toJson())).catchError((error) {
        log.error('Update Dialplan gave ${error}');
      });
    } else {
      return new Future.value();
    }
  }

  LIElement extensionListItem(Extension extension) {
    LIElement li = new LIElement()
        ..text = extension.name
        ..onClick.listen((_) {
          activateExtension(extension);
        });

    return li;
  }

  void hanleControlClick(int value) {
    if (selectedExtension != null) {
      switch (value) {
        case _ControlLookUp.timeControl:
          Time condition = new Time();
          selectedExtension.conditions.add(condition);
          break;

        case _ControlLookUp.forward:
          Forward action = new Forward();
          selectedExtension.actions.add(action);
          break;

        case _ControlLookUp.receptionist:
          Receptionists action = new Receptionists();
          selectedExtension.actions.add(action);
          break;

        case _ControlLookUp.voicemail:
          Voicemail action = new Voicemail();
          selectedExtension.actions.add(action);
          break;

        case _ControlLookUp.playAudioFile:
          PlayAudio action = new PlayAudio();
          selectedExtension.actions.add(action);
          break;

        case _ControlLookUp.ivr:
          ExecuteIvr action = new ExecuteIvr();
          selectedExtension.actions.add(action);
          break;
      }

      activateExtension(selectedExtension);
    }
  }

  void activateExtension(Extension extension) {
    if (extension != null) {
      selectedExtension = extension;
      itemsList.children.clear();
      for (Condition condition in extension.conditions) {
        if (condition is Time) {
          itemsList.children.add(new LIElement()
              ..text = 'Tidsstyring'
              ..onClick.listen((_) {
                settingsConditionTime(condition);
              }));
        }
      }

      settingsExtension(extension);

      for (Action action in extension.actions) {
        LIElement li = new LIElement();
        if (action is Forward) {
          li.text = 'Viderstil';
          li.onClick.listen((_) {
            settingsActionForward(action);
          });

        } else if (action is ExecuteIvr) {
          li.text = 'Ivrmenu';
          li.onClick.listen((_) {
            settingsActionExecuteIvr(action);
          });

        } else if (action is PlayAudio) {
          li.text = 'Afspil lyd';
          li.onClick.listen((_) {
            settingsActionPlayAudio(action);
          });

        } else if (action is Receptionists) {
          li.text = 'Reception';
          li.onClick.listen((_) {
            settingsActionReceptionists(action);
          });

        } else if (action is Voicemail) {
          li.text = 'Telefonsvare';

        } else {
          li.text = 'Ukendt';
        }
        itemsList.children.add(li);
      }
    }
  }

  void settingsExtension(Extension extension) {
      settingPanel.children.clear();
      InputElement nameInput = new InputElement()
          ..id = 'extension-setting-name'
          ..value = extension.name;
      LabelElement nameLabel = new LabelElement()
          ..text = 'Navn'
          ..htmlFor = nameInput.id;

      CheckboxInputElement startInput = new CheckboxInputElement()
          ..id = 'extension-setting-start'
          ..checked = extension.isStart;
      LabelElement startLabel = new LabelElement()
          ..text = 'Start'
          ..htmlFor = startInput.id;

      CheckboxInputElement catchInput = new CheckboxInputElement()
          ..id = 'extension-setting-catch'
          ..checked = extension.isCatchAll;
      LabelElement catchLabel = new LabelElement()
          ..text = 'Grib fejl'
          ..htmlFor = catchInput.id;

      commentTextarea.value = extension.comment;

      ButtonElement save = new ButtonElement()
          ..text = 'Gem'
          ..onClick.listen((_) {
        extension.name = nameInput.value;
        extension.comment = commentTextarea.value;
        extension.isStart = startInput.checked;
        extension.isCatchAll = catchInput.checked;
            //TODO save.
          });

      settingPanel.children.addAll([nameLabel, nameInput, startLabel, startInput, catchLabel, catchInput, save]);
    }

  void settingsConditionTime(Time condition) {
    settingPanel.children.clear();
    InputElement timeOfDayInput = new InputElement()
        ..id = 'extension-setting-timeofday'
        ..placeholder = '08:00-17:00'
        ..value = condition.timeOfDay;
    LabelElement timeOfDayLabel = new LabelElement()
        ..text = 'timeOfDay'
        ..htmlFor = timeOfDayInput.id;

    InputElement wdayInput = new InputElement()
        ..id = 'extension-setting-wday'
        ..placeholder = 'mon-tue, wed, thu, fri-sat, sun'
        ..value = condition.timeOfDay;
    LabelElement wdayLabel = new LabelElement()
        ..text = 'wday'
        ..htmlFor = wdayInput.id;

    InputElement ydayInput = new InputElement()
        ..id = 'extension-setting-yday'
        ..placeholder = '2014-2020'
        ..value = condition.timeOfDay;
    LabelElement ydayLabel = new LabelElement()
        ..text = 'yday'
        ..htmlFor = ydayInput.id;

    commentTextarea.value = condition.timeOfDay;

    ButtonElement save = new ButtonElement()
        ..text = 'Gem'
        ..onClick.listen((_) {
          condition.timeOfDay = timeOfDayInput.value;
          condition.comment = commentTextarea.value;
          condition.wday = wdayInput.value;
          condition.yday = ydayInput.value;

          //TODO save.
        });

    settingPanel.children.addAll([timeOfDayLabel, timeOfDayInput, wdayLabel,
        wdayInput, ydayLabel, ydayInput, save]);
  }

  void settingsActionPlayAudio(PlayAudio action) {
    settingPanel.children.clear();
    InputElement numberInput = new InputElement()
        ..id = 'extension-setting-audiofile'
        ..value = action.filename;

    LabelElement numberLabel = new LabelElement()
        ..text = 'Lydfil'
        ..htmlFor = numberInput.id;

    commentTextarea.value = action.comment;

    ButtonElement save = new ButtonElement()
        ..text = 'Gem'
        ..onClick.listen((_) {
          action.filename = numberInput.value;
          action.comment = commentTextarea.value;

          //TODO save.
        });

    settingPanel.children.addAll([numberLabel, numberInput, save]);
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
        ..text = 'Gem'
        ..onClick.listen((_) {
          action.number = numberInput.value;
          action.comment = commentTextarea.value;

          //TODO save.
        });

    settingPanel.children.addAll([numberLabel, numberInput, save]);
  }

  void settingsActionExecuteIvr(ExecuteIvr action) {
    settingPanel.children.clear();
    InputElement ivrnameInput = new InputElement()
        ..id = 'extension-setting-ivrname'
        ..value = action.ivrname;

    LabelElement ivrnameLabel = new LabelElement()
        ..text = 'Ivr navn'
        ..htmlFor = ivrnameInput.id;

    commentTextarea.value = action.comment;

    ButtonElement save = new ButtonElement()
        ..text = 'Gem'
        ..onClick.listen((_) {
          action.ivrname = ivrnameInput.value;
          action.comment = commentTextarea.value;

          //TODO save.
        });

    settingPanel.children.addAll([ivrnameLabel, ivrnameInput, save]);
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

    InputElement welcomeInput = new InputElement()
        ..id = 'extension-setting-welcomefile'
        ..value = action.welcomeFile;
    LabelElement welcomeLabel = new LabelElement()
        ..text = 'Velkomst lydfil'
        ..htmlFor = musicInput.id;

    commentTextarea.value = action.comment;

    ButtonElement save = new ButtonElement()
        ..text = 'Gem'
        ..onClick.listen((_) {
          action.sleepTime = int.parse(sleepTimeInput.value);
          action.music = musicInput.value;
          action.comment = commentTextarea.value;
          action.welcomeFile = welcomeInput.value;

          //TODO save.
        });

    settingPanel.children.addAll([numberLabel, sleepTimeInput, musicLabel,
        musicInput, welcomeLabel, welcomeInput, save]);
  }
}
