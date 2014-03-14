__author__ = 'thomas'

import unittest
import json
import admin_server
import utilities
import config
import logging


class ReceptionContactTests(unittest.TestCase):
    adminServer = admin_server.AdminServer(uri=config.adminUrl, authToken=config.authToken)

    receptionContactSchema = \
        {'type': 'object',
         'properties': {'reception_id':
                             {'type': 'integer',
                              'required': True,
                              'minimum': 0},
                        'contact_id':
                             {'type': 'integer',
                              'required': True,
                              'minimum': 0},
                        'wants_messages':
                             {'type': 'boolean',
                              'required': True}}}

    receptionContactListSchema = {'type': 'object',
                                  'properties':
                               {'receptionContacts':
                                    {'type': 'array',
                                     'required': True,
                                     'items': receptionContactSchema}}}

    def __init__(self, *args, **kwargs):
        super(ReceptionContactTests, self).__init__(*args, **kwargs)
        self.log = logging.getLogger(self.__class__.__name__)

    def test_getReceptionContact(self):
        receptionId = 1
        contactId = 1
        headers, body = self.adminServer.getReceptionContact(receptionId, contactId)
        jsonBody = json.loads(body)
        schema = self.receptionContactSchema
        utilities.verifySchema(schema, jsonBody)

    def test_getReceptionList(self):
        receptionId = 1
        headers, body = self.adminServer.getReceptionContactList(receptionId)
        jsonBody = json.loads(body)
        schema = self.receptionContactListSchema
        utilities.verifySchema(schema, jsonBody)

    def test_createNewReceptionContact(self):
        receptionContact = {
            'wants_messages': True,
            'distribution_list_id': 1,
            'attributes': {},
            'enabled': False
        }
        receptionId = 1
        contactId = 10

        body = self.adminServer.createReceptionContact(receptionId, contactId, receptionContact)[1]
        jsonBody = json.loads(body)
        try:

            #Validate that the create made a correct receptionContact.
            body = self.adminServer.getReceptionContact(receptionId, contactId)[1]
            jsonBody = json.loads(body)
            schema = self.receptionContactSchema
            utilities.verifySchema(schema, jsonBody)

            assert receptionContact['wants_messages'] == jsonBody['wants_messages'], 'wants_messages in ReceptionContact and response is not equal'
            assert receptionContact['distribution_list_id'] == jsonBody['distribution_list_id'], 'distribution_list_id in ReceptionContact and response is not equal.'
            assert receptionContact['attributes'] == jsonBody['attributes'], 'attributes in ReceptionContact and response is not equal'
            assert receptionContact['enabled'] == jsonBody['enabled'], 'enabled in ReceptionContact and response is not equal'

            self.adminServer.deleteReceptionContact(receptionId, contactId)
        except Exception as e:
            self.log.info('ReceptionContact: ' + str(receptionContact) + ' Json: ' + str(jsonBody))
            self.fail('Creating a new receptionContact did not give the expected output. Response: "' +
                      str(jsonBody) + '" Error ' + str(e))

    def test_updateNewReceptionContact(self):
        receptionContact = {
            'wants_messages': True,
            'distribution_list_id': 1,
            'attributes': {},
            'enabled': False
        }
        jsonBody = {'Status': 'Uninitialized'}
        try:
            receptionId = 1
            contactId = 10
            FieldToUpdate = 'wants_messages'

            #First try make a new receptionContact.
            body = self.adminServer.createReceptionContact(receptionId, contactId, receptionContact)[1]
            jsonBody = json.loads(body)

            #Get the information the server has saved for that reception.
            body = self.adminServer.getReceptionContact(receptionId, contactId)[1]
            newReceptionContact = json.loads(body)

            #Make sure the precondition is right.
            assert newReceptionContact[FieldToUpdate] == receptionContact[FieldToUpdate]

            newWantsMessages = False
            #Do the changes to the object.
            newReceptionContact[FieldToUpdate] = newWantsMessages

            #Update the reception.
            self.adminServer.updateReceptionContact(receptionId, contactId, newReceptionContact)

            #Fetch the reception and see if the change has gone through.
            body = self.adminServer.getReceptionContact(receptionId, contactId)[1]
            updatedReceptionContact = json.loads(body)

            #Make sure the postcondition is right.
            assert updatedReceptionContact[FieldToUpdate] == newWantsMessages

            #Clean up.
            self.adminServer.deleteReceptionContact(receptionId, contactId)
        except admin_server.ServerBadStatus as e:
            self.fail('Error: ' + str(e))
        except Exception as e:
            self.fail('Response: "' + str(jsonBody) + '" Error: ' + str(e))

