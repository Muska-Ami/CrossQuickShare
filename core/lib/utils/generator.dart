import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class Generator {
  static String generateRandomString(int length) {
    final random = Random();
    const availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz'
        '1234567890';
    final randomString =
        List.generate(
          length,
          (index) => availableChars[random.nextInt(availableChars.length)],
        ).join();

    return randomString;
  }

  static List<int> generateRandomBytes(int length) {
    final random = Random.secure();
    List<int> bytes = List<int>.generate(length, (_) => random.nextInt(256));

    return bytes;
  }

  /// 生成服务标识
  /// @param randomStr4L 4位随机字符串
  static String generateServiceID(String randomStr4L) {
    if (randomStr4L.length != 4) {
      throw ArgumentError(
        'Random string length must be 4, but got ${randomStr4L.length}',
      );
    }
    // Define the byte sequence
    List<int> byteSequence = [
      0x23, // 1 byte
      ...utf8.encode(randomStr4L), // 4 bytes of random string,
      0xFC, 0x9F, 0x5E, // 3-byte service ID
      0x00, 0x00, // 2 zero bytes
    ];

    Uint8List byteArray = Uint8List.fromList(byteSequence);

    return base64Url.encode(byteArray);
  }

  /// 生成 TXT 记录内容
  /// @param deviceName 设备名称
  /// @param deviceType 设备类型
  static String generateServiceTXTData(String deviceName, int deviceType) {
    if (deviceName.length > 255) {
      throw ArgumentError('Device name length more than 255 character.');
    }

    int bitField = 0; // init 0
    bitField |= (0 << 5); // version 3 bits: 0
    bitField |= (0 << 4); // visibility 1 bit: 0 (visible)
    bitField |= (deviceType << 1); // device type 3 bits
    bitField |= (0 << 0); // reserved 1 bit: 0

    Random random = Random();
    List<int> unknownBytes = List.generate(16, (_) => random.nextInt(256));

    // 设备名称：前缀加上长度
    List<int> nameBytes = utf8.encode(deviceName);
    List<int> lengthPrefix = [nameBytes.length];

    // 组合所有部分
    List<int> byteSequence = [
      bitField, // bit field
      ...unknownBytes, // unknown bytes
      ...lengthPrefix, // prefix for device name
      ...nameBytes, // device name
    ];

    Uint8List byteArray = Uint8List.fromList(byteSequence);

    return base64Url.encode(byteArray);
  }

}
