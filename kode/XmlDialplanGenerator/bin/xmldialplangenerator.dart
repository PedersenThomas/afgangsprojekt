import 'dart:convert';
import 'dart:async';

import 'package:xml/xml.dart';
import 'package:libdialplan/libdialplan.dart';

import '../lib/generator.dart';
import '../lib/configuration.dart';

void main() {
  Configuration config = new Configuration();
  config.loadFromFile('config.json').then((_) {
    TestStart();
  }).catchError((error, stack) {
    print('Error: "${error}"');
    print(stack);
  });
}

void TestStart() {
  int receptionId = 9;
  String number = '1234000${receptionId}';

  Map dialplan = JSON.decode(dialplan2);
  Dialplan handplan = new Dialplan.fromJson(dialplan)
    ..receptionId = receptionId
    ..entryNumber = number;

  GeneratorOutput output = generateXml(handplan);
  //print(JSON.encode(handplan.toJson()));
  print(output.entry.toString().substring(1));
  print('-- ^ PUBLIC CONTEXT ^ ---- v RECEPTION CONTEXT v --');
  print(output.receptionContext);
}

/**
 * ---- Krav til modellen.
 * Der skal altid være en, og kun en, extension med start = true
 * Der må højst være en extension med catchall = true
 */

/**
 * TODO TESTING. DELETE IF YOU SEE ME IN DOC!.
 */

String dialplan2 ='''
{
    "extensions": [
        {
            "start": true,
            "catchall": false,
            "name": "man-tors",
            "failoverextension": "fredag",
            "conditions": [
                {
                    "condition": "time",
                    "time-of-day": "08:00-17:00",
                    "wday": "mon-thu"
                }
            ],
            "actions": [
                {
                    "action": "receptionists",
                    "sleeptime": 0,
                    "music": "mohrec7",
                    "welcomefile": "r_8_welcome.wav"
                }
            ]
        },
        {
            "start": false,
            "catchall": false,
            "name": "fredag",
            "failoverextension": "lukket",
            "conditions": [
                {
                    "condition": "time",
                    "time-of-day": "08:00-16:30",
                    "wday": "fri"
                }
            ],
            "actions": [
                {
                    "action": "receptionists",
                    "sleeptime": 0,
                    "music": "mohrec7",
                    "welcomefile": "r_8_welcome.wav"
                }
            ]
        },
        {
            "start": false,
            "catchall": false,
            "name": "lukket",
            "conditions": [],
            "actions": [
                {
                    "action": "playaudio",
                    "filename": "en/us/callie/misc/8000/misc-soccer_mom.wav"
                }
            ]
        },
        {
            "start": false,
            "name": "natsvar",
            "catchall": true,
            "conditions": [],
            "actions": [
                {
                    "action": "playaudio",
                    "filename": "en/us/callie/misc/8000/error.wav"
                }
            ]
        }
    ]
}
''';
