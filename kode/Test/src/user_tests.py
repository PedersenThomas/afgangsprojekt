__author__ = 'Thomas'


import unittest
import json
import admin_server
import utilities
import config
import logging


class UserTests(unittest.TestCase):
    adminServer = admin_server.AdminServer(uri=config.adminUrl, authToken=config.authToken)

    userSchema = {'type': 'object',
                  'properties': {'id':
                                  {'type': 'integer',
                                   'required': True,
                                   'minimum': 0},
                                 'name':
                                   {'type': 'string',
                                    'required': True},
                                 'extension':
                                     {'type': 'string',
                                      'required': True}}}

    userListSchema = {'type': 'object',
                              'properties':
                               {'users':
                                    {'type': 'array',
                                     'required': True,
                                     'items': userSchema}}}

    def __init__(self, *args, **kwargs):
        super(UserTests, self).__init__(*args, **kwargs)
        self.log = logging.getLogger(self.__class__.__name__)

    def test_getUser(self):
        userId = 1
        headers, body = self.adminServer.getUser(userId)
        jsonBody = json.loads(body)
        schema = self.userSchema
        utilities.verifySchema(schema, jsonBody)

    def test_getUserList(self):
        headers, body = self.adminServer.getUserList()
        jsonBody = json.loads(body)
        schema = self.userListSchema
        utilities.verifySchema(schema, jsonBody)

    def test_createNewUser(self):
        user = {
            'name': 'TestMania',
            'extension': '1234'
        }
        headers, body = self.adminServer.createUser(user)
        jsonBody = json.loads(body)
        try:
            userId = jsonBody['id']

            self.adminServer.deleteUser(userId)
        except Exception, e:
            self.fail('Creating a new user did not give the expected output. Response: "' +
                      str(jsonBody) + '" Error' + str(e))

    def test_updateNewUser(self):
        user = {
            'name': 'TestMania',
            'extension': '1234'
        }

        jsonBody = {'Status': 'Uninitialized'}
        try:
            FieldName = 'name'

            #First try make a new user.
            body = self.adminServer.createUser(user)[1]
            jsonBody = json.loads(body)
            userId = jsonBody['id']

            #Get the information the server has saved for that user.
            body = self.adminServer.getUser(userId)[1]
            user = json.loads(body)

            #Make sure the precondition is right.
            assert user[FieldName] == 'TestMania'

            #Do the changes to the object.
            user[FieldName] = 'TestManiaUpdated'

            #Update the user.
            self.adminServer.updateUser(userId, user)

            #Fetch the user and see if the change has gone through.
            body = self.adminServer.getUser(userId)[1]
            user = json.loads(body)

            #Make sure the postcondition is right.
            assert user[FieldName] == 'TestManiaUpdated'

            #Clean up.
            self.adminServer.deleteUser(userId)
        except Exception, e:
            self.fail('Response: "' + str(jsonBody) + '" Error: ' + str(e))
