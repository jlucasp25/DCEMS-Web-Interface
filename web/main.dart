import 'dart:html';

import 'front_end/PanelNavBar.dart';
import 'front_end/SearchPanel.dart';
import 'front_end/BootstrapComponentWrappers.dart';
import 'front_end/Footer.dart';
import 'front_end/LoginPanel.dart';
import 'devices/Server.dart';
import 'devices/UPS.dart';
import 'devices/Device.dart';
import 'dummy_devices.dart';
void main() {
  //Outputs content to the dart container.
  Element out = querySelector('#dart_output');
  //Displays the device test page on the container.
  out.children.add(PanelNavBar.getPanelNavBar());
  displayEntryPage(out);
  
  //displayDevicePage(out);
  out.children.add(Footer.getFooter());
}


void displayEntryPage(Element out) {
  Element container = Element.div();
  container.classes.add('container-fluid');
  out.children.add(Element.br());
  LoginPanel panel = LoginPanel();
  container.children.add(panel.getLoginPanel());
  out.children.add(container);
}

///displayDevicePage()
///Test function to test the device listing layout.
void displayDevicePage(Element out) {
  Element container = Element.div();
  container.classes.add('container-fluid');
  out.children.add(Element.br());

  //Container contents
  container.children.add(SearchPanel.buildSearchPanel());
  
  //Generate dummy devices
  List<String> devicesJSONs = generateDummyJSONS();
  List<dynamic> devices = []; //Dynamic allows for a mixed list of Servers and UPS
  for (String device in devicesJSONs) {
    var dev = Device.fromJSON(device);
    devices.add(dev);
  }
  /*  int i = 1;
  
  for (Device device in devices) {
    i++;
  }*/
  List<Element> row = [];
  int i = 0;
  //Generates DOM elements and adds them to rows. (not very good code here!)
  for (var dev in devices) {
    row.add(dev.printToHTML());
    i++;
    if (i == 3) {
      container.children.add(BootstrapComponentWrappers.buildCentered3ElementsRow(row));
      row = [];
      i = 0;
    }
  }
  if (row.length != 0) {
    container.children.add(BootstrapComponentWrappers.buildCentered3ElementsRow(row));
  }

  //Append container to the dart output
  out.children.add(container);
}
