part of adaheads.server.model;

class ReceptionContact {
  int receptionId;
  int contactId;
  bool wants_messages;
  int distribution_list_id;
  Map attributes;
  bool enabled;
  
  ReceptionContact(
      int this.receptionId, 
      int this.contactId, 
      bool this.wants_messages,
      int this.distribution_list_id,
      Map this.attributes,
      bool this.enabled);
}
