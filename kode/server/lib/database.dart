library adaheads_server_database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';
import 'package:postgresql/postgresql.dart';

import 'model.dart';
import 'configuration.dart';

Future<Database> setupDatabase(Configuration config) {
  Database db = new Database(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname);
  return db.start().then((_) => db);
}

class Database {
  Pool pool;
  String user, password, host, name;
  int port, minimumConnections, maximumConnections;
  
  Database(String this.user, String this.password, String this.host, int this.port, String this.name, {int this.minimumConnections: 1, int this.maximumConnections: 10});
  
  Future start() {
    String connectString = 'postgres://${user}:${password}@${host}:${port}/${name}';
    
    pool = new Pool(connectString, min: minimumConnections, max: maximumConnections);
    return pool.start().then((_) => _testConnection());
  }

  Future _testConnection() => pool.connect().then((Connection conn) => conn.close());
  
  Future<List<Row>> query(String sql, [Map parameters = null]) => pool.connect()
    .then((Connection conn) => conn.query(sql, parameters).toList()
    .whenComplete(() => conn.close()));
  
  Future<int> execute(String sql, [Map parameters = null]) => pool.connect()
    .then((Connection conn) => conn.execute(sql, parameters)
    .whenComplete(() => conn.close()));
  
  /************************************************
   ***************** Reception ********************
  */

  Future<Reception> getReception(int organizationId, int receptionId) {
    String sql = '''
      SELECT id, organization_id, full_name, uri, attributes, extradatauri, enabled
      FROM receptions
      WHERE id = @id AND organization_id=@organization_id
    ''';
    
    Map parameters = 
      {'id': receptionId,
       'organization_id': organizationId};
    
    return query(sql, parameters).then((rows) {
      if(rows.length != 1) {
        return null;
      } else {
        Row row = rows.first;
        return new Reception(row.id, row.organization_id, row.full_name, row.uri, JSON.decode(row.attributes), row.extradatauri, row.enabled);
      }
    });
  }
  
  Future<List<Reception>> getReceptionList() {
      String sql = '''
        SELECT id, organization_id, full_name, uri, attributes, extradatauri, enabled
        FROM receptions
      ''';
     
      return query(sql).then((rows) {
        
        List<Reception> receptions = new List<Reception>();
        for(var row in rows) {
          receptions.add(new Reception(row.id, row.organization_id, row.full_name, row.uri, JSON.decode(row.attributes), row.extradatauri, row.enabled));
        }
        return receptions;
      });
    }
  
  Future<List<Reception>> getOrganizationReceptionList(int organizationId) {
    String sql = '''
      SELECT id, organization_id, full_name, uri, attributes, extradatauri, enabled
      FROM receptions
      WHERE organization_id=@organization_id
    ''';
    
    Map parameters = {'organization_id': organizationId};

    return query(sql, parameters).then((rows) {
      List<Reception> receptions = new List<Reception>();
      for(var row in rows) {
        receptions.add(new Reception(row.id, row.organization_id, row.full_name, row.uri, JSON.decode(row.attributes), row.extradatauri, row.enabled));
      }
      return receptions;
    });
  }
  
  Future<int> createReception(int organizationId, String fullName, String uri, Map attributes, String extradatauri, bool enabled) {
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
      
    return query(sql, parameters).then((rows) => rows.first.id);
  }
  
  Future<int> updateReception(int organizationId, int id, String fullName, String uri, Map attributes, String extradatauri, bool enabled) {
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
      
    return execute(sql, parameters);
  }

  Future<int> deleteReception(int organizationId, int id) {
    String sql = '''
        DELETE FROM receptions
        WHERE id=@id AND organization_id=@organization_id;
      ''';

    Map parameters = 
      {'id': id,
       'organization_id': organizationId};
    return execute(sql, parameters);
  }
  
  /************************************************
   ****************** Contact *********************
  */
  
  Future<Contact> getContact(int contactId) {
    String sql = '''
      SELECT id, full_name, contact_type, enabled
      FROM contacts
      WHERE id = @id
    ''';
    
    Map parameters = {'id': contactId};
    
    return query(sql, parameters).then((rows) {
      if(rows.length != 1) {
        return null;
      } else {
        Row row = rows.first;
        return new Contact(row.id, row.full_name, row.contact_type, row.enabled);
      }
    });
  }
  
  Future<List<Contact>> getContactList() {
    String sql = '''
      SELECT id, full_name, contact_type, enabled
      FROM contacts
    ''';

    return query(sql).then((rows) {
      List<Contact> contacts = new List<Contact>();
      for(var row in rows) {
        contacts.add(new Contact(row.id, row.full_name, row.contact_type, row.enabled));
      }
      return contacts;
    });
  }
  
