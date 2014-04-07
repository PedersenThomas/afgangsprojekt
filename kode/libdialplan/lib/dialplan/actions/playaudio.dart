part of Dialplan;

class PlayAudio implements Action {
  String comment;

  PlayAudio();

  PlayAudio.fromJson(Map json) {

  }

  Map toJson() {
    Map result = {};

    if(comment != null) {
      result['comment'] = comment;
    }

    return result;
  }
}
