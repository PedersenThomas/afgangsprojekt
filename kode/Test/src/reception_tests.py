__author__ = 'Thomas'

import httplib2
import unittest
import json
import random
import string
import admin_server

class ReceptionTests(unittest.TestCase):
    adminServer = admin_server.AdminServer(uri='http://localhost:4100', authToken='feedabbadeadbeef0')

    def test_getFirstReception(self):
        headers, body = self.adminServer.getReception(1)
        jsonBody = json.loads(body);
        try:
            assert jsonBody['id'] == 1
        except Exception, e:
            self.fail('Fetching organization 1 failed. Response "' +
                      str(jsonBody) + '" Error' + str(e))

    def test_createNewReception(self):
        reception = {
            'full_name': 'TestMania',
            'uri': self.randomLetters(10),
            'attributes': {},
            'enabled': False
        }
        headers, body = self.adminServer.createReception(reception)
        jsonBody = json.loads(body);
        try:
            assert jsonBody['id'] > 0
        except Exception, e:
            self.fail('Creating a new reception did not give the expected output. Response: "' +
                      str(jsonBody) + '" Error' + str(e))

    #Source: http://stackoverflow.com/questions/2257441/python-random-string-generation-with-upper-case-letters-and-digits
    def randomLetters(self, length):
        return ''.join(random.choice(string.ascii_letters) for _ in range(length))

if __name__ == "__main__":
    print "started"