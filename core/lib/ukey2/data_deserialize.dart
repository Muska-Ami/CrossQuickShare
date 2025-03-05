import 'package:proto_lib/ukey.pb.dart';
import 'dart:typed_data';

class DataDeserialize {
  /// 反序列化 ClientInit 消息
  static Ukey2ClientInitResult deserializeClientInit(Uint8List byteBuffer) {
    Ukey2Message ukey2message;
    try {
      ukey2message = Ukey2Message.fromBuffer(byteBuffer);
    } catch (e) {
      final alert = Ukey2Alert(type: Ukey2Alert_AlertType.BAD_MESSAGE);
      return Ukey2ClientInitResult(alert: alert);
    }
    if (ukey2message.messageType != Ukey2Message_Type.CLIENT_INIT) {
      final alert = Ukey2Alert(type: Ukey2Alert_AlertType.BAD_MESSAGE_TYPE);
      return Ukey2ClientInitResult(alert: alert);
    }

    Ukey2ClientInit clientInit;
    try {
      clientInit = Ukey2ClientInit.fromBuffer(ukey2message.messageData);
    } catch (e) {
      final alert = Ukey2Alert(type: Ukey2Alert_AlertType.BAD_MESSAGE_DATA);
      return Ukey2ClientInitResult(alert: alert);
    }

    if (clientInit.version != 1) {
      final alert = Ukey2Alert(type: Ukey2Alert_AlertType.BAD_VERSION);
      return Ukey2ClientInitResult(alert: alert);
    }
    if (clientInit.random.length != 32) {
      final alert = Ukey2Alert(type: Ukey2Alert_AlertType.BAD_RANDOM);
      return Ukey2ClientInitResult(alert: alert);
    }
    for (var cipher in clientInit.cipherCommitments) {
      switch (cipher.handshakeCipher) {
        case Ukey2HandshakeCipher.P256_SHA512:
          break;
        default:
          final alert = Ukey2Alert(
            type: Ukey2Alert_AlertType.BAD_HANDSHAKE_CIPHER,
          );
          return Ukey2ClientInitResult(alert: alert);
      }
    }
    if (clientInit.nextProtocol != "AES_256_CBC-HMAC_SHA256") {
      final alert = Ukey2Alert(type: Ukey2Alert_AlertType.BAD_NEXT_PROTOCOL);
      return Ukey2ClientInitResult(alert: alert);
    }

    return Ukey2ClientInitResult(clientInit: clientInit);
  }

  /// 反序列化 ClientFinished 消息
  static Ukey2ClientFinishedResult deserializeClientFinished(
    Uint8List byteBuffer,
  ) {
    Ukey2Message ukey2message;
    try {
      ukey2message = Ukey2Message.fromBuffer(byteBuffer);
    } catch (e) {
      return Ukey2ClientFinishedResult(error: true);
    }
    if (ukey2message.messageType != Ukey2Message_Type.CLIENT_FINISH) {
      return Ukey2ClientFinishedResult(error: true);
    }

    final clientFinished = Ukey2ClientFinished.fromBuffer(
      ukey2message.messageData,
    );

    return Ukey2ClientFinishedResult(clientFinished: clientFinished);
  }
}

class Ukey2ClientInitResult {
  Ukey2ClientInitResult({this.clientInit, this.alert});

  Ukey2ClientInit? clientInit;
  Ukey2Alert? alert;
}

class Ukey2ClientFinishedResult {
  Ukey2ClientFinishedResult({this.clientFinished, this.error = false});

  Ukey2ClientFinished? clientFinished;
  bool error;
}
