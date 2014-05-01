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
    class Protocol:
        contactTypeUrl  = "/contacttypes"
        dialplanUrl     = "/dialplan"
        receptionUrl    = "/reception"
        contactUrl      = "/contact"
        organizationUrl = "/organization"
        userUrl =         "/user"
        tokenParam      = "?token="

    authToken = None
    http      = httplib2.Http(".cache")
    log       = None
    uri       = None

    def __init__(self, uri, authToken):
        self.log = logging.getLogger(self.__class__.__name__)
        self.uri       = uri
        self.authToken = authToken

    def request(self, path, method="GET", params={}):
        self.log.info(method + " " + path + " " + json.dumps(params))
        uri_path = self.uri + path + self.Protocol.tokenParam + self.authToken

        try:
            if method in ('POST', 'PUT'):
                headers, body = self.http.request(uri_path,
                                                  method,
                                                  headers={'Origin': self.uri},
                                                  body=json.dumps(params))
            else:
                headers, body = self.http.request(uri_path, method, headers={'Origin': self.uri})

        except ValueError:
            logging.error('Server unreachable! ' + str(ValueError))
            raise ServerUnavailable(uri_path)
        if headers['status'] == '401':
            raise Server401('401 Unauthorized ' + method + ' ' + path + ' Response:' + body)

        elif headers['status'] == '403':
            raise Server403('403 Forbidden ' + method + ' ' + path + ' Response:' + body)

        elif headers['status'] == '404':
            raise Server404('404 Not Found ' + method + ' ' + path + ' Response:' + body)

        elif headers['status'] == '500':
            raise Server500('500 Internal Server Error ' + method + ' ' + path + ' Response:' + body)

        elif headers['status'] != '200':
            raise ServerBadStatus(headers['status'] + ' ' + method + ' ' + path + ' Response:' + body)

        return headers, body

######################## RECEPTION
    def getReception(self, organizationId, receptionId):
        return self.request(self.Protocol.organizationUrl + "/" + str(organizationId) +
                            self.Protocol.receptionUrl + "/" + str(receptionId), "GET")

    def getReceptionList(self, organizationId):
        return self.request(self.Protocol.organizationUrl + "/" + str(organizationId) +
                            self.Protocol.receptionUrl, "GET")

    def createReception(self, organizationId, params):
        return self.request(self.Protocol.organizationUrl + "/" + str(organizationId) +
                            self.Protocol.receptionUrl, "PUT", params)

    def deleteReception(self, organizationId, receptionId):
        return self.request(self.Protocol.organizationUrl + "/" + str(organizationId) +
                            self.Protocol.receptionUrl + "/" + str(receptionId), "DELETE")

    def updateReception(self, organizationId, receptionId, params):
        return self.request(self.Protocol.organizationUrl + "/" + str(organizationId) +
                            self.Protocol.receptionUrl + "/" + str(receptionId), "POST", params)

    def getOrganizationReceptionList(self, organizationId):
        return self.request(self.Protocol.organizationUrl + "/" + str(organizationId) + self.Protocol.receptionUrl, "GET")

######################## CONTACT
    def getContact(self, contactId):
        return self.request(self.Protocol.contactUrl + "/" + str(contactId), "GET")

    def getContactList(self):
        return self.request(self.Protocol.contactUrl, "GET")

    def createContact(self, params):
        return self.request(self.Protocol.contactUrl, "PUT", params)

    def updateContact(self, contactId, params):
        return self.request(self.Protocol.contactUrl + "/" + str(contactId), "POST", params)

    def deleteContact(self, contactId):
        return self.request(self.Protocol.contactUrl + "/" + str(contactId), "DELETE")

    def getContactTypes(self):
        return self.request(self.Protocol.contactTypeUrl, 'GET')

    def getOrganizationContactList(self, organizationId):
        return self.request(self.Protocol.organizationUrl + "/" + str(organizationId) + self.Protocol.contactUrl, "GET")

######################## RECEPTION-CONTACT
    def getReceptionContact(self, receptionId, contactId):
        return self.request(self.Protocol.receptionUrl + "/" + str(receptionId) +
                            self.Protocol.contactUrl + "/" + str(contactId), "GET")

    def getReceptionContactList(self, receptionId):
        return self.request(self.Protocol.receptionUrl + "/" + str(receptionId) +
                            self.Protocol.contactUrl, "GET")

    def createReceptionContact(self, receptionId, contactId, params):
        return self.request(self.Protocol.receptionUrl + "/" + str(receptionId) +
                            self.Protocol.contactUrl + "/" + str(contactId), "PUT", params)

    def updateReceptionContact(self, receptionId, contactId, params):
        return self.request(self.Protocol.receptionUrl + "/" + str(receptionId) +
                            self.Protocol.contactUrl + "/" + str(contactId), "POST", params)

    def deleteReceptionContact(self, receptionId, contactId):
        return self.request(self.Protocol.receptionUrl + "/" + str(receptionId) +
                            self.Protocol.contactUrl + "/" + str(contactId), "DELETE")

######################## ORGANIZATION
    def getOrganization(self, organizationId):
        return self.request(self.Protocol.organizationUrl + "/" + str(organizationId), "GET")

    def getOrganizationList(self):
        return self.request(self.Protocol.organizationUrl, "GET")

    def createOrganization(self, params):
        return self.request(self.Protocol.organizationUrl, "PUT", params)

    def deleteOrganization(self, organizationId):
        return self.request(self.Protocol.organizationUrl + "/" + str(organizationId), "DELETE")

    def updateOrganization(self, organizationId, params):
        return self.request(self.Protocol.organizationUrl + "/" + str(organizationId), "POST", params)

    def getContactOrganization(self, contactId):
        return self.request(self.Protocol.contactUrl + "/" + str(contactId) + self.Protocol.organizationUrl, "GET")

######################## DIALPLAN
    def getDialplan(self, receptionId):
        return self.request(self.Protocol.receptionUrl + "/" + str(receptionId) + self.Protocol.dialplanUrl, "GET")

    def updateDialplan(self, receptionId, params):
        return self.request(self.Protocol.receptionUrl + "/" + str(receptionId) + self.Protocol.dialplanUrl, "POST", params)

######################## USER
    def getUser(self, userId):
        return self.request(self.Protocol.userUrl + "/" + str(userId), "GET")

    def getUserList(self):
        return self.request(self.Protocol.userUrl, "GET")

    def createUser(self, params):
        return self.request(self.Protocol.userUrl, "PUT", params)

    def deleteUser(self, userId):
        return self.request(self.Protocol.userUrl + "/" + str(userId), "DELETE")

    def updateUser(self, userId, params):
        return self.request(self.Protocol.userUrl + "/" + str(userId), "POST", params)

    def getContactReceptionList(self, contactId):
        return self.request(self.Protocol.contactUrl + "/" + str(contactId) + self.Protocol.receptionUrl, "GET")
# Contact reception List //Complex?
# 
