import 'package:bonsoir/bonsoir.dart';

class Discover {
  static BonsoirDiscovery? discovery;

  Future<void> start() async {
    discovery = BonsoirDiscovery(type: '_FC9F5ED42C8A._tcp');
    await discovery!.ready;
    await discovery!.start();
  }

  Future<void> addListener(
    Function({
      BonsoirDiscoveryEventType type,
      BonsoirService service,
      BonsoirDiscovery discovery,
    })
    fn,
  ) async {
    discovery!.eventStream!.listen(
      (event) =>
          fn(type: event.type, service: event.service!, discovery: discovery!),
    );
  }

  Future<void> stop() async {
    if (discovery != null) await discovery!.stop();
  }
}
