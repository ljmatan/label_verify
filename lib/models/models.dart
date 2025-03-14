export 'src/model_db_document.dart';
export 'src/model_db_document_category.dart';
export 'src/model_db_document_review_configuration.dart';
export 'src/model_db_document_revision.dart';

/// Base model class with common / shared methods and properties.
///
abstract class LvModel {
  /// Default class constructor.
  ///
  LvModel({
    this.id,
  });

  /// Unique identifier assigned to this object or any of it's subclass instances.
  ///
  final String? id;

  /// Converts this object instance to a JSON map.
  ///
  Map<String, dynamic> toJson();
}
