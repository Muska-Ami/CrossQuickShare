import 'package:core/multicast/discover.dart';
import 'package:core/multicast/register.dart';
import 'package:core/server.dart';
import 'package:core/utils/generator.dart';
import 'package:nsd/nsd.dart';

class Run {

  final _server = Server();

  final Register _register = Register();
  final Discover _discover = Discover();

  Future<Registration> startCast(String str4L) async {
    final socket = await _server.listen(0);
    return await _register.register(
      Generator.generateServiceID(str4L),
      Generator.generateServiceTXTData('Ami\'s PC Test', 3),
      socket.port,
    );
  }

  void stopCast(Registration reg) async {
    _register.unregister(reg);
  }

}