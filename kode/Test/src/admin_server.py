from urllib import urlencode
import logging
import json
import httplib2

class ServerUnavailable(Exception):
    pass

class Server401(Exception):
    pass

class Server403(Exception):
    pass

class Server404(Exception):
    pass

class Server500(Exception):
    pass

class ServerBadStatus(Exception):
    pass

class AdminServer:
    class protocol:
        receptionUrl  = "/reception"
        tokenParam      = "?token="

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

    def getReception(self, receptionId):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId), "GET")

    def getReceptionList(self):
        return self.request(self.protocol.receptionUrl, "GET")

    def createReception(self, params):
        return self.request(self.protocol.receptionUrl, "PUT", params)

    def deleteReception(self, receptionId):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId), "DELETE")

    def updateReception(self, receptionId, param):
        return self.request(self.protocol.receptionUrl + "/" + str(receptionId), "POST", param)
