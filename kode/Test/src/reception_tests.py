__author__ = 'Thomas'

import unittest
import json
import admin_server
import utilities
from jsonschema import Draft3Validator
from jsonschema.exceptions import SchemaError, ValidationError
import config

class ReceptionTests(unittest.TestCase):
    adminServer = admin_server.AdminServer(uri=config.adminUrl, authToken=config.authToken)

    receptionSchema = \
        {'type': 'object',
         'properties': {'id' :
                             {'type': 'integer',
			                  'minimum': 0},
                         'full_name':
                             {'type': 'string'}}}

    receptionListSchema = {'type': 'object',
                           'properties':
                               {'receptions':
                                    {'type': 'array',
                                     'required': True,
                                     'items': receptionSchema}}}

    def test_getFirstReception(self):
        headers, body = self.adminServer.getReception(1)
        jsonBody = json.loads(body)
        schema = self.receptionSchema
        utilities.varifySchema(schema, jsonBody)

    def test_getReceptionList(self):
        headers, body = self.adminServer.getReceptionList()
        jsonBody = json.loads(body)
        schema = self.receptionListSchema
        utilities.varifySchema(schema, jsonBody)

    def test_createNewReception(self):
        reception = {
            'full_name': 'TestMania',
            'uri': utilities.randomLetters(10),
            'attributes': {},
            'enabled': False
        }
        headers, body = self.adminServer.createReception(reception)
        jsonBody = json.loads(body)
        try:
            assert jsonBody['id'] > 0

            self.adminServer.deleteReception(jsonBody['id'])
        except Exception, e:
            self.fail('Creating a new reception did not give the expected output. Response: "' +
                      str(jsonBody) + '" Error' + str(e))

    def test_updateNewReception(self):
        reception = {
            'full_name': 'TestMania',
            'uri': utilities.randomLetters(10),
            'attributes': {},
            'enabled': False
        }
        try:
            #First try make a new reception.
            body = self.adminServer.createReception(reception)[1]
            jsonBody = json.loads(body)
            receptionId = jsonBody['id']

            #Get the information the server has saved for that reception.
            body = self.adminServer.getReception(receptionId)[1]
            reception = json.loads(body)

            #Make sure the precondition is right.
            assert reception['full_name'] == 'TestMania'

            #Do the changes to the object.
            reception['full_name'] = 'TestManiaUpdated'

            #Update the reception.
            self.adminServer.updateReception(receptionId, reception)

            #Fetch the reception and see if the change has gone through.
            body = self.adminServer.getReception(receptionId)[1]
            reception = json.loads(body)

            #Make sure the postcondition is right.
            assert reception['full_name'] == 'TestManiaUpdated'

            #Clean up.
            self.adminServer.deleteReception(receptionId)
        except Exception, e:
            self.fail('Response: "' + str(jsonBody) + '" Error: ' + str(e))
