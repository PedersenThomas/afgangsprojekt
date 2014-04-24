library dialplan_view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'lib/eventbus.dart';
import 'lib/logger.dart' as log;
import 'lib/model.dart';
import 'lib/request.dart' as request;
import 'package:libdialplan/libdialplan.dart';
import 'lib/searchcomponent.dart';

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
  StreamSubscription<Event> commentTextSubscription;
  DivElement receptionOuterSelector;
  ButtonElement saveButton;

  SearchComponent SC;
  Dialplan dialplan;
  Extension selectedExtension;

  DialplanView(DivElement this.element) {
    controlList = element.querySelector('#dialplan-control-list');
    itemsList = element.querySelector('#dialplan-items-list');
    extensionList = element.querySelector('#dialplan-extension-list');
    extensionAdd = element.querySelector('#dialplan-extension-add');
    settingPanel = element.querySelector('#dialplan-settings');
    commentTextarea = element.querySelector('#dialplan-comment');
    saveButton = element.querySelector('#dialplan-savebutton');

    receptionOuterSelector = element.querySelector('#dialplan-receptionbar');

    SC = new SearchComponent<Reception>(receptionOuterSelector,
        'dialplan-reception-searchbox')
        ..listElementToString = receptionToSearchboxString
        ..searchFilter = receptionSearchHandler;

    fillSearchComponent();

    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
      if (event.containsKey('receptionid')) {
        activateDialplan(event['receptionid']);
      }
    });

    SC.selectedElementChanged = SearchComponentChanged;

    saveButton.onClick.listen((_) {
      saveDialplan();
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

        saveDialplan();
      }
    });
  }

  void SearchComponentChanged(Reception reception) {
    activateDialplan(reception.id);
  }

  String receptionToSearchboxString(Reception reception, String searchterm) {
    return '${reception.full_name}';
  }

  bool receptionSearchHandler(Reception reception, String searchTerm) {
    return reception.full_name.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void fillSearchComponent() {
    request.getReceptionList().then((List<Reception> list) {
      list.sort((a, b) => a.full_name.compareTo(b.full_name));
      SC.updateSourceList(list);
    });
  }

  void activateDialplan(int receptionId) {
    SC.selectElement(null, (Reception a,_) => a.id == receptionId);

    request.getDialplan(receptionId).then((Dialplan value) {
      dialplan = value;
      selectedReceptionId = receptionId;
      renderExtensionList(value);

      Extension startExtension = dialplan.Extensions.firstWhere((e) =>
          e.isStart, orElse: () => dialplan.Extensions.isNotEmpty ? dialplan.Extensions.first : null);
      activateExtension(startExtension);
    });
  }

  void renderExtensionList(Dialplan dialplan) {
    extensionList.children.clear();
    if (dialplan != null && dialplan.Extensions != null) {
      extensionList.children.addAll(dialplan.Extensions.map(extensionListItem));
    }
  }

  Future saveDialplan() {
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
    LIElement li = new LIElement();

    ButtonElement deleteButton = new ButtonElement()
      ..text = 'Slet'
      ..onClick.listen((_) {
      dialplan.Extensions.remove(extension);
    });
    SpanElement text = new SpanElement()
        ..text = '${extension.name}${extension.isStart ? '(s)' : ''}${extension.isCatchAll ? '(c)' : ''}'
        ..onClick.listen((_) {
          activateExtension(extension);
        });
    li.children.addAll([deleteButton, text]);
    return li;
  }

  void hanleControlClick(int value) {
    if (selectedExtension != null) {
      switch (value) {
        case _ControlLookUp.timeControl:
          Time condition = new Time();
          selectedExtension.conditions.add(condition);
          settingsConditionTime(condition);
          break;

        case _ControlLookUp.forward:
          Forward action = new Forward();
          selectedExtension.actions.add(action);
          settingsActionForward(action);
          break;

        case _ControlLookUp.receptionist:
          Receptionists action = new Receptionists();
          selectedExtension.actions.add(action);
          settingsActionReceptionists(action);
          break;

        case _ControlLookUp.voicemail:
          Voicemail action = new Voicemail();
          selectedExtension.actions.add(action);
          settingsActionVoicemail(action);
          break;

        case _ControlLookUp.playAudioFile:
          PlayAudio action = new PlayAudio();
          selectedExtension.actions.add(action);
          settingsActionPlayAudio(action);
          break;

        case _ControlLookUp.ivr:
          ExecuteIvr action = new ExecuteIvr();
          selectedExtension.actions.add(action);
          settingsActionExecuteIvr(action);
          break;
      }

      renderContent();
    }
  }

  void renderSelectedExtensionActions() {
    if(selectedExtension != null) {
      for (Action action in selectedExtension.actions) {
        LIElement li = new LIElement();
        ImageElement image = new ImageElement()
          ..classes.add('dialplan-controlitem-img');
        SpanElement nameTag = new SpanElement()
          ..classes.add('dialplan-controlitem-nametag');
        li.children.addAll([image, nameTag]);

        if (action is Forward) {
          image.src = 'image/tp/bendedarrow.svg';
          nameTag.text = 'Viderstil';
          li.onClick.listen((_) {
            settingsActionForward(action);
          });

        } else if (action is ExecuteIvr) {
          image.src = 'image/organization_icon.svg';
          nameTag.text = 'Ivrmenu';
          li.onClick.listen((_) {
            settingsActionExecuteIvr(action);
          });

        } else if (action is PlayAudio) {
          image.src = 'image/tp/speaker.svg';
          nameTag.text = 'Afspil lyd';
          li.onClick.listen((_) {
            settingsActionPlayAudio(action);
          });

        } else if (action is Receptionists) {
          image.src = 'image/tp/multiplemen.svg';
          nameTag.text = 'Reception';
          li.onClick.listen((_) {
            settingsActionReceptionists(action);
          });

        } else if (action is Voicemail) {
          image.src = 'image/tp/microphone.svg';
          nameTag.text = 'Telefonsvare';
          li.onClick.listen((_) {
            settingsActionVoicemail(action);
          });

        } else {
          image.src = 'image/organization_icon_disable.svg';
          nameTag.text = 'Ukendt';
        }
        itemsList.children.add(li);
      }
    }
  }

  void renderSelectedExtensionCondition() {
    if(selectedExtension != null) {
      for (Condition condition in selectedExtension.conditions) {
        if (condition is Time) {
          ImageElement image = new ImageElement(src: 'image/tp/time.svg')
            ..classes.add('dialplan-controlitem-img');
          SpanElement nameTag = new SpanElement()
            ..text = 'Tidsstyring'
            ..classes.add('dialplan-controlitem-nametag');

          itemsList.children.add(new LIElement()
              ..children.addAll([image, nameTag])
              ..onClick.listen((_) {
                settingsConditionTime(condition);
              }));
        }
      }
    }
  }

  void activateExtension(Extension extension) {
    if (extension != null) {
      selectedExtension = extension;
      settingsExtension(extension);
    }
    renderContent();
  }

  void renderContent() {
    itemsList.children.clear();
    renderSelectedExtensionCondition();
    renderSelectedExtensionActions();
  }

  void settingsExtension(Extension extension) {
      settingPanel.children.clear();
      String html = '''
      <ul class="dialplan-settingsList">
        <li>
            <label for="dialplan-setting-extensionname">Navn</label>
            <input id="dialplan-setting-extensionname" type="text" value="${extension.name != null ? extension.name : ''}">
        </li>
        <li>
            <label for="dialplan-setting-extensionstart">Start</label>
            <input id="dialplan-setting-extensionstart" type="checkbox" ${extension.isStart ? 'checked': ''}>
        </li>
        <li>
            <label for="dialplan-setting-extensioncatch">Grib fejl</label>
            <input id="dialplan-setting-extensioncatch" type="checkbox" ${extension.isCatchAll ? 'checked': ''}>
        </li>
        <li>
            <label for="dialplan-setting-extensioncatch">failover</label>
            <select id="dialplan-setting-extensionfailover">
              <option value="none">Ingen</option>
            </select>
        </li>
      </ul>
      ''';

      DocumentFragment fragment = new DocumentFragment.html(html);
      settingPanel.children.addAll(fragment.children);

      InputElement nameInput = settingPanel.querySelector('#dialplan-setting-extensionname');
      nameInput
        ..onInput.listen((_) {
        extension.name = nameInput.value;
        renderExtensionList(dialplan);
      })
      ..onInvalid.listen((_) {
        nameInput.title = nameInput.validationMessage;
      });

      CheckboxInputElement startInput = settingPanel.querySelector('#dialplan-setting-extensionstart');
      startInput.onChange.listen((_) {
         extension.isStart = startInput.checked;
         renderExtensionList(dialplan);
      });

      SelectElement failover = settingPanel.querySelector('#dialplan-setting-extensionfailover');
      for(Extension ext in dialplan.Extensions) {
        if(!ext.isStart && !ext.isCatchAll && extension != ext) {
          OptionElement opt = new OptionElement()
            ..text = ext.name
            ..value = ext.name;

          if(ext.name == extension.failoverExtension) {
            opt.selected = true;
          }

          failover.children.add(opt);
        }
      }
      failover.onChange.listen((_) {
        if(failover.selectedIndex == 0) {
          extension.failoverExtension = '';
        } else {
          extension.failoverExtension = failover.options[failover.selectedIndex].value;
        }
      });

      CheckboxInputElement catchInput = settingPanel.querySelector('#dialplan-setting-extensioncatch');
      catchInput.onChange.listen((_) {
         extension.isCatchAll = catchInput.checked;
         renderExtensionList(dialplan);
      });

      commentTextarea.value = extension.comment;
      if(commentTextSubscription != null) {
        commentTextSubscription.cancel();
      }
      commentTextSubscription = commentTextarea.onInput.listen((_) {
        extension.comment = commentTextarea.value;
      });
    }

  void settingsConditionTime(Time condition) {
    settingPanel.children.clear();

    String html = '''
    <ul class="dialplan-settingsList">
      <li>
          <label for="dialplan-setting-timeofday">Time Of day</label>
          <input id="dialplan-setting-timeofday" type="text" value="${condition.timeOfDay != null ? condition.timeOfDay != null : ''}" placeholder="08:00-17:00">
      </li>
      <li>
          <label for="dialplan-setting-wday">Ugedage</label>
          <input id="dialplan-setting-wday" type="text" value="${condition.wday != null ? condition.wday : ''}" placeholder="mon-tue, wed, thu, fri-sat, sun">
      </li>
    </ul>
    ''';
    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    InputElement timeOfDayInput = settingPanel.querySelector('#dialplan-setting-timeofday');
    timeOfDayInput
      ..onInput.listen((_) {
        condition.timeOfDay = timeOfDayInput.value.isEmpty ? null : timeOfDayInput.value;
      });

    InputElement wdayInput = settingPanel.querySelector('#dialplan-setting-wday');
    wdayInput
      ..onInput.listen((_) {
        condition.wday = wdayInput.value;
    });

    commentTextarea.value = condition.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      condition.comment = commentTextarea.value;
    });

