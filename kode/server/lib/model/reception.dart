part of adaheads_server_model;

class Reception {
  int id;
  int organizationId;
  String fullName;
  String uri;
  Map attributes;
  String extradatauri;
  bool enabled;
  
  Reception(int this.id, int this.organizationId, String this.fullName, String this.uri, Map this.attributes, String this.extradatauri, bool this.enabled);
}
