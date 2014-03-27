library adaheads.server.view.reception_contact_reduced_reception;

import '../model.dart';

Map ReceptionContact_ReducedReceptionAsJson(ReceptionContact_ReducedReception r) => r == null ? {} : 
    {'contact_id': r.contactId,
     'contact_wants_messages': r.wantsMessages,
     'contact_distribution_list_id': r.distributionListId,
     'contact_attributes': r.attributes,
     'contact_enabled': r.contactEnabled,
     
     'reception_id': r.receptionId,
     'reception_full_name': r.receptionName,
     'reception_uri': r.receptionUri,
     'reception_enabled': r.receptionEnabled,
     
     'organization_id': r.organizationId};

List listReceptionContact_ReducedReceptionAsJson(List<ReceptionContact_ReducedReception> receptions) => receptions.map(ReceptionContact_ReducedReceptionAsJson).toList();
