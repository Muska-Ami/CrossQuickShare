import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class Crypto {
  static final int kHashModulo = 9973;
  static final int kHashBaseMultiplier = 31;

  static Uint8List hkdfSha256(
    Uint8List inputKeyMaterial,
    Uint8List salt,
    String info,
    int length,
  ) {
    var hmac = Hmac(sha256, inputKeyMaterial);
    var prk = hmac.convert(salt + info.codeUnits).bytes;
    var output = HkdfExtract(prk).expand(length); // 扩展为所需长度的密钥
    return output;
  }

  static Uint8List hexToBytes(String hex) {
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  static String toFourDigitString(List<int> bytes) {
    int hash = 0;
    int multiplier = 1;

    // 遍历字节数组，计算哈希值
    for (int byte in bytes) {
      // 计算当前字节对哈希值的影响
      hash = (hash + (byte.toSigned(8) * multiplier)) % kHashModulo;
      // 更新乘数
      multiplier = (multiplier * kHashBaseMultiplier) % kHashModulo;
    }

    return (hash.abs()).toString().padLeft(4, '0');
  }
}

class HkdfExtract {
  final List<int> prk; // 提取的密钥材料

  HkdfExtract(this.prk);

  // 扩展为指定长度的密钥
  Uint8List expand(int length) {
    var result = <int>[];
    var block = <int>[];
    int remainingLength = length;
    int blockIndex = 1;

    // 扩展过程
    while (remainingLength > 0) {
      var hmac = Hmac(sha256, prk);
      var output = hmac.convert(block + [blockIndex]).bytes;
      block = output;
      result.addAll(output);
      remainingLength -= output.length;
      blockIndex++;
    }

    return Uint8List.fromList(result.sublist(0, length));
  }
}
