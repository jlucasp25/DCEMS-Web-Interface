import 'dart:html';

import 'front_end/PanelNavBar.dart';
import 'front_end/SearchPanel.dart';
import 'front_end/BootstrapComponentWrappers.dart';
import 'devices/Server.dart';
import 'devices/UPS.dart';

void main() {
  //Outputs content to the dart container.
  Element out = querySelector('#dart_output');
  //Displays the device test page on the container.
  displayDevicePage(out);
}

///displayDevicePage()
///Test function to test the device listing layout.
void displayDevicePage(Element out) {
  Element container = Element.div();
  container.classes.add('container-fluid');
  out.children.add(Element.br());

  //Container contents
  container.children.add(PanelNavBar.getPanelNavBar());
  container.children.add(SearchPanel.buildSearchPanel());
  container.children.add(BootstrapComponentWrappers.buildCentered3ElementsRow([
    Server.withStatus('1','server-1','192.168.0.1',true).printToHTML(),
    Server.withStatus('2','server-2','192.168.0.2',true).printToHTML(),
    Server.withStatus('3','server-3','192.168.0.3',false).printToHTML(),
    ]));
  container.children.add(BootstrapComponentWrappers.buildCentered3ElementsRow([
    UPS.withStatus('4','ups-1','192.168.0.4',90,true).printToHTML(),
    UPS.withStatus('5','ups-2','192.168.0.5',90,true).printToHTML(),
    UPS.withStatus('6','ups-3','192.168.0.6',90,false).printToHTML(),
    ]));
  //Append container to the dart output
  out.children.add(container);
}
