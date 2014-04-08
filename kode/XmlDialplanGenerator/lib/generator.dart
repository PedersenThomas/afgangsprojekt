library generator;

import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/utilities.dart';
import 'package:xml/xml.dart';
import 'package:XmlDialplanGenerator/action_to_xml.dart';

class GeneratorOutput {
  XmlElement entry;
  XmlElement receptionContext;
}

/**
 * Generates multiple extensions for a receptions dialplan.
 */
GeneratorOutput generateXml(Dialplan dialplan) {
  GeneratorOutput output = new GeneratorOutput();

  //The extension the caller hits.
  output.entry = makeEntryNode(dialplan,[]);

  XmlElement context = new XmlElement('context')
    ..attributes['name'] = contextName(dialplan.receptionId);

  output.receptionContext = context;

  //Make actual Extension.
  Iterable<XmlElement> extensions = dialplan.Extensions.map((Extension ext) => makeReceptionExtensions(ext, dialplan.receptionId));
  context.children.addAll(extensions);

  return output;
}

/**
 * Makes the reception extensions.
 */
XmlElement makeReceptionExtensions(Extension extension, int receptionId) {
  XmlElement head = new XmlElement('extension')
    ..attributes['name'] = receptionExtensionName(receptionId, extension.name);

  if(!extension.isCatchAll) {
    //Makes the conditions.
    XmlElement destCond = XmlCondition('destination_number', mainDestinationName(receptionId));
    head.children.add(destCond);

    head.children.addAll(extension.conditions.map((e) => e.toXml()));
  } else {
    head.children.add(new XmlElement('condition'));
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

  Extension startExtension = dialplan.Extensions.firstWhere((e) => e.isStart);
  XmlElement main = FsTransfer(receptionExtensionName(dialplan.receptionId, startExtension.name), contextName(dialplan.receptionId)); //XmlAction('transfer', receptionExtensionName(dialplan.receptionId, startExtension.name));
  numberCondition.children.add(main);

  return entry;
}

//TODO REMOVE - LIBRARY THIS.
XmlElement FsTransfer(String extension, String context) {
  return XmlAction('transfer', '${extension} xml ${context}');
}

/** Returns the name of the context for the reception*/
String contextName(int receptionId) => 'Rcontext_${receptionId}';

/** Returns the name of the branching extensions for a reception.*/
String mainDestinationName(int receptionId) => 'r_${receptionId}_main';

/** Returns the name of the entry extension for a reception.*/
String entryExtensionName(int receptionid) => 'r_$receptionid';

/** Returns the name of the branching extension.*/
String receptionExtensionName(int receptionId, String extensionName) => 'r_${receptionId}_${extensionName}';

