import 'dart:convert';

String toUnicodeString(String s) {
  return utf8.decode(s.runes.toList());
}
