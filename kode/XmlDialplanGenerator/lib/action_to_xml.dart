library ActionToXml;

import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/utilities.dart';
import 'package:xml/xml.dart';

List<XmlElement> actionToXml(Action action) {
  if(action is Receptionists) {
    return receptionist(action);

  } else if (action is Voicemail) {
    return voicemail(action);

  } else if (action is PlayAudio) {
    return playAudio(action);

  } else {
    return [];
  }
}

List<XmlElement> receptionist(Receptionists action) {
  List<XmlElement> nodes = new List<XmlElement>();

  nodes.add(XmlAction('transfer', 'prequeue XML default'));

  return nodes;
}

List<XmlElement> voicemail(Voicemail action) {
  List<XmlElement> nodes = new List<XmlElement>();

  nodes.add(XmlAction('transfer', 'voicemail XML default'));

  return nodes;
}

List<XmlElement> playAudio(PlayAudio action) {
  List<XmlElement> nodes = new List<XmlElement>();

  nodes.add(XmlAction('playback', '\$\${sounds_dir}/${action.filename}'));

  return nodes;
}
