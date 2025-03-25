import 'package:generic_shop_app_architecture/gsar.dart';
import 'package:label_verify/models/src/model_db_document.dart';
import 'package:label_verify/models/src/model_db_document_category.dart';
import 'package:label_verify/models/src/model_db_document_review_configuration.dart';
import 'package:label_verify/models/src/model_db_document_revision.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

/// Device memory database storage service.
///
class LvServiceDatabase extends GsaService {
  LvServiceDatabase._();

  /// Globally-accessible class instance.
  ///
  static final instance = LvServiceDatabase._();

  /// [sqflite_ffi.Database] property provided by the
  /// [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) package.
  ///
  late sqflite_ffi.Database db;

  /// Database table identifiers.
  ///
  final _documentTableId = 'Documents',
      _documentCategoryTableId = 'DocumentCategories',
      _documentReviewConfigurationTableId = 'DocumentReviewConfiguration',
      _documentRevisionsTableId = 'DocumentRevisions';

  /// Allocates the database runtime resources.
  ///
  @override
  Future<void> init() async {
    await super.init();
    sqflite_ffi.sqfliteFfiInit();
    final databaseFactory = sqflite_ffi.databaseFactoryFfi;
    final appDocumentsDir = await path_provider.getApplicationSupportDirectory();
    final dbPath = path.join(appDocumentsDir.path, 'databases', 'labelverify.db');
    db = await databaseFactory.openDatabase(dbPath);
    for (final table in <String>{
      _documentTableId,
      _documentCategoryTableId,
      _documentReviewConfigurationTableId,
      _documentRevisionsTableId,
    }) {
      try {
        // await db.delete(table);
      } catch (e) {
        // Do nothing.
      }
    }
    for (final query in <String>{
      '''
      CREATE TABLE $_documentTableId (
          id INTEGER PRIMARY KEY,
          categoryId INTEGER,
          label TEXT,
          fileName TEXT,
          fileType TEXT,
          filePath TEXT,
          fileImageDisplayPaths TEXT,
          createdAtIso8601 TEXT,
          lastUpdatedIso8601 TEXT
      )
      ''',
      '''
      CREATE TABLE $_documentCategoryTableId (
          id INTEGER PRIMARY KEY,
          title TEXT
      )
      ''',
      '''
      CREATE TABLE $_documentReviewConfigurationTableId (
          id INTEGER PRIMARY KEY,
          documentId INTEGER,
          page INTEGER,
          label TEXT,
          description TEXT,
          type TEXT,
          positionStartPercentX INTEGER,
          positionStartPercentY INTEGER,
          positionEndPercentX INTEGER,
          positionEndPercentY INTEGER
      )
      ''',
      '''
      CREATE TABLE $_documentRevisionsTableId (
          id INTEGER PRIMARY KEY,
          documentId INTEGER,
          createdAtIso8601 TEXT,
          filePath TEXT,
          fileImageDisplayPaths TEXT
      )
      ''',
    }) {
      try {
        await db.execute(query);
      } catch (e) {
        // debugPrint('Error executing query: $e\n$query');
      }
    }
  }
}

/// Extension methods for the database document retrieval and manipulation.
///
extension LvServiceDatabaseDocumentQueries on LvServiceDatabase {
  /// Inserts a database document record, returning the new value identifier.
  ///
  Future<int> insertDocument(
    LvModelDocument document,
  ) async {
    final id = await db.insert(
      _documentTableId,
      document.toJson()..['id'] = null,
    );
    document.id = id;
    return id;
  }

  /// Removes a document with a specified [documentId].
  ///
  /// Returns the number of rows affected.
  ///
  Future<int> removeDocument(
    int documentId,
  ) async {
    return await db.delete(
      _documentTableId,
      where: 'id = ?',
      whereArgs: [
        documentId,
      ],
    );
  }

  /// Updates a database record of a document with provided [document.id] value.
  ///
  Future<int> updateDocument(
    LvModelDocument document,
  ) async {
    return await db.update(
      _documentTableId,
      document.toJson(),
      where: 'id = ?',
      whereArgs: [
        document.id,
      ],
    );
  }

  /// Fetches the complete document list available on this device.
  ///
  Future<List<LvModelDocument>> getAllDocuments() async {
    final dbData = await db.query(
      _documentTableId,
    );
    return dbData
        .map(
          (data) => LvModelDocument.fromJson(data),
        )
        .toList();
  }

  /// Returns the list of documents for the specified [categoryId].
  ///
  Future<List<LvModelDocument>> getDocumentsForCategory(
    int categoryId,
  ) async {
    final dbData = await db.query(
      _documentTableId,
      where: 'categoryId = ?',
      whereArgs: [
        categoryId,
      ],
    );
    return dbData
        .map(
          (data) => LvModelDocument.fromJson(data),
        )
        .toList();
  }
}

/// Extension methods for the database document category retrieval and manipulation.
///
extension LvServiceDatabaseDocumentCategoryQueries on LvServiceDatabase {
  /// Inserts a database document category record, returning the new value identifier.
  ///
  Future<int> insertDocumentCategory(
    LvModelDocumentCategory documentCategory,
  ) async {
    final id = await db.insert(
      _documentCategoryTableId,
      documentCategory.toJson()..['id'] = null,
    );
    documentCategory.id = id;
    return id;
  }

