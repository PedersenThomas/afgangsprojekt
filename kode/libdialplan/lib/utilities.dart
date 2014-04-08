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
XmlElement XmlAction(String application, String data) =>
    new XmlElement('action')
    ..attributes['application'] = application
    ..attributes['data'] = data;
