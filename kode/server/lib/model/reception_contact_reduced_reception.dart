part of adaheads_server_model;

class ReceptionContact_ReducedReception {
  int contactId;
  bool wantsMessages;
  int distributionListId;
  Map attributes;
  bool contactEnabled;

  int receptionId;
  bool receptionEnabled;
  String receptionName;
  String receptionUri;
  
  int organizationId;
 
  ReceptionContact_ReducedReception (
    int this.contactId,
    bool this.wantsMessages,
    int this.distributionListId,
    Map this.attributes,
    bool this.contactEnabled,
    
    int this.receptionId,
    String this.receptionName,
    String this.receptionUri,
    bool this.receptionEnabled,
    
    int this.organizationId);
}
