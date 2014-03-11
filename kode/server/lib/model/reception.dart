part of adaheads.server.model;

class Reception {
  int id;
  String fullName;
  String uri;
  Map attributes;
  String extradatauri;
  bool enabled;
  
  Reception(int this.id, String this.fullName, String this.uri, Map this.attributes, String this.extradatauri, bool this.enabled);
}
