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
  /// Example usage:
  ///
  /// ```sh
  /// flutter run --dart-define lvVersion=0.0.0.0
  /// ```
  ///
  String _version = const String.fromEnvironment('lvVersion');

  /// Defined project version.
  ///
  String get version {
    if (_version.isEmpty) _version = '0.0.0.0';
    return _version;
  }

  /// Defines whether binary assets should be updated on the current build, and the old one removed.
  ///
  /// Example usage:
  ///
  /// ```sh
  /// flutter run --dart-define lvBinAssetUpdate=true
  /// ```
  ///
  bool binAssetUpdate = const String.fromEnvironment('lvBinAssetUpdate').toLowerCase() == 'true';

  /// Allocates the application runtime resources.
  ///
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await LvServiceDatabase.instance.init();
    await LvServiceCache.instance.init();
    await LvServicePythonRuntime.instance.init();
  }
}
