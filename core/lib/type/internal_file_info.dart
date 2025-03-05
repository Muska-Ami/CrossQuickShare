import 'package:proto_lib/wire_format.pb.dart';

abstract class InternalFileInfo {
  InternalFileInfo({
    required this.fileMetadata,
    required this.payloadId,
    required this.destinationUrl,
  });
  FileMetadata fileMetadata;
  int payloadId;
  Uri destinationUrl;
}