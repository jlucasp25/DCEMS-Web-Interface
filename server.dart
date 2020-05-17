import 'dart:io';
import 'dart:convert';
/**
 * Dummy server to test dart features
 */

final int PORT = 8500; 
void main() async {
  print('Server started on port ' + PORT.toString());

  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    PORT
  );



  await for (var request in server) {
    requestHandler(request);
  }
}

void requestHandler(HttpRequest request) {
  if (request.method == 'GET') {
    GETHandler(request);
  }
  else if (request.method == 'POST') {
    POSTHandler(request);
  }
  else {
    print(request.method);
  }

}

void GETHandler(HttpRequest request) {
  return;
}

void POSTHandler(HttpRequest request) {
  print(request.uri);  
  final response = request.response;
  response.headers.add("Access-Control-Allow-Origin", "*");
  response.headers.add("Access-Control-Allow-Methods", "POST,GET,DELETE,PUT,OPTIONS");
  if (request.uri.toString() == '/login/') {
    //lets assume for now ure a real user :)
    response.statusCode = HttpStatus.ok;
    var responseJSON = {
      'response_type':'login',
      'response_body':'ok'
    };
    response..writeln(jsonEncode(responseJSON))..close();
  }
  else if (request.uri.toString() == '/listing/') {
    final response = request.response;
    response.statusCode = HttpStatus.ok;
    var responseJSON = {
      'response_type':'listing',
      'response_body': jsonEncode(generateDummyJSONS())
    };
    response..writeln(jsonEncode(responseJSON))..close();
  }
  
}


List<dynamic> generateDummyJSONS() {
  List<dynamic> jsons = [];
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
    jsons.add(JSON);
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
    jsons.add(JSON);
  }
  return jsons;
}