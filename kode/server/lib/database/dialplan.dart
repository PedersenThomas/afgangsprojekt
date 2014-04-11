part of adaheads_server_database;

Future<Dialplan> _getDialplan(Pool pool, int receptionId) {
  String sql = '''
    SELECT id, dialplan, reception_telephonenumber
    FROM receptions
    WHERE id = @id
  ''';

  Map parameters = {'id': receptionId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      Dialplan dialplan = new Dialplan.fromJson(JSON.decode(row.dialplan));

      //In case the json is empty.
      if(dialplan == null) {
        dialplan = new Dialplan();
      }

      dialplan
        ..receptionId = row.id
        ..entryNumber = row.reception_telephonenumber;
      return dialplan;
    }
  });
}
