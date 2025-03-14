import 'dart:convert' as dart_convert;
import 'dart:io' as dart_io;
import 'dart:typed_data' as dart_typed_data;

/// Model class representing document database format.
///
class LvModelDocument {
  /// Default, unnamed constructor.
  ///
  LvModelDocument({
    required this.id,
    required this.categoryId,
    required this.label,
    required this.fileName,
    required this.fileType,
    required this.filePath,
    required this.fileImageDisplayPaths,
    required this.createdAt,
    required this.lastUpdated,
  });

  /// Document identifier generated by the SQL database.
  ///
  int id;

  /// Optional document category identifier.
  ///
  String? categoryId;

  /// Document display name.
  ///
  String label;

  /// Document file name.
  ///
  String fileName;

  /// Document file type or file extension.
  ///
  String fileType;

  /// Path of the representation in byte format.
  ///
  String filePath;

  /// Private class property used for storing of the file contents after loading.
  ///
  dart_typed_data.Uint8List? _fileBytes;

  /// Function used for fetching file contents in the form of unsigned 8-bit integer list.
  ///
  Future<dart_typed_data.Uint8List> fileBytes() async {
    _fileBytes ??= await dart_io.File(filePath).readAsBytes();
    return _fileBytes!;
  }

  /// Path of the converted image display of document contents.
  ///
  List<String> fileImageDisplayPaths;

  /// The number of pages available with the document.
  ///
  int get pages => fileImageDisplayPaths.length;

  /// Private class property used for storing of the file image display contents after loading.
  ///
  List<dart_typed_data.Uint8List>? _fileImageDisplays;

  /// Function used for fetching file image display contents in the form of unsigned 8-bit integer list.
  ///
  Future<List<dart_typed_data.Uint8List>> getFileImageDisplays() async {
    _fileImageDisplays ??= await Future.wait(
      [
        for (final imageDisplayPath in fileImageDisplayPaths) dart_io.File(imageDisplayPath).readAsBytes(),
      ],
    );
    return _fileImageDisplays!;
  }

  /// Time of the document creation.
  ///
  DateTime createdAt;

  /// Time the document has last been updated with a new revision.
  ///
  DateTime? lastUpdated;

  /// Factory constructor used to generate a class instance from database data format.
  ///
  factory LvModelDocument.fromJson(Map<String, dynamic> json) {
    return LvModelDocument(
      id: json['id'],
      categoryId: json['categoryId'],
      label: json['label'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      filePath: json['filePath'],
      fileImageDisplayPaths: List<String>.from(
        dart_convert.jsonDecode(
          json['fileImageDisplayPaths'],
        ),
      ),
      createdAt: DateTime.parse(
        json['createdAtIso8601'],
      ),
      lastUpdated: json['lastUpdatedIso8601'] is String
          ? DateTime.parse(
              json['lastUpdatedIso8601'],
            )
          : null,
    );
  }

  /// Method used for generating data in the database format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'label': label,
      'fileName': fileName,
      'fileType': fileType,
      'filePath': filePath,
      'fileImageDisplayPaths': dart_convert.jsonEncode(
        fileImageDisplayPaths,
      ),
      'createdAtIso8601': createdAt.toIso8601String(),
      'lastUpdatedIso8601': lastUpdated?.toIso8601String(),
    };
  }
}