//    ButtonElement save = new ButtonElement()
//        ..text = 'Gem'
//        ..onClick.listen((_) {
//          condition.timeOfDay = timeOfDayInput.value;
//          condition.comment = commentTextarea.value;
//          condition.wday = wdayInput.value;
//
//          updateDialplan();
//        });

//    settingPanel.children.addAll([timeOfDayLabel, timeOfDayInput, wdayLabel,
//        wdayInput]);
  }

  void settingsActionPlayAudio(PlayAudio action) {
    settingPanel.children.clear();
    //TODO Der skal være en liste af filer her.
    InputElement numberInput = new InputElement();
    numberInput
        ..id = 'extension-setting-audiofile'
        ..value = action.filename
        ..onInput.listen((_) {
      action.filename = numberInput.value;
    });

    LabelElement numberLabel = new LabelElement()
        ..text = 'Lydfil'
        ..htmlFor = numberInput.id;

    commentTextarea.value = action.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      action.comment = commentTextarea.value;
    });

    settingPanel.children.addAll([numberLabel, numberInput]);
  }

  void settingsActionForward(Forward action) {
    settingPanel.children.clear();

    InputElement numberInput = new InputElement();
    numberInput
        ..id = 'extension-setting-number'
        ..value = action.number
        ..onInput.listen((_) {
      action.number = numberInput.value;
    });
    LabelElement numberLabel = new LabelElement()
        ..text = 'Nummer'
        ..htmlFor = numberInput.id;

    commentTextarea.value = action.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      action.comment = commentTextarea.value;
    });

    settingPanel.children.addAll([numberLabel, numberInput]);
  }

  void settingsActionExecuteIvr(ExecuteIvr action) {
    settingPanel.children.clear();

    InputElement ivrnameInput = new InputElement();
    ivrnameInput
        ..id = 'extension-setting-ivrname'
        ..value = action.ivrname
        ..onInput.listen((_) {
      action.ivrname = ivrnameInput.value;
    });
    LabelElement ivrnameLabel = new LabelElement()
        ..text = 'Ivr navn'
        ..htmlFor = ivrnameInput.id;

    commentTextarea.value = action.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      action.comment = commentTextarea.value;
    });

