library IVR;

class IVR {
  String name;
  String greetingFile;
  List<Entry> Entries = new List<Entry>();
}

class Entry {
  int digits;
  String extensionName;
}
