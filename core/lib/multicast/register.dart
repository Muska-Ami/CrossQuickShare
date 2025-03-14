import 'package:bonsoir/bonsoir.dart';

class Register {
  Future<BonsoirBroadcast> register(String name, String data, int port) async {
    final service = BonsoirService(
      name: name,
      type: '_FC9F5ED42C8A._tcp',
      port: port,
      attributes: {'n': data},
    );
    final broadcast = BonsoirBroadcast(service: service);
    await broadcast.ready;
    await broadcast.start();
    return broadcast;
  }

  Future<void> unregister(BonsoirBroadcast registration) async {
    await registration.stop();
  }
}