//    ButtonElement save = new ButtonElement()
//        ..text = 'Gem'
//        ..onClick.listen((_) {
//          action.ivrname = ivrnameInput.value;
//          action.comment = commentTextarea.value;
//
//          updateDialplan();
//        });

    settingPanel.children.addAll([ivrnameLabel, ivrnameInput]);
  }

  void settingsActionReceptionists(Receptionists action) {
    settingPanel.children.clear();

    NumberInputElement sleepTimeInput = new NumberInputElement();
    sleepTimeInput
        ..id = 'extension-setting-sleepTime'
        ..value = action.sleepTime.toString()
        ..onInput.listen((_) {
      try {
        int sleepTime = int.parse(sleepTimeInput.value);
        action.sleepTime = sleepTime;
      } catch(_) {}
    });
    LabelElement numberLabel = new LabelElement()
        ..text = 'Ventetid'
        ..htmlFor = sleepTimeInput.id;

    InputElement musicInput = new InputElement();
    musicInput
        ..id = 'extension-setting-music'
        ..value = action.music
        ..onInput.listen((_) {
      action.music = musicInput.value;
    });
    LabelElement musicLabel = new LabelElement()
        ..text = 'Ventemusik'
        ..htmlFor = musicInput.id;

    InputElement welcomeInput = new InputElement();
    welcomeInput
        ..id = 'extension-setting-welcomefile'
        ..value = action.welcomeFile
        ..onInput.listen((_) {
      action.welcomeFile = welcomeInput.value;
    });
    LabelElement welcomeLabel = new LabelElement()
        ..text = 'Velkomst lydfil'
        ..htmlFor = musicInput.id;

    commentTextarea.value = action.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      action.comment = commentTextarea.value;
    });

