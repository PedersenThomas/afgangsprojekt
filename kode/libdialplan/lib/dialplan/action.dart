part of Dialplan;

class Action implements JsonSerializable {
  Action();

  factory Action.fromJson(Map json) {
    switch (json['action'] as String) {
      case 'forward':
        return new Forward.fromJson(json);
      case 'executeivr':
        return new ExecuteIvr.fromJson(json);
      case 'playaudio':
        return new PlayAudio.fromJson(json);
      case 'receptionists':
        return new Receptionists.fromJson(json);
      case 'voicemail':
        return new Voicemail.fromJson(json);

      default:
        throw ('Unknown action. action name:"${json['action']}" complete Object:"${json}"');
    }
  }

  Map toJson() => null;
}
