part of adaheads_server_database;

Future<model.CompleteReceptionContact> _getReceptionContact(Pool pool, int receptionId, int contactId) {
  String sql = '''
    SELECT c.id, 
           c.full_name, 
           c.contact_type, 
           c.enabled as contactenabled, 
          rc.reception_id, 
          rc.wants_messages, 
          rc.distribution_list_id, 
          rc.attributes, 
          rc.enabled as receptionenabled,
          (SELECT array_to_json(array_agg(row_to_json(row)))
           FROM (SELECT 
           pn.id, pn.value, pn.kind
           FROM contact_phone_numbers cpn
             JOIN phone_numbers pn on cpn.phone_number_id = pn.id
           WHERE cpn.reception_id = rc.reception_id AND cpn.contact_id = rc.contact_id
           ) row) as phone
    FROM reception_contacts rc
      JOIN contacts c on rc.contact_id = c.id
    WHERE rc.reception_id = @reception_id AND rc.contact_id = @contact_id
  ''';

  Map parameters =
    {'reception_id': receptionId,
     'contact_id': contactId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;

      List<model.Phone> phonenumbers = new List<model.Phone>();
      if(row.phone != null) {
        phonenumbers = (JSON.decode(row.phone) as List).map((Map obj) => new model.Phone(obj['id'], obj['value'], obj['kind'])).toList();
      }

      return new model.CompleteReceptionContact(
          row.id,
          row.full_name,
          row.contact_type,
          row.contactenabled,
          row.reception_id,
          row.wants_messages,
          row.distribution_list_id,
          row.attributes == null ? {} : JSON.decode(row.attributes),
          row.receptionenabled,
          phonenumbers);
    }
  });
}

Future<List<model.CompleteReceptionContact>> _getReceptionContactList(Pool pool, int receptionId) {
  String sql = '''
    SELECT c.id, 
           c.full_name, 
           c.contact_type, 
           c.enabled as contactenabled, 
          rc.reception_id, 
          rc.wants_messages, 
          rc.distribution_list_id, 
          rc.attributes, 
          rc.enabled as receptionenabled,
          (SELECT array_to_json(array_agg(row_to_json(row)))
           FROM (SELECT 
           pn.id, pn.value, pn.kind
           FROM contact_phone_numbers cpn
             JOIN phone_numbers pn on cpn.phone_number_id = pn.id
           WHERE cpn.reception_id = rc.reception_id AND cpn.contact_id = rc.contact_id
           ) row) as phone
    FROM reception_contacts rc
      JOIN contacts c on rc.contact_id = c.id
    WHERE rc.reception_id = @reception_id
  ''';

  Map parameters = {'reception_id': receptionId};

  return query(pool, sql, parameters).then((rows) {
    List<model.CompleteReceptionContact> receptions = new List<model.CompleteReceptionContact>();
    for(var row in rows) {
      List<model.Phone> phonenumbers = new List<model.Phone>();
      if(row.phone != null) {
        phonenumbers = (JSON.decode(row.phone) as List).map((Map obj) => new model.Phone(obj['id'], obj['value'], obj['kind'])).toList();
      }

      receptions.add(new model.CompleteReceptionContact(
          row.id,
          row.full_name,
          row.contact_type,
          row.contactenabled,
          row.reception_id,
          row.wants_messages,
          row.distribution_list_id,
          row.attributes == null ? {} : JSON.decode(row.attributes),
          row.receptionenabled,
          phonenumbers));
    }
    return receptions;
  });
}

Future<int> _createReceptionContact(Pool pool, int receptionId, int contactId, bool wantMessages, int distributionListId, Map attributes, bool enabled) {
  String sql = '''
    INSERT INTO reception_contacts (reception_id, contact_id, wants_messages, distribution_list_id, attributes, enabled)
    VALUES (@reception_id, @contact_id, @wants_messages, @distribution_list_id, @attributes, @enabled);
  ''';

  Map parameters =
    {'reception_id'         : receptionId,
     'contact_id'           : contactId,
     'wants_messages'       : wantMessages,
     'distribution_list_id' : distributionListId,
     'attributes'           : attributes == null ? '{}' : JSON.encode(attributes),
     'enabled'              : enabled};

  return execute(pool, sql, parameters);
}

