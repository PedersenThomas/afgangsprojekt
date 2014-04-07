import 'package:xml/xml.dart';

void main() {
  print("Hello, World!");

  XmlElement root = new XmlElement('Dialplan');
  XmlElement extension = new XmlElement('Extensions');
  extension.attributes['wday'] = 'monday';
  root.children.add(extension);
  print(root);

  XmlElement test =
      XML.parse(
      ''' <stackpanel>
          <checkbox text='Hello World!' ></checkbox>
          <textblock text='Hello World!' fontSize='12'></textblock>
              <border>
                  <image>
                      The quick brown fox jumped over the lazy dog.
                  </image>
              </border>
      </stackpanel>
      '''
      );
}
