__author__ = 'Thomas'

import unittest
import json
import admin_server
import utilities
import config
import logging


class ContactTests(unittest.TestCase):
    adminServer = admin_server.AdminServer(uri=config.adminUrl, authToken=config.authToken)

    contactSchema = \
        {'type': 'object',
         'properties': {'id':
                             {'type': 'integer',
                              'required': True,
                              'minimum': 0},
                        'full_name':
                             {'type': 'string',
                              'required': True}}}

    contactListSchema = {'type': 'object',
                         'properties':
                               {'contacts':
                                    {'type': 'array',
                                     'required': True,
                                     'items': contactSchema}}}

    contactTypeSchema = {"type": "object",
                         "required": True,
                         "properties": {
                           "contacttypes": {
                             "type": "array",
                             "required": True,
                             "items": {
                               "type": "string",
                               "required": False
                             }
                           }
                         }
                        }

    def __init__(self, *args, **kwargs):
        super(ContactTests, self).__init__(*args, **kwargs)
        self.log = logging.getLogger(self.__class__.__name__)

    def test_getFirstContact(self):
        headers, body = self.adminServer.getContact(1)
        jsonBody = json.loads(body)
        schema = self.contactSchema
        utilities.verifySchema(schema, jsonBody)

    def test_getContactList(self):
        headers, body = self.adminServer.getContactList()
        jsonBody = json.loads(body)
        schema = self.contactListSchema
        utilities.verifySchema(schema, jsonBody)

    def test_createNewContact(self):
        contact = {
            'full_name': 'Kurt Test Mandela',
            'contact_type': 'human',
            'enabled': False
        }
        headers, body = self.adminServer.createContact(contact)
        jsonBody = json.loads(body)
        try:
            contactId = jsonBody['id']

            #Validate that the create made a correct contact.
            headers, body = self.adminServer.getContact(contactId)
            jsonBody = json.loads(body)
            schema = self.contactSchema
            utilities.verifySchema(schema, jsonBody)

            assert contact['full_name'] == jsonBody['full_name'], 'full_name in Contact and response is not equal'
            assert contact['contact_type'] == jsonBody['contact_type'], 'contact_type in Contact and response is not equal.'
            assert contact['enabled'] == jsonBody['enabled'], 'enabled in Contact and response is not equal'

            self.adminServer.deleteContact(contactId)
        except Exception as e:
            self.log.info('Contact: ' + str(contact) + ' Json: ' + str(jsonBody))
            self.fail('Creating a new contact did not give the expected output. Response: "' +
                      str(jsonBody) + '" Error ' + str(e))

    def test_updateNewContact(self):
        contact = {
            'full_name': 'Kurt Test Mandela',
            'contact_type': 'human',
            'enabled': False
        }
        jsonBody = {'Status': 'Uninitialized'}
        try:
            #First try make a new contact.
            body = self.adminServer.createContact(contact)[1]
            jsonBody = json.loads(body)
            contactId = jsonBody['id']

            #Get the information the server has saved for that contact.
            body = self.adminServer.getContact(contactId)[1]
            newContact = json.loads(body)

            #Make sure the precondition is right.
            assert newContact['full_name'] == contact['full_name']

            newName = 'TestManiaUpdated'
            #Do the changes to the object.
            newContact['full_name'] = newName

            #Update the contact.
            self.adminServer.updateContact(contactId, newContact)

            #Fetch the contact and see if the change has gone through.
            body = self.adminServer.getContact(contactId)[1]
            updatedContact = json.loads(body)

            #Make sure the postcondition is right.
            assert updatedContact['full_name'] == newName

            #Clean up.
            self.adminServer.deleteContact(contactId)
        except Exception, e:
            self.fail('Response: "' + str(jsonBody) + '" Error: ' + str(e))

    def test_getContactTypeList(self):
        headers, body = self.adminServer.getContactTypes()
        jsonBody = json.loads(body)
        schema = self.contactTypeSchema
        utilities.verifySchema(schema, jsonBody)

    def test_getOrganizationContactList(self):
        organizationId = 1
        headers, body = self.adminServer.getOrganizationContactList(organizationId)
        jsonBody = json.loads(body)
        schema = self.contactListSchema
        utilities.verifySchema(schema, jsonBody)
