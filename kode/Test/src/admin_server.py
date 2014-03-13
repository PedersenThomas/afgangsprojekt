from urllib import urlencode
import logging
import json
import httplib2

class ServerUnavailable(Exception):
    pass

class ServerBadStatus(Exception):
    pass

class Server401(ServerBadStatus):
    pass

class Server403(ServerBadStatus):
    pass

class Server404(ServerBadStatus):
    pass

class Server500(ServerBadStatus):
    pass


class AdminServer:
    class protocol:
        receptionUrl  = "/reception"
        contactUrl    = "/contact"
        tokenParam    = "?token="

    authToken = None
    http      = httplib2.Http(".cache")
    log       = None
    uri       = None

    def __init__ (self, uri, authToken):
        self.log = logging.getLogger(self.__class__.__name__)
        self.uri       = uri
        self.authToken = authToken

    def request (self, path, method="GET", params={}):
        self.log.info(method + " " + path + " " + json.dumps(params))
        try:
            uri_path = self.uri + path + self.protocol.tokenParam + self.authToken

            if method in ('POST', 'PUT'):
                headers, body = self.http.request(uri_path , method, headers={'Origin' : self.uri}, body=json.dumps(params))
            else:
                headers, body = self.http.request(uri_path , method, headers={'Origin' : self.uri})

        except ValueError:
            logging.error("Server unreachable! " + str(ValueError))
            raise ServerUnavailable (uri_path)
        if headers['status'] == '401':
            raise Server401 (method + " " + path + " Response:" + body)
        elif headers['status'] == '403':
            raise Server403 (method + " " + path + " Response:" + body)
        elif headers['status'] == '404':
            raise Server404 (method + " " + path + " Response:" + body)
        elif headers['status'] == '500':
            raise Server500 (method + " " + path + " Response:" + body)
        elif headers['status'] != '200':
            raise ServerBadStatus (headers['status'] + " " + method + " " + path + " Response:" + body)

        return headers, body

######################## RECEPTION
    def getReception(self, receptionId):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId), "GET")

    def getReceptionList(self):
        return self.request(self.protocol.receptionUrl, "GET")

    def createReception(self, params):
        return self.request(self.protocol.receptionUrl, "PUT", params)

    def deleteReception(self, receptionId):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId), "DELETE")

    def updateReception(self, receptionId, params):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId), "POST", params)

######################## CONTACT
    def getContact(self, contactId):
        return self.request(self.protocol.contactUrl + "/" + str(contactId), "GET")

    def getContactList(self):
        return self.request(self.protocol.contactUrl, "GET")

    def createContact(self, params):
        return self.request(self.protocol.contactUrl, "PUT", params)

    def updateContact(self, contactId, params):
        return self.request(self.protocol.contactUrl + "/" + str(contactId), "POST", params)

    def deleteContact(self, contactId):
        return self.request(self.protocol.contactUrl + "/" + str(contactId), "DELETE")

######################## RECEPTION-CONTACT
    def getReceptionContact(self, receptionId, contactId):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId) +
                            self.protocol.contactUrl + "/" + str(contactId), "GET")

    def getReceptionContactList(self, receptionId):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId) +
                            self.protocol.contactUrl, "GET")

    def createReceptionContact(self, receptionId, contactId, params):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId) +
                            self.protocol.contactUrl + "/" + str(contactId), "PUT", params)

    def updateReceptionContact(self, receptionId, contactId, params):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId) +
                            self.protocol.contactUrl + "/" + str(contactId), "POST", params)

    def deleteReceptionContact(self, receptionId, contactId):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId) +
                            self.protocol.contactUrl + "/" + str(contactId), "DELETE")