  Future<int> createContact(String fullName, String contact_type, bool enabled) {
    String sql = '''
      INSERT INTO contacts (full_name, contact_type, enabled)
      VALUES (@full_name, @contact_type, @enabled)
      RETURNING id;
    ''';

    Map parameters =
      {'full_name'    : fullName,
       'contact_type' : contact_type,
       'enabled'      : enabled};
      
    return query(sql, parameters).then((rows) => rows.first.id);
  }
  
  Future<int> updateContact(int contactId, String fullName, String contact_type, bool enabled) {
    String sql = '''
      UPDATE contacts
      SET full_name=@full_name, contact_type=@contact_type, enabled=@enabled
      WHERE id=@id;
    ''';

    Map parameters =
      {'full_name'    : fullName,
       'contact_type' : contact_type,
       'enabled'      : enabled,
       'id'           : contactId};
      
    return execute(sql, parameters);
  }

  Future<int> deleteContact(int contactId) {
    String sql = '''
        DELETE FROM contacts
        WHERE id=@id;
      ''';

    Map parameters = {'id': contactId};
    return execute(sql, parameters);
  }  
  
  /************************************************
   ************ Reception Contacts ****************
   */
  
  Future<CompleteReceptionContact> getReceptionContact(int receptionId, int contactId) {
    String sql = '''
      SELECT c.id, 
             c.full_name, 
             c.contact_type, 
             c.enabled as contactenabled, 
            rc.reception_id, 
            rc.wants_messages, 
            rc.distribution_list_id, 
            rc.attributes, 
            rc.enabled as receptionenabled
      FROM reception_contacts rc
        JOIN contacts c on rc.contact_id = c.id
      WHERE rc.reception_id = @reception_id AND rc.contact_id = @contact_id
    ''';
    
    Map parameters = 
      {'reception_id': receptionId,
       'contact_id': contactId};
    
    return query(sql, parameters).then((rows) {
      if(rows.length != 1) {
        return null;
      } else {
        Row row = rows.first;
        return new CompleteReceptionContact(
            row.id,
            row.full_name,
            row.contact_type,
            row.contactenabled,
            row.reception_id,
            row.wants_messages,
            row.distribution_list_id,
            row.attributes == null ? {} : JSON.decode(row.attributes),
            row.receptionenabled);
      }
    });
  }
  
  Future<List<CompleteReceptionContact>> getReceptionContactList(int receptionId) {
    String sql = '''
      SELECT c.id, 
             c.full_name, 
             c.contact_type, 
             c.enabled as contactenabled, 
            rc.reception_id, 
            rc.wants_messages, 
            rc.distribution_list_id, 
            rc.attributes, 
            rc.enabled as receptionenabled
      FROM reception_contacts rc
        JOIN contacts c on rc.contact_id = c.id
      WHERE rc.reception_id = @reception_id
    ''';
    
    Map parameters = {'reception_id': receptionId};

    return query(sql, parameters).then((rows) {
      List<CompleteReceptionContact> receptions = new List<CompleteReceptionContact>();
      for(var row in rows) {
        receptions.add(new CompleteReceptionContact(
            row.id,
            row.full_name,
            row.contact_type,
            row.contactenabled,
            row.reception_id,
            row.wants_messages,
            row.distribution_list_id,
            row.attributes == null ? {} : JSON.decode(row.attributes),
            row.receptionenabled));
      }
      return receptions;
    });
  }
  
  Future<int> createReceptionContact(int receptionId, int contactId, bool wantMessages, int distributionListId, Map attributes, bool enabled) {
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
    
    return execute(sql, parameters);
  }

  Future<int> deleteReceptionContact(int receptionId, int contactId) {
    String sql = '''
      DELETE FROM reception_contacts
      WHERE reception_id=@reception_id AND contact_id=@contact_id;
    ''';

    Map parameters = {'reception_id' : receptionId,
                      'contact_id'   : contactId};
    return execute(sql, parameters);
  }
  
  Future<int> updateReceptionContact(int receptionId, int contactId, bool wantMessages, int distributionListId, Map attributes, bool enabled) {
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
      
    return execute(sql, parameters);
  }
  
