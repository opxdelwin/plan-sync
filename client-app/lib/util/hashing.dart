import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

String genSortedHash(List data) {
  AccumulatorSink<Digest> sink = AccumulatorSink<Digest>();

  // Convert each sorted record to a string and hash it.
  var hash = sha256.startChunkedConversion(sink);

  for (var record in data) {
    String recordJson = jsonEncode(record);
    hash.add(utf8.encode(recordJson));
  }
  hash.close();
  return sink.events.single.toString();
}
