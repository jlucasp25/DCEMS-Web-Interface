import 'dart:html';

import 'front_end/DeviceListing.dart';
import 'front_end/Footer.dart';
import 'front_end/LoginPanel.dart';
import 'front_end/PanelNavBar.dart';

/// DCEMSApplication - Application Wrapper for DCEMS interface
/// Singleton Pattern
/// 

class DCEMSApplication {

  DCEMSApplication._constructor();

  static final DCEMSApplication _instance = DCEMSApplication._constructor();
  Element _stdout;


  factory DCEMSApplication() {
    return _instance;
  }

  void setStandardOutput(Element e) {
    _instance._stdout =  e;
  }

  void displayMainPage() {
    _instance._stdout.children.add(PanelNavBar.getPanelNavBar());
    DeviceListing dl = DeviceListing();
    _instance._stdout.children.add(dl.getDeviceListingPanel());
    //displayDevicePage(out);
    _instance._stdout.children.add(Footer.getFooter());
  }

  void displayLoginPage() {
    Element container = Element.div();
    container.classes.add('container-fluid');
    _instance._stdout.children.add(Element.br());
    LoginPanel panel = LoginPanel();
    container.children.add(panel.getLoginPanel());
    _instance._stdout.children.add(container);
  }

}
