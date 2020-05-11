import 'dart:html';

import 'Device.dart';
import 'WebPrintable.dart';


class UPS extends Device implements WebPrintable {
  ///Properties
  double charge;

  ///Constructors
  UPS(String id, String name, String ip, double charge) : super(id,name,ip) {
    charge = charge;
  }
  UPS.withStatus(String id, String name, String ip, double charge, bool status) : super.withStatus(id,name,ip,status);

  ///printToHTML()
  ///Returns a DOM Element of the device's information.
  @override
  Element printToHTML() {
    Element card = Element.div()..classes.addAll(['card','device-card']);
    //Card Header
    Element cardHeader = Element.div()..classes.addAll(['card-header','text-right']);
    Element img = Element.img()..attributes.addAll({'src':'./ups.png'});
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
    //Nests elements
    card.children.addAll([cardHeader,cardBody,cardFooter]);
    return card;
  }

}