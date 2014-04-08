import 'dart:convert';
import 'dart:async';

import 'package:xml/xml.dart';
import 'package:libdialplan/libdialplan.dart';

import '../lib/generator.dart';
import '../lib/configuration.dart';

void main() {
  Configuration config = new Configuration();
  config.loadFromFile('config.json').then((_) {
    int receptionId = 8;
    String number = '1234000${receptionId}';

    Map dialplan = JSON.decode(dialplan1);
    Dialplan handplan = new Dialplan.fromJson(dialplan)
      ..receptionId = receptionId
      ..entryNumber = number;

    List<XmlElement> extensions = generateXml(handplan);

    extensions.forEach(print);
  }).catchError((error, stack) {
    print('Error: "${error}"');
    print(stack);
  });
}

void start() {

}



/**
 * TODO TESTING. DELETE IF YOU SEE ME IN DOC!.
 */
String dialplan1 = '''
{
    "extensions": [
        {
            "name": "open",
            "conditions": [
                {
                    "condition": "time",
                    "minute-of-day": "480-1020",
                    "wday": "mon-fri"
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
                    "action": "playaudio",
                    "filename": "en/us/callie/misc/8000/misc-speak_live_with_community.wav"
                }
            ]
        }
    ]
}
''';
