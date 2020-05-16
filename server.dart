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
    throw Exception('Not a valid method on request!');
  }

}

void GETHandler(HttpRequest request) {
  return;
}

void POSTHandler(HttpRequest request) {
  if (request.uri.toString() == '/login/') {
    //lets assume for now ure a real user :)
    final response = request.response;
    response.statusCode = HttpStatus.ok;
    var responseJSON = {
      'response_type':'login',
      'response_body':'ok'
    };
    response..writeln(jsonEncode(responseJSON))..close();

  }
  print(request.uri);  
}