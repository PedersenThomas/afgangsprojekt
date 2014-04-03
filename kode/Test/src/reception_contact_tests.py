__author__ = 'thomas'

import unittest
import json
import admin_server
import utilities
import config
import logging


class ReceptionContactTests(unittest.TestCase):
    adminServer = admin_server.AdminServer(uri=config.adminUrl, authToken=config.authToken)

    priorityListSchema = {"type": "object",
                          "required": False,
                          "properties": {
                              "priority": {
                                  "type": "integer",
                                  "required": True
                              },
                              "value": {
                                  "type": "string",
                                  "required": True
                              }
                          }
                        }

    contactAttributesSchema = {
                            "department": {
                                "type": "string",
                                "required": True
                            },
                            "info": {
                                "type": "string",
                                "required": True
                            },
                            "position": {
                                "type": "string",
                                "required": True
                            },
                            "relations": {
                                "type": "string",
                                "required": True
                            },
                            "responsibility": {
                                "type": "string",
                                "required": True
                            },
                            "backup": {
                                "type": "array",
                                "required": True,
                                "items": priorityListSchema
                            },
                            "emailaddresses": {
                                "type": "array",
                                "required": True,
                                "items": priorityListSchema
                            },
                            "handling": {
                                "type": "array",
                                "required": True,
                                "items": priorityListSchema
                            },
                            "telephonenumbers": {
                                "type": "array",
                                "required": True,
                                "items": priorityListSchema
                            },
                            "workhours": {
                                "type": "array",
                                "required": True,
                                "items": priorityListSchema
                            },
                            "tags": {
                                "type": "array",
                                "required": True,
                                "items": {
                                    "type": "string",
                                    "required": True
                                }
                            }
                        }


    receptionContactSchema = {
                    "type": "object",
                    "required": True,
                    "properties": {
                        "reception_id": {
                            "type": "integer",
                            "required": True
                        },
                        "contact_id": {
                            "type": "integer",
                            "required": True
                        },
                        "full_name": {
                            "type": "string",
                            "required": True
                        },
                        "contact_type": {
                            "type": "string",
                            "required": True
                        },
                        "contact_enabled": {
                            "type": "boolean",
                            "required": True
                        },
                        "wants_messages": {
                            "type": "boolean",
                            "required": True
                        },
                        "distribution_list_id": {
                            "type": ["null", "integer"],
                            "required": True
                        },
                        "reception_enabled": {
                            "type": "boolean",
                            "required": True
                        },
                        "attributes": {
                        "type": "object",
                        "required": True,
                        "properties": contactAttributesSchema
                        }
                    }
                }


    receptionContactListSchema = {'type': 'object',
                                  'properties':
                               {'receptionContacts':
                                    {'type': 'array',
                                     'required': True,
                                     'items': receptionContactSchema}}}

    contactReceptionListSchema = {"type": "object",
  "required": True,
  "properties": {
    "contacts": {
      "id": "#contacts",
      "type": "array",
      "required": True,
      "items": {
        "id": "#3",
        "type": "object",
        "required": True,
        "properties": {
          "contact_id": {
            "id": "#contact_id",
            "type": "integer",
            "required": True
          },
          "contact_wants_messages": {
            "id": "#contact_wants_messages",
            "type": "boolean",
            "required": True
          },
          "contact_distribution_list_id": {
            "id": "#contact_distribution_list_id",
            "type": ["null", "integer"],
            "required": True
          },
          "contact_attributes": {
            "id": "#contact_attributes",
            "type": "object",
            "required": True,
            "properties": contactAttributesSchema
          },
          "contact_enabled": {
            "id": "#contact_enabled",
            "type": "boolean",
            "required": True
          },
          "reception_id": {
            "id": "#reception_id",
            "type": "integer",
            "required": True
          },
          "reception_full_name": {
            "id": "#reception_full_name",
            "type": "string",
            "required": True
          },
          "reception_uri": {
            "id": "#reception_uri",
            "type": "string",
            "required": True
          },
          "reception_enabled": {
            "id": "#reception_enabled",
            "type": "boolean",
            "required": True
          },
          "organization_id": {
            "id": "#organization_id",
            "type": "integer",
            "required": True
          }
        }
      }
    }
  }
}

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

    def test_getReceptionContactList(self):
        receptionId = 1
        headers, body = self.adminServer.getReceptionContactList(receptionId)
        jsonBody = json.loads(body)
        schema = self.receptionContactListSchema
        utilities.verifySchema(schema, jsonBody)

    def test_createNewReceptionContact(self):
        receptionContact = {
            'wants_messages': True,
            'distribution_list_id': 1,
            'attributes': {
                "backup": [],
                "department": "",
                "emailaddresses": [],
                "handling": [],
                "info": "",
                "position": "",
                "relations": "",
                "responsibility": "",
                "telephonenumbers": [],
                "tags": [],
                "workhours": []},
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
            assert receptionContact['enabled'] == jsonBody['reception_enabled'], 'enabled in ReceptionContact and response is not equal. ' + jsonBody
        except Exception as e:
            self.log.info('ReceptionContact: ' + str(receptionContact) + ' Json: ' + str(jsonBody))
            self.fail('Creating a new receptionContact did not give the expected output. Response: "' +
                      str(jsonBody) + '"\n Error ' + str(e))
        finally:
            self.adminServer.deleteReceptionContact(receptionId, contactId)

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

            #Make a copy
            newReceptionContact = receptionContact.copy()

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
        except admin_server.ServerBadStatus as e:
            self.fail('Error: ' + str(e))
        except Exception as e:
            self.fail('Response: "' + str(jsonBody) + '" Error: ' + str(e))
        finally:
            #Clean up.
            self.adminServer.deleteReceptionContact(receptionId, contactId)

    def test_getReceptionContactList(self):
        receptionId = 1
        headers, body = self.adminServer.getContactReceptionList(receptionId)
        jsonBody = json.loads(body)
        schema = self.contactReceptionListSchema
        utilities.verifySchema(schema, jsonBody)
