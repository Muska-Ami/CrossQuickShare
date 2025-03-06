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
    print(
      'Incoming client: ${client.remoteAddress.address}:${client.remotePort}',
    );
    connection = NearbyConnection(
      id: uuid.v4(),
      connection: SocketConnection(socket: client),
      handleUkey2Connection: _handleUkey2Connection,
      handleConnection: _handleConnection,
    );
    connection!.startListen();
  }

  void _handleUkey2Connection(ConnectionState? state, Uint8List data) async {
    assert(connection != null, 'Connection not defined.');

    switch (state) {
      case null:
      case ConnectionState.sentUkeyServerInit:
        await _handleUkey2handshake(state, data);
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
        _handleReceivedConnectionRequest(data);
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
    print('Offline frame: ${frame.toProto3Json()}');
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

  /// 连接请求
  void _handleReceivedConnectionRequest(Uint8List data) {
    print('Connection establishing');
  }

  /// Ukey2 握手处理
  Future<void> _handleUkey2handshake(
    ConnectionState? state,
    Uint8List data,
  ) async {
    final message = DataDeserialize.deserializeMessage(data);
    if (message == null) {
      // 无效消息
      connection!.closeSocket();
      return;
    }
    final Uint8List bytes = Uint8List.fromList(message.messageData);
    switch (message.messageType) {
      case Ukey2Message_Type.ALERT:

        /// 警告
        final alert = Ukey2Alert.fromBuffer(bytes);
        print('Received an alert: ${alert.toProto3Json()}');
        break;
      case Ukey2Message_Type.CLIENT_FINISH:

        /// Client Finished
        // 状态不匹配，拒绝无效的消息
        if (state != ConnectionState.sentUkeyServerInit) {
          connection!.closeSocket();
          return;
        }
        final clientFinishedParsed = DataDeserialize.deserializeClientFinished(
          data,
        );
        if (clientFinishedParsed.error) {
          connection!.closeSocket();
          return;
        }
        print('Client finished.');
        connection!.clientFinished = clientFinishedParsed.clientFinished;
        connection!.state = ConnectionState.receivedUkeyClientFinish;
        break;
      case Ukey2Message_Type.CLIENT_INIT:

        /// Client Init
        final clientInitParsed = DataDeserialize.deserializeClientInit(bytes);
        print(
          'client init: ${clientInitParsed.clientInit?.toProto3Json()}, alert: ${clientInitParsed.alert?.toProto3Json()}',
        );
        if (clientInitParsed.alert != null) {
          await connection!.sendFrame(clientInitParsed.alert!.writeToBuffer());
          return;
        }
        connection!.clientInit = clientInitParsed.clientInit;
        final ec = getP256();
        final privateKey = ec.generatePrivateKey();
        final publicKey = privateKey.publicKey;

        connection!.ukey2data = Ukey2Data(
          publicKey: Crypto.hexToBytes(publicKey.toHex()),
          privateKey: Crypto.hexToBytes(privateKey.toHex()),
        );

        // 构造 Server Init 返回
        final serverInit = Ukey2ServerInit(
          version: 1,
          random: Generator.generateRandomBytes(32),
          publicKey: connection!.ukey2data!.publicKey,
          handshakeCipher: Ukey2HandshakeCipher.P256_SHA512,
        );
        connection!.serverInit = serverInit;
        print('Send server init: ${serverInit.toProto3Json()}');
        final message = Ukey2Message(
          messageType: Ukey2Message_Type.SERVER_INIT,
          messageData: serverInit.writeToBuffer(),
        );
        await connection!.sendFrame(message.writeToBuffer());
        connection!.state = ConnectionState.sentUkeyServerInit;
        break;
      default:
        // 无效状态
        connection!.closeSocket();
        return;
    }
  }
}
