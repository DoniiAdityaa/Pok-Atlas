// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env
final class _Env {
  static const List<int> _enviedkeyapiKey = <int>[
    2042069530,
    2399321928,
  ];

  static const List<int> _envieddataapiKey = <int>[
    2042069560,
    2399321962,
  ];

  static final String apiKey = String.fromCharCodes(List<int>.generate(
    _envieddataapiKey.length,
    (int i) => i,
    growable: false,
  ).map((int i) => _envieddataapiKey[i] ^ _enviedkeyapiKey[i]));
}
