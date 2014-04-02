part of adaheads_server_database;

Future<model.Organization> _getOrganization(Pool pool, int organizationId) {
  String sql = '''
    SELECT id, full_name
    FROM organizations
    WHERE id = @id
  ''';

  Map parameters = {'id': organizationId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      return new model.Organization(row.id, row.full_name);
    }
  });
}

Future<List<model.Organization>> _getOrganizationList(Pool pool) {
  String sql = '''
    SELECT id, full_name
    FROM organizations
  ''';

  return query(pool, sql).then((rows) {
    List<model.Organization> organizations = new List<model.Organization>();
    for(var row in rows) {
      organizations.add(new model.Organization(row.id, row.full_name));
    }

    return organizations;
  });
}

Future<int> _createOrganization(Pool pool, String fullName) {
  String sql = '''
    INSERT INTO organizations (full_name)
    VALUES (@full_name)
    RETURNING id;
  ''';

  Map parameters = {'full_name' : fullName};

  return query(pool, sql, parameters).then((rows) => rows.first.id);
}

Future<int> _updateOrganization(Pool pool, int organizationId, String fullName) {
  String sql = '''
    UPDATE organizations
    SET full_name=@full_name
    WHERE id=@id;
  ''';

  Map parameters =
    {'full_name'    : fullName,
     'id'           : organizationId};

  return execute(pool, sql, parameters);
}

Future<int> _deleteOrganization(Pool pool, int organizationId) {
  String sql = '''
    DELETE FROM organizations
    WHERE id=@id;
  ''';

  Map parameters = {'id': organizationId};
  return execute(pool, sql, parameters);
}
