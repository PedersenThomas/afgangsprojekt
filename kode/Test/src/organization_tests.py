__author__ = 'Thomas'


import unittest
import json
import admin_server
import utilities
import config
import logging


class OrganizationTests(unittest.TestCase):
    adminServer = admin_server.AdminServer(uri=config.adminUrl, authToken=config.authToken)

    organizationSchema = {"type": "object",
                          "required": True,
                          "properties": {
                            "id": {
                              "type": "integer",
                              "required": True
                            },
                            "full_name": {
                              "type": "string",
                              "required": True
                            }
                          }
                        }

    organizationListSchema = {'type': 'object',
                              'required': True,
                              'properties':
                                  {'organizations':
                                      {'type': 'array',
                                       'required': True,
                                       'items': organizationSchema}}}

    def __init__(self, *args, **kwargs):
        super(OrganizationTests, self).__init__(*args, **kwargs)
        self.log = logging.getLogger(self.__class__.__name__)

    def test_getOrganization(self):
        organizationId = 1
        headers, body = self.adminServer.getOrganization(organizationId)
        jsonBody = json.loads(body)
        schema = self.organizationSchema
        utilities.verifySchema(schema, jsonBody)

    def test_getOrganizationList(self):
        headers, body = self.adminServer.getOrganizationList()
        jsonBody = json.loads(body)
        schema = self.organizationListSchema
        utilities.verifySchema(schema, jsonBody)

    def test_createNewOrganization(self):
        organization = {
            'full_name': 'TestMania',
            'bill_type': 'email',
            'flag': 'non-VIP'
        }
        headers, body = self.adminServer.createOrganization(organization)
        jsonBody = json.loads(body)
        try:
            organizationId = jsonBody['id']

            self.adminServer.deleteOrganization(organizationId)
        except Exception, e:
            self.fail('Creating a new organization did not give the expected output. Response: "' +
                      str(jsonBody) + '" Error' + str(e))

    def test_updateNewOrganization(self):
        organization = {
            'full_name': 'TestMania',
            'bill_type': 'email',
            'flag': 'non-VIP'
        }

        jsonBody = {'Status': 'Uninitialized'}
        try:
            FieldName = 'full_name'

            #First try make a new organization.
            body = self.adminServer.createOrganization(organization)[1]
            jsonBody = json.loads(body)
            organizationId = jsonBody['id']

            #Get the information the server has saved for that organization.
            body = self.adminServer.getOrganization(organizationId)[1]
            organization = json.loads(body)

            #Make sure the precondition is right.
            assert organization[FieldName] == 'TestMania'

            #Do the changes to the object.
            organization[FieldName] = 'TestManiaUpdated'

            #Update the organization.
            self.adminServer.updateOrganization(organizationId, organization)

            #Fetch the organization and see if the change has gone through.
            body = self.adminServer.getOrganization(organizationId)[1]
            organization = json.loads(body)

            #Make sure the postcondition is right.
            assert organization[FieldName] == 'TestManiaUpdated'

            #Clean up.
            self.adminServer.deleteOrganization(organizationId)
        except Exception, e:
            self.fail('Response: "' + str(jsonBody) + '" Error: ' + str(e))

    def test_getOrganization(self):
        contactId = 1
        headers, body = self.adminServer.getContactOrganization(contactId)
        jsonBody = json.loads(body)
        schema = self.organizationListSchema
        utilities.verifySchema(schema, jsonBody)