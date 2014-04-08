library generator;

import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/utilities.dart';
import 'package:xml/xml.dart';
import 'package:XmlDialplanGenerator/action_to_xml.dart';

const String TrueVariable = 'True';
const String FalseVariable = 'False';

/**
 * Generates multiple extensions for a receptions dialplan.
 */
List<XmlElement> generateXml(Dialplan dialplan) {
  List<XmlElement> nodes = new List<XmlElement>();

  //Map of Extension names, and its conditions.
  Map<String, List<Condition>> conditions = extractConditions(dialplan);

  //Finds every extension that have conditions
  Map<String, List<Condition>> nonEmptyConditions = new Map<String, List<Condition>>();
  conditions.forEach((k, v) {
    if(v != null && v.isNotEmpty) {
      nonEmptyConditions[k] = v;
    }
  });

  //The extension the caller hits.
  XmlElement entry = makeEntryNode(dialplan,
      nonEmptyConditions.keys
      .map((String extensionName) => conditionSetterExtensionName(dialplan.receptionId, extensionName)));
  nodes.add(entry);

  //Condition variable setter Extensions.
  List<XmlElement> conditionVariableSetters = new List<XmlElement>();
  nonEmptyConditions.forEach((k, v) => conditionVariableSetters.add(ConditionVariableSetter(dialplan.receptionId, k, v)));
  nodes.addAll(conditionVariableSetters);

  //Make actual Extension.
  Iterable<XmlElement> branchingExtensions = dialplan.Extensions.map((ext) => makeBranchingExtensions(ext, dialplan.receptionId));
  nodes.addAll(branchingExtensions);

  return nodes;
}

/**
 * Makes the brancing extensions.
 */
XmlElement makeBranchingExtensions(Extension extension, int receptionId) {
  XmlElement head = new XmlElement('extension')
    ..attributes['name'] = branchingExtensionName(receptionId, extension.name);

  //Makes the conditions.
  XmlElement destCond = XmlCondition('destination_number', mainDestinationName(receptionId));
  head.children.add(destCond);

  if(extension.conditions.isNotEmpty) {
    XmlElement cond = XmlCondition('\${${conditionVariableName(receptionId, extension.name)}}', TrueVariable);
    head.children.add(cond);
  }
  XmlElement lastCondition = head.children.last;

  //Makes all the actions
  lastCondition.children.addAll(extension.actions.map(actionToXml).reduce((List<XmlElement> aList, List<XmlElement> bList) => aList.addAll(bList)));

  return head;
}

/**
 * Makes the extension that catches one the phonenumber.
 */
XmlElement makeEntryNode(Dialplan dialplan, Iterable<String> conditionExtensions) {
  XmlElement entry = new XmlElement('extension')
    ..attributes['name'] = entryExtensionName(dialplan.receptionId);

  XmlElement numberCondition = XmlCondition('destination_number', '^${dialplan.entryNumber}\$');
  entry.children.add(numberCondition);

  XmlElement setId = XmlAction('set', 'receptionid=${dialplan.receptionId}');
  numberCondition.children.add(setId);

  //Executes all the extensions that sets condition variables.
  numberCondition.children.addAll(conditionExtensions.map((extention) => XmlAction('execute_extension', extention)));

  XmlElement main = XmlAction('transfer', mainDestinationName(dialplan.receptionId));
  numberCondition.children.add(main);

  return entry;
}

/** Returns the name of the branching extensions for a reception.*/
String mainDestinationName(int receptionId) => 'r_${receptionId}_main';

/** Returns the name of the entry extension for a reception.*/
String entryExtensionName(int receptionid) => 'r_$receptionid';

/** Returns the name of the extension where the condition variable is set.*/
String conditionSetterExtensionName(int receptionId, String extensionName) => 'r_${receptionId}_cond_${extensionName}';

/**Returns the name of the condition variable used in the branching extensions.*/
String conditionVariableName(int receptionId, String extensionName) => 'r_${receptionId}_${extensionName}';

/** Returns the name of the branching extension.*/
String branchingExtensionName(int receptionId, String extensionName) => 'r_${receptionId}_${extensionName}';

/**
 * Pulls out every conditions list from extensions.
 */
Map<String, List<Condition>> extractConditions(Dialplan dialplan) {
  Map<String, List<Condition>> conditions = new Map<String, List<Condition>>();

  for(Extension extension in dialplan.Extensions) {
    if(extension.conditions.isNotEmpty) {
      conditions[extension.name] = extension.conditions;
    }
  }

  return conditions;
}

/**
 * Makes the extension that sets the condition variable.
 */
XmlElement ConditionVariableSetter(int receptionId, String extensionName, List<Condition> conditions) {
  String condExtensionName = conditionSetterExtensionName(receptionId, extensionName);
  String conditionVariable = conditionVariableName(receptionId, extensionName);
  XmlElement node = new XmlElement('extension')
    ..attributes['name'] = condExtensionName;

  XmlElement destination = XmlCondition('destination_number', condExtensionName)
      ..children.add(XmlAction('set', '${conditionVariable}=${FalseVariable}'));
  node.children.add(destination);

  node.children.addAll(conditions.map((c) => c.toXml()));

  XmlElement last = node.children.last;
  last.children.add(XmlAction('set', '${conditionVariable}=${TrueVariable}'));

  return node;
}

