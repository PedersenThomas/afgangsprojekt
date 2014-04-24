part of adaheads_server_model;

class CompleteReceptionContact {
  int id;
  String fullName;
  String contactType;
  bool contactEnabled;
  int receptionId;
  bool wantsMessages;
  int distributionListId;
  Map attributes;
  bool receptionEnabled;
  List<Phone> phonenumbers;

  CompleteReceptionContact (
    int this.id,
    String this.fullName,
    String this.contactType,
    bool this.contactEnabled,
    int this.receptionId,
    bool this.wantsMessages,
    int this.distributionListId,
    Map this.attributes,
    bool this.receptionEnabled,
    List<Phone> this.phonenumbers);
}
