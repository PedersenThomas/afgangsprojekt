part of Dialplan;

class Action {
  Action();

  factory Action.fromJson(Map json) {
    switch (json['action'] as String) {
      case 'playAudio': return new PlayAudio.fromJson(json);
      case 'receptionists': return new Receptionists.fromJson(json);
      case 'voicemail': return new Voicemail.fromJson(json);

      default:
        throw('Unknown action "${json['action']} ${json}"');
    }
  }

  Map toJson() => null;
}
