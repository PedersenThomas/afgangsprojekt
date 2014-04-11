library dialplan_utilities;

import 'package:xml/xml.dart';

/**
 * Makes a condition xml element
 */
XmlElement XmlCondition(String field, String expression) =>
    new XmlElement('condition')
  ..attributes['field'] = field
  ..attributes['expression'] = expression;

/**
 * Makes a action xml element
 */
XmlElement XmlAction(String application, String data, [bool anti_action = false]) =>
    new XmlElement(anti_action ? 'anti-action' : 'action')
    ..attributes['application'] = application
    ..attributes['data'] = data;
