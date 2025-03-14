import 'package:flutter/material.dart';
import 'package:label_verify/services/services.dart';

/// Project configuration used during the runtime.
///
class LvConfig {
  LvConfig._();

  /// Globally-accessible singleton class instance.
  ///
  static final instance = LvConfig._();

  /// Property holding the value to the defined project version.
  ///
  String _version = const String.fromEnvironment('lvVersion');

  /// Defined project version.
  ///
  String get version {
    if (_version.isEmpty) _version = '0.0.0.0';
    return _version;
  }

  /// Allocates the application runtime resources.
  ///
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await LvServiceDatabase.instance.init();
  }
}
