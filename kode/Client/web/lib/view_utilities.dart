library view_utilities;

import 'dart:html';

import 'package:html5_dnd/html5_dnd.dart';

String addNewLiClass = 'addnew';

class _Key{
  static const int ESCAPE = 27;
  static const int ENTER = 13;
}

void fillList(UListElement element, List<String> items) {
  List<LIElement> children = new List<LIElement>();
  if(items != null) {
    for(String item in items) {
        LIElement li = simpleListElement(item);      
        children.add(li);
      } 
  }

  SortableGroup sortGroup = new SortableGroup()
    ..installAll(children)
    ..onSortUpdate.listen((SortableEvent event) {
      // do something when user sorted the elements...
    });

  // Only accept elements from this section.
  sortGroup.accept.add(sortGroup);
  
  InputElement inputNewItem = new InputElement();
  inputNewItem
    ..classes.add(addNewLiClass)
    ..placeholder = 'Add new...'
    ..onKeyPress.listen((KeyboardEvent event) {
      KeyEvent key = new KeyEvent.wrap(event);
      if(key.keyCode == _Key.ENTER) {
        String item = inputNewItem.value;
        inputNewItem.value = '';
        
        LIElement li = simpleListElement(item);
        int index = element.children.length -1;
        sortGroup.install(li);
        element.children.insert(index, li);
      }
    });
  
  children.add(new LIElement()..children.add(inputNewItem));
  
  element.children
    ..clear()
    ..addAll(children);
}

LIElement simpleListElement(String item) {
  LIElement li = new LIElement();
  ButtonElement deleteButton = new ButtonElement()
    ..text = 'Slet'
    ..onClick.listen((_) {
      li.parent.children.remove(li);
    });
  SpanElement content = new SpanElement()
    ..text = item;
  
  li..children.addAll([deleteButton, content]);
  
  bool activeEdit = false;
  li.onClick.listen((_) {
    if(!activeEdit) {
      activeEdit = true;
      String oldDisplay = content.style.display;
      content.style.display = 'none';
      InputElement editBox = new InputElement(type: 'text');
      li.children.add(editBox);
      editBox
        ..focus()
        ..value = content.text
        ..onKeyDown.listen((KeyboardEvent event) {
          KeyEvent key = new KeyEvent.wrap(event);
          if(key.keyCode == _Key.ENTER || key.keyCode == _Key.ESCAPE) {
            if(key.keyCode == _Key.ENTER) {
              content.text = editBox.value;
            }
            content.style.display = oldDisplay;
            li.children.remove(editBox);
            activeEdit = false;
          }
        });
    }
  });
  return li;
}

List<String> getListValues(UListElement element) {
  List<String> texts = new List<String>();
  for(LIElement e in element.children) {
    if(!e.classes.contains(addNewLiClass)) {
      SpanElement content = e.children.firstWhere((elem) => elem is SpanElement, orElse: () => null);
      if (content != null) {
        texts.add(content.text);
      }
    }
  }
  return texts;
}
