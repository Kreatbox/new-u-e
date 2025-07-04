import 'dart:convert';

String xorEncrypt(String text, String key) {
  var encrypted = <int>[];
  for (int i = 0; i < text.length; i++) {
    encrypted.add(text.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
  }
  return base64.encode(encrypted);
}

String xorDecrypt(String encrypted, String key) {
  final decoded = base64.decode(encrypted);
  final chars = <int>[];
  for (int i = 0; i < decoded.length; i++) {
    chars.add(decoded[i] ^ key.codeUnitAt(i % key.length));
  }
  return String.fromCharCodes(chars);
}
