import 'dart:io';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'controller/contact.dart';
import 'controller/organization.dart';
import 'controller/reception.dart';
import 'controller/reception_contact.dart';
import 'database.dart';
import 'utilities/http.dart';
import 'utilities/logger.dart';

final Pattern anyThing = new UrlPattern(r'/(.*)');
final Pattern organizationIdUrl = new UrlPattern(r'/organization/(\d+)');
final Pattern organizationUrl = new UrlPattern(r'/organization(/?)');
final Pattern receptionIdUrl = new UrlPattern(r'/reception/(\d+)');
final Pattern receptionUrl = new UrlPattern(r'/reception(/?)');
final Pattern contactIdUrl = new UrlPattern(r'/contact/(\d+)');
final Pattern contactUrl = new UrlPattern(r'/contact(/?)');
final Pattern receptionContactIdUrl = new UrlPattern(r'/reception/(\d+)/contact/(\d+)');
final Pattern receptionContactUrl = new UrlPattern(r'/reception/(\d+)/contact(/?)');
final List<Pattern> Serviceagents = [receptionIdUrl, receptionUrl, organizationIdUrl, organizationUrl, contactIdUrl, contactUrl];

ContactController contact;
OrganizationController organization;
ReceptionController reception;
ReceptionContactController receptionContact;

void setupRoutes(HttpServer server, Configuration config, Logger logger) {
  Router router = new Router(server)
    ..filter(anyThing, (HttpRequest req) => logHit(req, logger))
    ..filter(matchAny(Serviceagents), (HttpRequest req) => authorized(req, config.authUrl, groupName: 'Serviceagent'))
    
    ..serve(receptionUrl, method: HttpMethod.GET).listen(reception.getReceptionList)
    ..serve(receptionUrl, method: HttpMethod.PUT).listen(reception.createReception)
    ..serve(receptionIdUrl, method: HttpMethod.GET)   .listen(reception.getReception)
    ..serve(receptionIdUrl, method: HttpMethod.POST)  .listen(reception.updateReception)
    ..serve(receptionIdUrl, method: HttpMethod.DELETE).listen(reception.deleteReception)

    ..serve(contactUrl, method: HttpMethod.GET).listen(contact.getContactList)
    ..serve(contactUrl, method: HttpMethod.PUT).listen(contact.createContact)
    ..serve(contactIdUrl, method: HttpMethod.GET)   .listen(contact.getContact)
    ..serve(contactIdUrl, method: HttpMethod.POST)  .listen(contact.updateContact)
    ..serve(contactIdUrl, method: HttpMethod.DELETE).listen(contact.deleteContact)

    ..serve(receptionContactUrl, method: HttpMethod.GET).listen(receptionContact.getReceptionContactList)
    ..serve(receptionContactIdUrl, method: HttpMethod.PUT).listen(receptionContact.createReceptionContact)
    ..serve(receptionContactIdUrl, method: HttpMethod.GET)   .listen(receptionContact.getReceptionContact)
    ..serve(receptionContactIdUrl, method: HttpMethod.POST)  .listen(receptionContact.updateReceptionContact)
    ..serve(receptionContactIdUrl, method: HttpMethod.DELETE).listen(receptionContact.deleteReceptionContact)
    
    ..serve(organizationIdUrl, method: HttpMethod.GET).listen(organization.getOrganization)
    ..defaultStream.listen(NOTFOUND);
}

void setupControllers(Database db) {
  contact = new ContactController(db);
  organization = new OrganizationController(db);
  reception = new ReceptionController(db);
  receptionContact = new ReceptionContactController(db);
}
