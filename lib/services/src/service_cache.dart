import 'package:generic_shop_app_architecture/gsar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache service implemented for storage, retrieval and manipulation of simple key-value pair data.
///
class LvServiceCache extends GsaService {
  LvServiceCache._();

  /// Globally-accessible class instance.
  ///
  static final instance = LvServiceCache._();

  /// Package service providing a persistent store for simple data.
  ///
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    await super.init();
    _prefs = await SharedPreferences.getInstance();
  }

  /// Saves a boolean [value] to persistent storage in the background.
  ///
  Future<void> setBool(
    String key,
    bool value,
  ) async {
    await _prefs.setBool(key, value);
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a bool.
  ///
  bool? getBool(
    String key,
  ) {
    return _prefs.getBool(key);
  }

  /// Saves a string [value] to persistent storage in the background.
  ///
  Future<void> setString(
    String key,
    String value,
  ) async {
    await _prefs.setString(key, value);
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a String.
  ///
  String? getString(
    String key,
  ) {
    return _prefs.getString(key);
  }

  /// Saves an integer [value] to persistent storage in the background.
  ///
  Future<void> setInt(
    String key,
    int value,
  ) async {
    await _prefs.setInt(key, value);
  }

  /// Reads a value from persistent storage, throwing an exception if it's not an int.
  ///
  int? getInt(
    String key,
  ) {
    return _prefs.getInt(key);
  }

  /// Removes an entry from persistent storage.
  ///
  Future<void> remove(
    String key,
  ) async {
    await _prefs.remove(key);
  }
}
