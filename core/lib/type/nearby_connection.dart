import 'dart:io';
import 'dart:typed_data';

import 'package:core/type/device_type.dart';
import 'package:core/type/internal_file_info.dart';
import 'package:proto_lib/ukey.pb.dart';

class NearbyConnection {
  NearbyConnection({
    required this.id,
    required this.connection,
    required this.handleConnection,
    required this.handleUkey2Connection,
  });

  ConnectionState? state;

  String id;
  SocketConnection connection;
  bool encryptionDone = false;
  List<InternalFileInfo>? transferredFiles;

  Ukey2ClientInit? clientInit;
  Ukey2ServerInit? serverInit;
  Ukey2ClientFinished? clientFinished;

  Ukey2Data? ukey2data;

  RemoteDeviceInfo? deviceInfo;

  Function(ConnectionState? state, Uint8List data) handleUkey2Connection;
  Function(ConnectionState state, Uint8List data) handleConnection;

  void closeSocket({Ukey2Alert? ukey2alert}) {
    if (ukey2alert != null) connection.socket.write(ukey2alert);
    connection.socket.close();
    connection.closed = true;
  }

  void startListen() => connection.socket.listen((Uint8List data) {
    print('Current state: ${state?.name ?? 'No state'}');
    switch (state) {
      case null:
      case ConnectionState.sentUkeyServerInit:
      case ConnectionState.receivedUkeyClientFinish:
        handleUkey2Connection(state, data);
        break;
      default:
        handleConnection(state!, data);
    }
  });

  Future<void> sendFrame(Uint8List data) async {
    if (connection.closed) return;
    int length = data.length;
    final lengthPrefixedData = BytesBuilder();

    lengthPrefixedData.add([
      (length >> 24) & 0xFF,
      (length >> 16) & 0xFF,
      (length >> 8) & 0xFF,
      length & 0xFF,
    ]);

    lengthPrefixedData.add(data);

    print('Send frame to client: ${lengthPrefixedData.toBytes()}');

    connection.socket.write(lengthPrefixedData.toBytes());
    connection.socket.flush();
  }
}

enum ConnectionState {
  initial,
  receivedConnectionRequest,
  sentUkeyServerInit,
  receivedUkeyClientFinish,
  sentConnectionResponse,
  sentPairedKeyResult,
  receivedPairedKeyResult,
  waitingForUserConsent,
  receivingFiles,
  disconnected,
}

class SocketConnection {
  SocketConnection({required this.socket, this.closed = false});

  Socket socket;
  bool closed;
}

class Ukey2Data {
  Ukey2Data({required this.publicKey, required this.privateKey});

  Uint8List publicKey;
  Uint8List privateKey;
}

class SecureMessageData {
  SecureMessageData({
    required this.decryptKey,
    required this.encryptKey,
    required this.receiveHmacKey,
    required this.sendHmacKey,
    this.serverSeq = 0,
    this.clientSeq = 0,
  });

  Uint8List decryptKey;
  Uint8List encryptKey;

  Uint8List receiveHmacKey;
  Uint8List sendHmacKey;

  int serverSeq;
  int clientSeq;
}

class RemoteDeviceInfo {
  RemoteDeviceInfo({required this.name, required this.type});
  String name;
  DeviceType type;
}