  Future<List<ReceptionContact_ReducedReception>> getAContactsReceptionContactList(int contactId) {
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
              r.organization_id
      FROM reception_contacts rc
        JOIN receptions r on rc.reception_id = r.id
      WHERE rc.contact_id = @contact_id
    ''';
    
    Map parameters = {'contact_id': contactId};
    
    return query(sql, parameters).then((rows) {
      List<ReceptionContact_ReducedReception> contacts = new List<ReceptionContact_ReducedReception>();
      for(var row in rows) {
        contacts.add(new ReceptionContact_ReducedReception(
          row.contact_id,
          row.wants_messages,
          row.distribution_list_id,
          row.attributes == null ? {} : JSON.decode(row.attributes),
          row.contactenabled,
          row.reception_id,
          row.receptionname,
          row.receptionuri,
          row.receptionenabled,
          row.organization_id));
      }
      return contacts;
    });
  }
  
  /************************************************
   *************** Organization *******************
   */
  
  Future<Organization> getOrganization(int organizationId) {
    String sql = '''
      SELECT id, full_name
      FROM organizations
      WHERE id = @id
    ''';
    
    Map parameters = {'id': organizationId};
    
    return query(sql, parameters).then((rows) {
      if(rows.length != 1) {
        return null;
      } else {
        Row row = rows.first;
        return new Organization(row.id, row.full_name);
      }
    });
  }
  
  Future<List<Organization>> getOrganizationList() {
    String sql = '''
      SELECT id, full_name
      FROM organizations
    ''';

    return query(sql).then((rows) {
      List<Organization> organizations = new List<Organization>();
      for(var row in rows) {
        organizations.add(new Organization(row.id, row.full_name));
      }

      return organizations;
    });
  }
  
  Future<int> createOrganization(String fullName) {
    String sql = '''
      INSERT INTO organizations (full_name)
      VALUES (@full_name)
      RETURNING id;
    ''';

    Map parameters = {'full_name' : fullName};
      
    return query(sql, parameters).then((rows) => rows.first.id);
  }
  
  Future<int> updateOrganization(int organizationId, String fullName) {
    String sql = '''
      UPDATE organizations
      SET full_name=@full_name
      WHERE id=@id;
    ''';

    Map parameters =
      {'full_name'    : fullName,
       'id'           : organizationId};
      
    return execute(sql, parameters);
  }

  Future<int> deleteOrganization(int organizationId) {
    String sql = '''
      DELETE FROM organizations
      WHERE id=@id;
    ''';

    Map parameters = {'id': organizationId};
    return execute(sql, parameters);
  }
  
  /***
   * STUFF
   */
  
  Future<List<Reception>> getContactReceptions(int contactId) {
    String sql = '''
      SELECT r.id, r.organization_id, r.full_name, r.uri, r.attributes, r.extradatauri, r.enabled
      FROM reception_contacts rc
        JOIN receptions r on rc.reception_id = r.id
      WHERE rc.contact_id=@contact_id
    ''';
    
    Map parameters = {'contact_id': contactId};

    return query(sql, parameters).then((rows) {
      List<Reception> receptions = new List<Reception>();
      for(var row in rows) {
        receptions.add(new Reception(row.id, row.organization_id, row.full_name, row.uri, JSON.decode(row.attributes), row.extradatauri, row.enabled));
      }
      return receptions;
    });
  }
  
//  Future<List<ReceptionContact>> getContactReceptionContact(int contactId) {
//    String sql = '''
//      SELECT reception_id, contact_id, wants_messages, distribution_list_id, attributes, enabled
//      FROM reception_contacts rc
//        JOIN contact c on rc.contact_id = c.id
//      WHERE contact_id = @contact_id
//    ''';
//    
//    Map parameters = {'contact_id': contactId};
//
//    return query(sql, parameters).then((rows) {
//      List<ReceptionContact> receptions = new List<ReceptionContact>();
//      for(var row in rows) {
//        receptions.add(new ReceptionContact(
//            row.reception_id, 
//            row.contact_id, 
//            row.wants_messages,
//            row.distribution_list_id,
//            row.attributes == null ? {} : JSON.decode(row.attributes),
//            row.enabled));
//      }
//      return receptions;
//    });
//  }
  
  Future<List<Contact>> getOrganizationContactList(int organizationId) {
    String sql = '''
      SELECT DISTINCT c.id, c.full_name, c.enabled, c.contact_type
      FROM receptions r
        JOIN reception_contacts rc on r.id = rc.reception_id
        JOIN contacts c on rc.contact_id = c.id
      WHERE r.organization_id = @organization_id
      ORDER BY c.id
    ''';
        
    Map parameters = {'organization_id': organizationId};

    return query(sql, parameters).then((rows) {
      List<Contact> contacts = new List<Contact>();
      for(var row in rows) {
        contacts.add(new Contact(row.id, row.full_name, row.contact_type, row.enabled));
      }
      return contacts;
    });
  }
}

