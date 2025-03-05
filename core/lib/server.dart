import 'dart:io';
import 'dart:typed_data';

import 'package:core/type/device_type.dart';
import 'package:core/type/nearby_connection.dart';
import 'package:core/ukey2/data_deserialize.dart';
import 'package:core/utils/crypto.dart';
import 'package:core/utils/generator.dart';
import 'package:elliptic/elliptic.dart';
import 'package:proto_lib/offline_wire_formats.pb.dart';
import 'package:proto_lib/ukey.pb.dart';
import 'package:uuid/uuid.dart';

class Server {
  static NearbyConnection? connection;
  final uuid = Uuid();

  Future<ServerSocket> listen(int port) async {
    ServerSocket server = await ServerSocket.bind('0.0.0.0', port);
    server.listen(
      _onData,
      onError: (e) {
        throw e;
      },
    );
    print('Listening on ${server.address.address}:${server.port}');
    return server;
  }

  void _onData(Socket client) async {
    print('Received data, client: ${client.remoteAddress.address}:${client.remotePort}');
    connection = NearbyConnection(
      id: uuid.v4(),
      connection: SocketConnection(socket: client),
      handleUkey2Connection: _handleUkey2Connection,
      handleConnection: _handleConnection,
    );
  }

  void _handleUkey2Connection(ConnectionState? state, Uint8List data) async {
    assert(connection != null, 'Connection not defined.');

    switch (state) {
      case null:
        final clientInitParsed = DataDeserialize.deserializeClientInit(data);
        if (clientInitParsed.alert != null) {
          connection!.closeSocket(ukey2alert: clientInitParsed.alert);
          return;
        }
        connection!.clientInit = clientInitParsed.clientInit;
        final ec = getP256();
        final privateKey = ec.generatePrivateKey();
        final publicKey = privateKey.publicKey;

        connection!.ukey2data = Ukey2Data(
          publicKey: Crypto.hexToBytes('0x$publicKey'),
          privateKey: Crypto.hexToBytes('0x$privateKey'),
        );

        final serverInit = Ukey2ServerInit(
          version: 1,
          random: Generator.generateRandomBytes(32),
          publicKey: connection!.ukey2data!.publicKey,
          handshakeCipher: Ukey2HandshakeCipher.P256_SHA512,
        );
        connection!.serverInit = serverInit;
        connection!.sendFrame(serverInit);
        connection!.state = ConnectionState.sentUkeyServerInit;
        break;
      case ConnectionState.sentUkeyServerInit:
        final clientFinishedParsed = DataDeserialize.deserializeClientFinished(
          data,
        );
        if (clientFinishedParsed.error) {
          connection!.closeSocket();
          return;
        }
        break;
      default:
        throw UnimplementedError();
    }
  }

  void _handleConnection(ConnectionState state, Uint8List data) {
    assert(connection != null, 'Connection not defined.');

    switch (state) {
      case ConnectionState.initial:
        _handleInitialData(data);
      case ConnectionState.receivedConnectionRequest:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ConnectionState.sentConnectionResponse:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ConnectionState.sentPairedKeyResult:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ConnectionState.receivedPairedKeyResult:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ConnectionState.waitingForUserConsent:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ConnectionState.receivingFiles:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ConnectionState.disconnected:
        connection!.closeSocket();
      default:
        throw UnimplementedError();
    }
  }

  /// 连接初始化
  void _handleInitialData(Uint8List data) {
    final frame = OfflineFrame.fromBuffer(data);
    if (!(frame.v1.hasConnectionRequest() &&
        frame.v1.connectionRequest.hasEndpointInfo())) {
      throw UnimplementedError('Wrong connection request data.');
    }
    if (frame.v1.type != V1Frame_FrameType.CONNECTION_REQUEST) {
      throw UnimplementedError('Unexpected connection frame type.');
    }
    final endpointInfo = frame.v1.connectionRequest.endpointInfo;
    if (endpointInfo.length <= 17) {
      throw ArgumentError('Endpoint info too short.');
    }
    final deviceNameLength = endpointInfo[17];
    if (endpointInfo.length < deviceNameLength + 18) {
      throw ArgumentError('Endpoint info too short to contain the device name');
    }
    final deviceName = String.fromCharCodes(
      endpointInfo.sublist(18, 18 + deviceNameLength),
    );
    if (deviceName.isEmpty) {
      throw ArgumentError('Device name is not valid UTF-8 text.');
    }
    final rawDeviceType = (endpointInfo[0] & 7) >> 1;
    connection!.deviceInfo = RemoteDeviceInfo(
      name: deviceName,
      type: DeviceType.fromValue(rawDeviceType),
    );
    connection!.state = ConnectionState.receivedConnectionRequest;
  }

  ///
}
