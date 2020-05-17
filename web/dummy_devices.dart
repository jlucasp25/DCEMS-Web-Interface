import 'dart:convert';

void main() {
  var x = generateDummyJSONS();
}

List<String> generateDummyJSONS() {
  List<String> jsons = [];
  for (int i = 0 ; i < 5 ; i++) {
    bool status;
    if (i%2 == 0)
      status = true;
    else
      status = false;
    var JSON = {
      'device_id': i.toString(),
      'device_type': 'server',
      'device_ip': '100.0.0.0',
      'device_name': 'server_x',
      'device_status': status
    };
    jsons.add(jsonEncode(JSON));
  }
  for (int i = 5 ; i < 10 ; i++) {
    bool status;
    if (i%2 == 0)
      status = true;
    else
      status = false;
    var JSON = {
      'device_id': i.toString(),
      'device_type': 'ups',
      'device_ip': '100.0.0.0',
      'device_name': 'ups_x',
      'device_status': status,
      'device_charge': 90.0
    };
    jsons.add(jsonEncode(JSON));
  }
  return jsons;
}


/* Example of json */
/*
  {
    'device_id': 1,
    'device_type': 'server',
    'device_ip': '100.100.100.100',
    'device_status': 'active',
    'device_charge': 80

  }
*/