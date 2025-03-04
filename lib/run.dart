import 'package:core/multicast/discover.dart';
import 'package:core/multicast/register.dart';
import 'package:core/utils/generator.dart';
import 'package:nsd/nsd.dart';

class Run {

  final Register _register = Register();
  final Discover _discover = Discover();

  Future<Registration> startCast(String str4L) async {
    return await _register.register(
      Generator.generateServiceID(str4L),
      Generator.generateServiceTXTData('Ami\'s PC Test', 3),
      11451,
    );
  }

  void stopCast(Registration reg) async {
    _register.unregister(reg);
  }

}