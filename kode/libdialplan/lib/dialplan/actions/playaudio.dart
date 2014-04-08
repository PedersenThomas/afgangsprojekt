part of Dialplan;

class PlayAudio implements Action {
  String comment;
  String filename;

  PlayAudio();

  PlayAudio.fromJson(Map json) {
    comment = json['comment'];

    if(json.containsKey('filename')) {
      filename = json['filename'];
    }
  }

  Map toJson() {
    Map result = {};

    if(comment != null) {
      result['comment'] = comment;
    }

    if(filename != null) {
      result['filename'] = filename;
    }

    return result;
  }
}
