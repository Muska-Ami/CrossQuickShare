import 'dart:convert';

import 'package:nsd/nsd.dart' as nsd;

class Register {

  Future<nsd.Registration> register(String name, String data, int port) async {
    return await nsd.register(
        nsd.Service(
          name: name,
          type: '_FC9F5ED42C8A._tcp',
          port: port,
          txt: {
            'n': utf8.encode(data),
          }
        ),
    );
  }

  Future<void> unregister(nsd.Registration registration) async {
    await nsd.unregister(registration);
  }

}