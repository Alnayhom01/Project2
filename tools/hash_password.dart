import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main(List<String> args) {
  if (args.length != 1 || args.first.trim().isEmpty) {
    stderr.writeln('Usage: dart run tools/hash_password.dart "YourPassword"');
    exitCode = 64;
    return;
  }

  final password = args.first;
  final hash = sha256.convert(utf8.encode(password)).toString();
  stdout.writeln(hash);
}
