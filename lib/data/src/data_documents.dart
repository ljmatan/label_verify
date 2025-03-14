import 'package:label_verify/data/data.dart';
import 'package:label_verify/models/models.dart';

/// Data class holding references and properties to the available document files.
///
class LvDataDocuments extends LvData {
  LvDataDocuments._();

  /// Globally-accessible singleton class instance.
  ///
  static final instance = LvDataDocuments._();

  /// Private object containing instances of the available documents.
  ///
  final _collection = <LvModelDocument>[];

  /// A list collection of available documents.
  ///
  List<LvModelDocument> get collection => _collection;

  /// Adds a new entry to the document [collection] and notifies any listeners.
  ///
  Future<void> documentAdd(List<LvModelDocument> documents) async {
    _collection.addAll(documents);
    notifyListeners();
  }

  /// Adds a new entry to the document [collection] and notifies any listeners.
  ///
  Future<void> documentRemove(LvModelDocument document) async {
    _collection.remove(document);
    notifyListeners();
  }

  /// Imports a data set from the user device.
  ///
  Future<void> dataImport() async {
    notifyListeners();
  }

  /// Exports all of the available document data to the user device.
  ///
  Future<void> dataExport() async {}
}
