part of adaheads_server_database;

Future<int> _createReception(Pool pool, int organizationId, String fullName, String uri, Map attributes, String extradatauri, bool enabled) {
  String sql = '''
    INSERT INTO receptions (organization_id, full_name, uri, attributes, extradatauri, enabled)
    VALUES (@organization_id, @full_name, @uri, @attributes, @extradatauri, @enabled)
    RETURNING id;
  ''';

  Map parameters =
    {'organization_id': organizationId,
     'full_name'      : fullName,
     'uri'            : uri,
     'attributes'     : attributes == null ? '{}' : JSON.encode(attributes),
     'extradatauri'   : extradatauri,
     'enabled'        : enabled};

  return query(pool, sql, parameters).then((rows) => rows.first.id);
}

Future<int> _deleteReception(Pool pool, int organizationId, int id) {
  String sql = '''
      DELETE FROM receptions
      WHERE id=@id AND organization_id=@organization_id;
    ''';

  Map parameters =
    {'id': id,
     'organization_id': organizationId};
  return execute(pool, sql, parameters);
}

Future<List<model.Reception>> _getOrganizationReceptionList(Pool pool, int organizationId) {
  String sql = '''
    SELECT id, organization_id, full_name, uri, attributes, extradatauri, enabled
    FROM receptions
    WHERE organization_id=@organization_id
  ''';

  Map parameters = {'organization_id': organizationId};

  return query(pool, sql, parameters).then((rows) {
    List<model.Reception> receptions = new List<model.Reception>();
    for(var row in rows) {
      receptions.add(new model.Reception(row.id, row.organization_id, row.full_name, row.uri, JSON.decode(row.attributes), row.extradatauri, row.enabled));
    }
    return receptions;
  });
}

Future<model.Reception> _getReception(Pool pool, int organizationId, int receptionId) {
  String sql = '''
    SELECT id, organization_id, full_name, uri, attributes, extradatauri, enabled
    FROM receptions
    WHERE id = @id AND organization_id=@organization_id
  ''';

  Map parameters =
    {'id': receptionId,
     'organization_id': organizationId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      return new model.Reception(row.id, row.organization_id, row.full_name, row.uri, JSON.decode(row.attributes), row.extradatauri, row.enabled);
    }
  });
}

Future<List<model.Reception>> _getReceptionList(Pool pool) {
  String sql = '''
    SELECT id, organization_id, full_name, uri, attributes, extradatauri, enabled
    FROM receptions
  ''';

  return query(pool, sql).then((rows) {

    List<model.Reception> receptions = new List<model.Reception>();
    for(var row in rows) {
      receptions.add(new model.Reception(row.id, row.organization_id, row.full_name, row.uri, JSON.decode(row.attributes), row.extradatauri, row.enabled));
    }
    return receptions;
  });
}

Future<int> _updateReception(Pool pool, int organizationId, int id, String fullName, String uri, Map attributes, String extradatauri, bool enabled) {
  String sql = '''
    UPDATE receptions
    SET full_name=@full_name, uri=@uri, attributes=@attributes, extradatauri=@extradatauri, enabled=@enabled
    WHERE id=@id AND organization_id=@organization_id;
  ''';

  Map parameters =
    {'full_name'      : fullName,
     'uri'            : uri,
     'attributes'     : attributes == null ? '{}' : JSON.encode(attributes),
     'extradatauri'   : extradatauri,
     'enabled'        : enabled,
     'id'             : id,
     'organization_id': organizationId};

  return execute(pool, sql, parameters);
}

Future<List<model.Reception>> _getContactReceptions(Pool pool, int contactId) {
  String sql = '''
    SELECT r.id, r.organization_id, r.full_name, r.uri, r.attributes, r.extradatauri, r.enabled
    FROM reception_contacts rc
      JOIN receptions r on rc.reception_id = r.id
    WHERE rc.contact_id=@contact_id
  ''';

  Map parameters = {'contact_id': contactId};

  return query(pool, sql, parameters).then((rows) {
    List<model.Reception> receptions = new List<model.Reception>();
    for(var row in rows) {
      receptions.add(new model.Reception(row.id, row.organization_id, row.full_name, row.uri, JSON.decode(row.attributes), row.extradatauri, row.enabled));
    }
    return receptions;
  });
}
