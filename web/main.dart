import 'dart:html';

import 'DCEMSApplication.dart';
import 'front_end/PanelNavBar.dart';
import 'front_end/Footer.dart';
import 'front_end/LoginPanel.dart';
import 'front_end/DeviceListing.dart';
void main() {
  //Outputs content to the dart container.
  Element out = querySelector('#dart_output');
  DCEMSApplication app = DCEMSApplication();
  app.setStandardOutput(out);
  app.displayLoginPage();
}


