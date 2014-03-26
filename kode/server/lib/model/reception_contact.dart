part of adaheads_server_model;

class ReceptionContact {
  int contactId;
  String fullName;
  String contactType;
  bool contactEnabled;
  int receptionId;
  bool wantsMessages;
  int distributionListId;
  Map attributes;
  bool receptionEnabled;
 
  ReceptionContact (
      int this.contactId,
      String this.fullName,
      String this.contactType,
      bool this.contactEnabled,
      int this.receptionId, 
      bool this.wantsMessages,
      int this.distributionListId,
      Map this.attributes,
      bool this.receptionEnabled);
}
