__author__ = 'Thomas'

import unittest
import json
import admin_server
import utilities
import config


class ReceptionTests(unittest.TestCase):
    adminServer = admin_server.AdminServer(uri=config.adminUrl, authToken=config.authToken)

    receptionSchema = {'type': 'object',
                       'required': True,
                       'properties':
                           {'id':
                                {'type': 'integer',
                                 'required': True,
                                 'minimum': 0},
                            'organization_id':
                                {'type': 'integer',
                                 'required': True,
                                 'minimum': 0},
                            'full_name':
                                {'type': 'string'}},
                       "additionalProperties": True}

    receptionListSchema = {'type': 'object',
                           'required': True,
                           'properties':
                               {'receptions':
                                    {'type': 'array',
                                     'required': True,
                                     'items': receptionSchema}}}

    def test_getFirstReception(self):
        organizationId = 1
        receptionId = 1
        headers, body = self.adminServer.getReception(organizationId, receptionId)
        jsonBody = json.loads(body)
        schema = self.receptionSchema
        utilities.verifySchema(schema, jsonBody)

    def test_getReceptionList(self):
        organizationId = 1
        headers, body = self.adminServer.getReceptionList(organizationId)
        jsonBody = json.loads(body)
        schema = self.receptionListSchema
        utilities.verifySchema(schema, jsonBody)

    def test_createNewReception(self):
        organizationId = 1
        reception = {
            'full_name': 'TestMania',
            'uri': utilities.randomLetters(10),
            'attributes': {},
            'enabled': False
        }
        headers, body = self.adminServer.createReception(organizationId, reception)
        jsonBody = json.loads(body)
        try:
            receptionId = jsonBody['id']

            self.adminServer.deleteReception(organizationId, receptionId)
        except Exception, e:
            self.fail('Creating a new reception did not give the expected output. Response: "' +
                      str(jsonBody) + '" Error' + str(e))

    def test_updateNewReception(self):
        organizationId = 1
        reception = {
            'full_name': 'TestMania',
            'uri': utilities.randomLetters(10),
            'attributes': {},
            'enabled': False
        }
        jsonBody = {'Status': 'Uninitialized'}
        try:
            FieldName = 'full_name'

            #First try make a new reception.
            body = self.adminServer.createReception(organizationId, reception)[1]
            jsonBody = json.loads(body)
            receptionId = jsonBody['id']

            #Get the information the server has saved for that reception.
            body = self.adminServer.getReception(organizationId, receptionId)[1]
            reception = json.loads(body)

            #Make sure the precondition is right.
            assert reception[FieldName] == 'TestMania'

            #Do the changes to the object.
            reception[FieldName] = 'TestManiaUpdated'

            #Update the reception.
            self.adminServer.updateReception(organizationId, receptionId, reception)

            #Fetch the reception and see if the change has gone through.
            body = self.adminServer.getReception(organizationId, receptionId)[1]
            reception = json.loads(body)

            #Make sure the postcondition is right.
            assert reception[FieldName] == 'TestManiaUpdated'

            #Clean up.
            self.adminServer.deleteReception(organizationId, receptionId)
        except Exception, e:
            self.fail('Response: "' + str(jsonBody) + '" Error: ' + str(e))

    def test_getOrganizationReceptionList(self):
        organizationId = 1
        headers, body = self.adminServer.getOrganizationReceptionList(organizationId)
        jsonBody = json.loads(body)
        schema = self.receptionListSchema
        utilities.verifySchema(schema, jsonBody)
