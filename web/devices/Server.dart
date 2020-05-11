import 'dart:html';

import 'Device.dart';
import 'WebPrintable.dart';

///class Server
///Represents a Server device.
///Extends Device as it is a type of manageable device.
///Implements WebPrintable as it needs to be represented in an HTML form.
class Server extends Device implements WebPrintable {

  ///Constructors
  Server(String id, String name, String ip) : super(id,name,ip);
  Server.withStatus(String id, String name, String ip, bool active) : super.withStatus(id,name,ip, active);

  ///printToHTML()
  ///Returns a DOM Element of the device's information.
  @override
  Element printToHTML() {
    Element card = Element.div()..classes.addAll(['card','device-card']);
    //Card Header
    Element cardHeader = Element.div()..classes.addAll(['card-header','text-right']);
    Element img = Element.img()..attributes.addAll({'src':'./server.png'});
    img.classes.add('server-icon');
    cardHeader.innerHtml += deviceName;
    cardHeader.children.add(img);
    //Card Body
    Element cardBody = Element.div()..classes.add('card-body');
    Element stateText = Element.tag('span');
    stateText.classes.add('text-primary');
    stateText.innerText = stateAsText();
    cardBody.children.add(stateText);
    //Card Footer
    Element cardFooter = Element.div()..classes.addAll(['card-footer','text-align-center']);
    cardFooter.innerHtml = ipAddress.toString();
    //Final element nesting
    card.children.addAll([cardHeader,cardBody,cardFooter]);
    return card;
  }
}