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
                            "required": True
                        },
                        "actions": {
                            "type": "array",
                            "required": True
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
        self.failIf('extensions' in jsonBody and len(jsonBody['extensions']) == 0)
        if 'extensions' in jsonBody and len(jsonBody['extensions']) == 0:
            self.fail('There is not a test dialplan to update.')

        oldValue = jsonBody['extensions'][0]['name']
        jsonBody['extensions'][0]['name'] = 'TestMania'
        try:
            self.adminServer.updateDialplan(reception_id, jsonBody)

            jsonBody['extensions'][0]['name'] = oldValue
            #Change it back again.
            self.adminServer.updateDialplan(reception_id, jsonBody)
        except admin_server.ServerBadStatus as e:
            self.fail('Error: ' + str(e) + ' Data"' + str(jsonBody) + '"')
        except Exception as e:
            self.fail('Data Sent:"' + str(jsonBody) + '" Error: ' + str(e))