import 'package:dart_amqp/dart_amqp.dart';

class AMQPWrapper {
  ConnectionSettings _settings;
  Client _client;


  AMQPWrapper(String host, int port, String user, String password) {

    _settings = new ConnectionSettings(
      host: host,
      port: port,
      authProvider: new PlainAuthenticator(user, password)
    );

    _client = new Client(settings: _settings);
  }

  void connectAndListen() {
    _client.channel()
    .then( (Channel channel) => channel.queue(""))
    .then( (Queue queue) => queue.consume())
    .then( (Consumer consumer) => consumer.listen(
      (AmqpMessage message) {
        print(message);
      }
    ));
  }

}
