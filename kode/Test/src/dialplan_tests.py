__author__ = 'thomas'

import unittest
import json
import admin_server
import utilities
import config
import logging

class DialplanTests(unittest.TestCase):
    adminServer = admin_server.AdminServer(uri=config.adminUrl, authToken=config.authToken)

    dialplanSchema = {
    "type": "object",
    "required": True,
    "properties": {
        "extensions": {
            "type": "array",
            "required": True,
            "items": [
                {
                    "type": "object",
                    "required": True,
                    "properties": {
                        "name": {
                            "type": "string",
                            "required": True
                        },
                        "start": {
                            "type": "boolean",
                            "required": True
                        },
                        "catchall": {
                            "type": "boolean",
                            "required": True
                        },
                        "conditions": {
                            "type": "array",
                            "required": True,
                            "items": [
                            { #Time
                                "type": "object",
                                "required": True,
                                "properties": {
                                    "condition": {
                                        "type": "string",
                                        "required": True
                                    },
                                    "time-of-day": {
                                        "type": "string",
                                        "required": True
                                    },
                                    "wday": {
                                        "type": "string",
                                        "required": True
                                    }
                                }
                            }]
                        },
                        "actions": {
                            "type": "array",
                            "required": True,
                            "items": [
                            { #forward
                                "type": "object",
                                "required": True,
                                "properties": {
                                    "action": {
                                        "type": "string",
                                        "required": True
                                    },
                                    "number": {
                                        "type": "string",
                                        "required": True
                                    }
                                }
                            },
                            { #playaudio
                                "type": "object",
                                "required": True,
                                "properties": {
                                    "action": {
                                        "type": "string",
                                        "required": True
                                    }
                                }
                            }]
                        }
                    }
                }
            ]
        }
    }
}

    def __init__(self, *args, **kwargs):
        super(DialplanTests, self).__init__(*args, **kwargs)
        self.log = logging.getLogger(self.__class__.__name__)

    def test_getDialplan(self):
        reception_id = 1
        response = self.adminServer.getDialplan(reception_id)[1]
        jsonBody = json.loads(response)
        schema = self.dialplanSchema
        utilities.verifySchema(schema, jsonBody)

    def test_updateDialplan(self):
        reception_id = 1
        response = self.adminServer.getDialplan(reception_id)[1]
        jsonBody = json.loads(response)

        jsonBody['extensions'][0]['name'] = 'TestMania'
        try:
            self.adminServer.updateDialplan(reception_id, jsonBody)
        except admin_server.ServerBadStatus as e:
            self.fail('Error: ' + str(e) + ' Data"' + str(jsonBody) + '"')
        except Exception as e:
            self.fail('Data Sent:"' + str(jsonBody) + '" Error: ' + str(e))