import 'package:nsd/nsd.dart';

class Discover {

  static Discovery? discovery;

  Future<void> start() async {
    discovery = await startDiscovery('_FC9F5ED42C8A._tcp');
  }

  Future<void> addListener(Function(Discovery) fn) async {
    return discovery!.addListener(() => fn(discovery!));
  }

  Future<void> stop() async {
    if (discovery != null) await stopDiscovery(discovery!);
  }

}