Future<int> _deleteReceptionContact(Pool pool, int receptionId, int contactId) {
  String sql = '''
    DELETE FROM reception_contacts
    WHERE reception_id=@reception_id AND contact_id=@contact_id;
  ''';

  Map parameters = {'reception_id' : receptionId,
                    'contact_id'   : contactId};
  return execute(pool, sql, parameters);
}

Future<int> _updateReceptionContact(Pool pool, int receptionId, int contactId, bool wantMessages, int distributionListId, Map attributes, bool enabled) {
  String sql = '''
    UPDATE reception_contacts
    SET wants_messages=@wants_messages,
        distribution_list_id=@distribution_list_id,
        attributes=@attributes,
        enabled=@enabled
    WHERE reception_id=@reception_id AND contact_id=@contact_id;
  ''';

  Map parameters =
    {'reception_id'         : receptionId,
     'contact_id'           : contactId,
     'wants_messages'       : wantMessages,
     'distribution_list_id' : distributionListId,
     'attributes'           : attributes == null ? '{}' : JSON.encode(attributes),
     'enabled'              : enabled};

  return execute(pool, sql, parameters);
}

Future<List<model.ReceptionContact_ReducedReception>> _getAContactsReceptionContactList(Pool pool, int contactId) {
  String sql = '''
    SELECT rc.contact_id,
           rc.wants_messages,
           rc.distribution_list_id,
           rc.attributes,
           rc.enabled as contactenabled,
            r.organization_id,
            r.id as reception_id,
            r.full_name as receptionname,
            r.uri as receptionuri,
            r.enabled as receptionenabled,
            r.organization_id,
          (SELECT array_to_json(array_agg(row_to_json(row)))
           FROM (SELECT 
           pn.id, pn.value, pn.kind
           FROM contact_phone_numbers cpn
             JOIN phone_numbers pn on cpn.phone_number_id = pn.id
           WHERE cpn.reception_id = rc.reception_id AND cpn.contact_id = rc.contact_id
           ) row) as phone
    FROM reception_contacts rc
      JOIN receptions r on rc.reception_id = r.id
    WHERE rc.contact_id = @contact_id
  ''';

  Map parameters = {'contact_id': contactId};

  return query(pool, sql, parameters).then((rows) {
    List<model.ReceptionContact_ReducedReception> contacts = new List<model.ReceptionContact_ReducedReception>();
    for(var row in rows) {
      List<model.Phone> phonenumbers = new List<model.Phone>();
      if(row.phone != null) {
        phonenumbers = (JSON.decode(row.phone) as List).map((Map obj) => new model.Phone(obj['id'], obj['value'], obj['kind'])).toList();
      }

      contacts.add(new model.ReceptionContact_ReducedReception(
        row.contact_id,
        row.wants_messages,
        row.distribution_list_id,
        row.attributes == null ? {} : JSON.decode(row.attributes),
        row.contactenabled,
        phonenumbers,
        row.reception_id,
        row.receptionname,
        row.receptionuri,
        row.receptionenabled,
        row.organization_id));
    }
    return contacts;
  });
}

Future<List<model.Organization>> _getAContactsOrganizationList(Pool pool, int contactId) {
  String sql = '''
    SELECT DISTINCT o.id, o.full_name
    FROM reception_contacts rc
    JOIN receptions r on rc.reception_id = r.id
    JOIN organizations o on r.organization_id = o.id
    WHERE rc.contact_id = @contact_id
  ''';

  Map parameters = {'contact_id': contactId};

  return query(pool, sql, parameters).then((rows) {
    List<model.Organization> organizations = new List<model.Organization>();
    for(var row in rows) {
      organizations.add(new model.Organization(row.id, row.full_name));
    }
    return organizations;
  });
}