  /// Removes a document category with a specified [documentCategoryId].
  ///
  /// Returns the number of rows affected.
  ///
  Future<int> removeDocumentCategory(
    int documentCategoryId,
  ) async {
    return await db.delete(
      _documentCategoryTableId,
      where: 'id = ?',
      whereArgs: [
        documentCategoryId,
      ],
    );
  }

  /// Updates a database record of a document category with provided [documentCategory.id] value.
  ///
  Future<int> updateDocumentCategory(
    LvModelDocumentCategory documentCategory,
  ) async {
    return await db.update(
      _documentCategoryTableId,
      documentCategory.toJson(),
      where: 'id = ?',
      whereArgs: [
        documentCategory.id,
      ],
    );
  }

  /// Fetches the complete document category list available on this device.
  ///
  Future<List<LvModelDocumentCategory>> getAllDocumentCategories() async {
    final dbData = await db.query(
      _documentCategoryTableId,
    );
    return dbData
        .map(
          (data) => LvModelDocumentCategory.fromJson(data),
        )
        .toList();
  }
}

/// Extension methods for the database document review configuration retrieval and manipulation.
///
extension LvServiceDatabaseDocumentReviewConfiguration on LvServiceDatabase {
  /// Inserts a database document review configuration record, returning the new value identifier.
  ///
  Future<void> insertDocumentReviewConfiguration(
    List<LvModelDocumentReviewConfiguration> documentReviewConfiguration,
  ) async {
    for (final reviewConfig in documentReviewConfiguration) {
      final id = await db.insert(
        _documentReviewConfigurationTableId,
        reviewConfig.toJson()..['id'] = null,
      );
      reviewConfig.id = id;
    }
  }

  /// Removes a document review configuration with a specified [documentReviewConfigurationId].
  ///
  /// Returns the number of rows affected.
  ///
  Future<int> removeDocumentReviewConfiguration(
    int documentId,
  ) async {
    return await db.delete(
      _documentReviewConfigurationTableId,
      where: 'documentId = ?',
      whereArgs: [
        documentId,
      ],
    );
  }

  /// Updates a database record of a document review configuration with provided [documentReviewConfiguration.id] value.
  ///
  Future<int> updateDocumentReviewConfiguration(
    LvModelDocumentReviewConfiguration documentReviewConfiguration,
  ) async {
    return await db.update(
      _documentReviewConfigurationTableId,
      documentReviewConfiguration.toJson(),
      where: 'id = ?',
      whereArgs: [
        documentReviewConfiguration.id,
      ],
    );
  }

  /// Fetches the complete document review configuration list available on this device.
  ///
  Future<List<LvModelDocumentReviewConfiguration>> getAllDocumentReviewConfigurations() async {
    final dbData = await db.query(
      _documentReviewConfigurationTableId,
    );
    return dbData
        .map(
          (data) => LvModelDocumentReviewConfiguration.fromJson(data),
        )
        .toList();
  }

  /// Fetches the complete document review configuration list available on this device.
  ///
  Future<List<LvModelDocumentReviewConfiguration>> getDocumentReviewConfigurationsForId(
    int documentId,
  ) async {
    final dbData = await db.query(
      _documentReviewConfigurationTableId,
      where: 'documentId = ?',
      whereArgs: [
        documentId,
      ],
    );
    return dbData
        .map(
          (data) => LvModelDocumentReviewConfiguration.fromJson(data),
        )
        .toList();
  }
}

/// Extension methods for the database document revision retrieval and manipulation.
///
extension LvServiceDatabaseDocumentRevisionQueries on LvServiceDatabase {
  /// Inserts a database document revision record, returning the new value identifier.
  ///
  Future<int> insertDocumentRevision(
    LvModelDocumentRevision documentRevision,
  ) async {
    final id = await db.insert(
      _documentRevisionsTableId,
      documentRevision.toJson()..['id'] = null,
    );
    documentRevision.id = id;
    return id;
  }

  /// Removes a document revision with a specified [documentRevisionId].
  ///
  /// Returns the number of rows affected.
  ///
  Future<int> removeDocumentRevision(
    int documentRevisionId,
  ) async {
    return await db.delete(
      _documentRevisionsTableId,
      where: 'id = ?',
      whereArgs: [
        documentRevisionId,
      ],
    );
  }

  /// Updates a database record of a document revisions with provided [documentRevision.id] value.
  ///
  Future<int> updateDocumentRevisions(
    LvModelDocumentRevision documentRevision,
  ) async {
    return await db.update(
      _documentRevisionsTableId,
      documentRevision.toJson(),
      where: 'id = ?',
      whereArgs: [
        documentRevision.id,
      ],
    );
  }

  /// Fetches the complete document revision list available on this device.
  ///
  Future<List<LvModelDocumentRevision>> getAllDocumentRevisions() async {
    final dbData = await db.query(
      _documentRevisionsTableId,
    );
    return dbData
        .map(
          (data) => LvModelDocumentRevision.fromJson(data),
        )
        .toList();
  }

  /// Fetches the complete document revision list available for a specific document.
  ///
  Future<List<LvModelDocumentRevision>> getDocumentRevisionsForId(int documentId) async {
    final dbData = await db.query(
      _documentRevisionsTableId,
      where: 'documentId = ?',
      whereArgs: [
        documentId,
      ],
    );
    return dbData
        .map(
          (data) => LvModelDocumentRevision.fromJson(data),
        )
        .toList();
  }
}