//    ButtonElement save = new ButtonElement()
//        ..text = 'Gem'
//        ..onClick.listen((_) {
//          action.sleepTime = int.parse(sleepTimeInput.value);
//          action.music = musicInput.value;
//          action.comment = commentTextarea.value;
//          action.welcomeFile = welcomeInput.value;
//
//          updateDialplan();
//        });

    settingPanel.children.addAll([numberLabel, sleepTimeInput, musicLabel,
        musicInput, welcomeLabel, welcomeInput]);
  }

  void settingsActionVoicemail(Voicemail action) {
    settingPanel.children.clear();
    InputElement emailInput = new InputElement();
    emailInput
        ..id = 'extension-setting-email'
        ..value = action.email
        ..onInput.listen((_) {
        action.email = emailInput.value;
    });
    LabelElement emailLabel = new LabelElement()
        ..text = 'email'
        ..htmlFor = emailInput.id;

    commentTextarea.value = action.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      action.comment = commentTextarea.value;
    });

//    ButtonElement save = new ButtonElement()
//        ..text = 'Gem'
//        ..onClick.listen((_) {
//          action.email = emailInput.value;
//          action.comment = commentTextarea.value;
//
//          updateDialplan();
//        });

    settingPanel.children.addAll([emailLabel, emailInput]);
  }
}
