import 'dart:convert';
import 'dart:html';

import '../devices/Device.dart';
import 'BootstrapComponentWrappers.dart';
import 'SearchPanel.dart';

Map<String, String> headers = {'Content-type': 'text/plain',
};

class DeviceListing {
  Element panel;
  List<dynamic> devices = [];

  DeviceListing() {
    _buildDeviceListingPanel();
  }

  Element getDeviceListingPanel() {
    return panel;
  }

Future<void> listingRequest() async {
    Map<String,String> json = {
      'request_type':'listing'
    };
    List<dynamic> list = [];
    const path = 'http://localhost:8500/listing/';
    HttpRequest response = await HttpRequest.postFormData(path,json);
    devices = parseResponse(response);
  }

  List<dynamic> parseResponse(HttpRequest response) {
    List<dynamic> devs = [];
    var resp = jsonDecode(response.responseText);
    window.console.info(resp['response_body']);
    var body = jsonDecode(resp['response_body']);
    for (var device in body) {
      window.console.info(jsonEncode(device));
      Device dev = Device.fromJSON(device);
      window.console.info(dev);
      devs.add(dev);
    }
    return devs;
  }

///displayDevicePage()
///Test function to test the device listing layout.
void _buildDeviceListingPanel() async {
  panel = Element.div();
  panel.classes.add('container-fluid');
  panel.children.add(Element.br());

  //Container contents
  panel.children.add(SearchPanel.buildSearchPanel());
  
  //Fetch devices
  await listingRequest(); //Dynamic allows for a mixed list of Servers and UPS

  List<Element> row = [];
  int i = 0;
  //Generates DOM elements and adds them to rows. (not very good code here!)
  for (var dev in devices) {
    row.add(dev.printToHTML());
    i++;
    if (i == 3) {
      panel.children.add(BootstrapComponentWrappers.buildCentered3ElementsRow(row));
      row = [];
      i = 0;
    }
  }
  if (row.length != 0) {
    panel.children.add(BootstrapComponentWrappers.buildCentered3ElementsRow(row));
  }
}


}