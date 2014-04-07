import 'dart:convert';
import 'dart:async';
import 'package:xml/xml.dart';
import 'package:libdialplan/libdialplan.dart';

void main() {
  Dialplan handplan;
  try {
    Map dialplan = JSON.decode(dialplan1);
    handplan = new Dialplan.fromJson(dialplan)
      ..receptionId = 1;

    //print(JSON.encode(handplan.toJson()));

  } catch(e, s) {
    print('error $e');
    print('stack $s');
  }

  List<XmlElement> extensions = generateXml(handplan);

  extensions.forEach(print);
}

List<XmlElement> generateXml(Dialplan dialplan) {
  List<XmlElement> nodes = new List<XmlElement>();

  //The conditions.
  Map<String, List<Condition>> conditions = extractConditions(dialplan);

  //The extension the caller hits.
  XmlElement entry = makeEntryNode(dialplan);
  nodes.add(entry);

  List<XmlElement> conditionVariableSetters = new List<XmlElement>();
  conditions.forEach((k, v) => conditionVariableSetters.add((ConditionVariableSetter(k,v))));

  return nodes;
}

XmlElement makeEntryNode(Dialplan dialplan) {
  XmlElement entry = new XmlElement('extension')
    ..attributes['name'] = 'r_${dialplan.receptionId}';

  XmlElement numberCondition = XmlCondition('destination_number', '^${dialplan.entryNumber}\$');
  entry.children.add(numberCondition);

  XmlElement setId = XmlAction('set', 'receptionid=${dialplan.receptionId}');
  XmlElement main = XmlAction('transfer', mainDestinationName(dialplan.receptionId));

  numberCondition.children.addAll([setId, main]);

  return entry;
}

XmlElement XmlCondition(String field, String expression) =>
    new XmlElement('condition')
  ..attributes['field'] = field
  ..attributes['expression'] = expression;

XmlElement XmlAction(String application, String data) =>
    new XmlElement('action')
    ..attributes['application'] = application
    ..attributes['data'] = data;

String mainDestinationName(int receptionId) => 'r_${receptionId}_main';

Map<String, List<Condition>> extractConditions(Dialplan dialplan) {
  Map<String, List<Condition>> conditions = new Map<String, List<Condition>>();

  for(Extension extension in dialplan.Extensions) {
    if(extension.conditions.isNotEmpty) {
      conditions[extension.name] = extension.conditions;
    }
  }

  return conditions;
}

XmlElement ConditionVariableSetter(String extensionName, List<Condition> conditions) {
  XmlElement node = new XmlElement('extension');

  return node;
}

String dialplan1 = '''
{
    "extensions": [
        {
            "name": "open",
            "conditions": [
                {
                    "condition": "time",
                    "minute-of-day": "480-1020",
                    "wday": "mon-fre",
                }
            ],
            "actions": [
                {
                    "action": "receptionists",
                    "sleeptime": 0,
                    "music": "mohrec7",
                    "welcomefile": "r_7_welcome.wav"
                }
            ]
        },
        {
            "name": "catchall",
            "conditions": [],
            "actions": [
                {
                    "action": "voicemail",
                    "email": "voicemail@responsum.dk"
                }
            ]
        }
    ]
}
''';
