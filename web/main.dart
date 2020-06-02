import 'dart:html';

import 'front_end/PanelNavBar.dart';
import 'front_end/Footer.dart';
import 'front_end/LoginPanel.dart';
import 'front_end/DeviceListing.dart';
void main() {
  //Outputs content to the dart container.
  Element out = querySelector('#dart_output');
  //Displays the device test page on the container.
  out.children.add(PanelNavBar.getPanelNavBar());
  DeviceListing dl = DeviceListing();
  out.children.add(dl.getDeviceListingPanel());
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

