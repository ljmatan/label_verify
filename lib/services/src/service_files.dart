import 'dart:convert' as dart_convert;
import 'dart:io' as dart_io;
import 'dart:math' as dart_math;

import 'package:flutter/foundation.dart';
import 'package:generic_shop_app_architecture/gsar.dart';
import 'package:label_verify/config.dart';
import 'package:label_verify/data/src/data_documents.dart';
import 'package:label_verify/main.dart';
import 'package:label_verify/models/models.dart';
import 'package:label_verify/services/src/service_conversion.dart';
import 'package:label_verify/view/src/common/dialogs/dialog_content_blocking.dart';
import 'package:collection/collection.dart' as collection;
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:file_saver/file_saver.dart' as file_saver;
import 'package:archive/archive.dart' as archive;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:printing/printing.dart';

/// Supported file type extensions.
///
enum LvServiceFilesExtensionTypes {
  txt,
  json,
  gz,
  zip,
  svg,
  pdf,
  png,
  jpg,
  jpeg,
  exec;

  String get filePathExtension {
    return '.$name';
  }
}

/// Available document upload type.
///
enum LvServiceFilesType {
  /// Previously-exported data submitted for import.
  ///
  importData,

  /// Document file submitted for later configuration and review.
  ///
  document;

  /// The type of file associated with the given content.
  ///
  Iterable<String> get allowedTypeIdentifiers {
    switch (this) {
      case LvServiceFilesType.importData:
        return {
          LvServiceFilesExtensionTypes.txt,
          LvServiceFilesExtensionTypes.json,
          LvServiceFilesExtensionTypes.gz,
          LvServiceFilesExtensionTypes.zip,
        }.map((value) => value.name);
      case LvServiceFilesType.document:
        return {
          LvServiceFilesExtensionTypes.svg,
          LvServiceFilesExtensionTypes.pdf,
          LvServiceFilesExtensionTypes.png,
          LvServiceFilesExtensionTypes.jpg,
          LvServiceFilesExtensionTypes.jpeg,
        }.map((value) => value.name);
    }
  }
}

/// Service implemented for uploading files from the local file system.
///
class LvServiceFiles extends GsaService {
  LvServiceFiles._();

  /// Globally-accessible singleton class instance.
  ///
  static final instance = LvServiceFiles._();

  /// Retrieves the file from the local file system.
  ///
  Future<
      ({
        Uint8List fileBytes,
        String fileName,
        LvServiceFilesExtensionTypes fileType,
        int pagesNumber,
      })?> getFile(
    LvServiceFilesType fileType,
  ) async {
    file_picker.FilePickerResult? result = await file_picker.FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      try {
        final file = dart_io.File(result.files.single.path!);
        final fileBytes = await file.readAsBytes();
        final fileName = path.basename(file.path);
        final fileExtension = path.extension(file.path).replaceAll('.', '');
        final fileExtensionType = LvServiceFilesExtensionTypes.values.firstWhereOrNull(
          (value) => value.name == fileExtension,
        );
        if (fileExtensionType == null) {
          throw UnimplementedError('File type $fileType not supported.');
        }
        final pagesNumber = fileExtensionType != LvServiceFilesExtensionTypes.pdf
            ? 1
            : await Printing.raster(
                fileBytes,
                dpi: 1,
              ).length;
        return (
          fileBytes: fileBytes,
          fileName: fileName,
          fileType: fileExtensionType,
          pagesNumber: pagesNumber,
        );
      } catch (e) {
        debugPrint('$e');
        return null;
      }
    } else {
      return null;
    }
  }

  /// Stores a single file to the device memory.
  ///
  Future<dart_io.File> storeStandaloneFile({
    required Uint8List fileBytes,
    required LvServiceFilesExtensionTypes fileType,
  }) async {
    String generateRandomFileName(int length) {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      dart_math.Random random = dart_math.Random();
      return String.fromCharCodes(
        List.generate(
          length,
          (index) => chars.codeUnitAt(
            random.nextInt(chars.length),
          ),
        ),
      );
    }

    // Setup the application support directory location.
    final appSupportDirectory = await path_provider.getApplicationSupportDirectory();
    if (!await appSupportDirectory.exists()) await appSupportDirectory.create(recursive: true);

    // Determine a valid filename.
    String fileName = generateRandomFileName(20) + fileType.filePathExtension;
    String filePath = path.join(appSupportDirectory.path, fileName);
    dart_io.File file = dart_io.File(filePath);
    while (await file.exists()) {
      fileName = generateRandomFileName(20) + fileType.filePathExtension;
      filePath = path.join(appSupportDirectory.path, fileName);
      file = dart_io.File(filePath);
    }

    // Store the file to the device memory.
    await file.writeAsBytes(fileBytes);

    if (!await file.exists()) {
      throw 'File not written successfully: ${file.path}';
    }

    return file;
  }

  /// Stores the specified [fileBytes] to a file of [fileType], returning the path of the newly-created file.
  ///
  Future<
      ({
        String filePath,
        List<String> fileImageDisplayPaths,
      })> storeFile({
    required Uint8List fileBytes,
    required LvServiceFilesExtensionTypes fileType,
  }) async {
    final file = await storeStandaloneFile(
      fileBytes: fileBytes,
      fileType: fileType,
    );

    // Set file image displays and their appropriate path values.
    final fileImageDisplayPaths = <String>{};

    if ({
      LvServiceFilesExtensionTypes.jpeg,
      LvServiceFilesExtensionTypes.jpg,
      LvServiceFilesExtensionTypes.png,
    }.contains(fileType)) {
      fileImageDisplayPaths.add(file.path);
    }
    if (fileType == LvServiceFilesExtensionTypes.svg) {
      final convertedFile = await LvServiceConversion.instance.convertSvgToPng(
        dart_convert.utf8.decode(
          fileBytes,
        ),
      );
      final storedConvertedFile = await storeStandaloneFile(
        fileBytes: convertedFile,
        fileType: fileType,
      );
      fileImageDisplayPaths.add(storedConvertedFile.path);
    }
    if (fileType == LvServiceFilesExtensionTypes.pdf) {
      final convertedFiles = await LvServiceConversion.instance.convertPdfToPng(
        fileBytes,
      );
      for (final convertedFile in convertedFiles) {
        final storedConvertedFile = await storeStandaloneFile(
          fileBytes: convertedFile,
          fileType: fileType,
        );
        fileImageDisplayPaths.add(storedConvertedFile.path);
      }
    }

    // Return the newly-created file path.
    return (
      filePath: file.path,
      fileImageDisplayPaths: fileImageDisplayPaths.toList(),
    );
  }

  // /// Exports the file to the user device.
  // ///
  // Future<void> dataExport({
  //   dynamic data,
  //   String? fileName,
  // }) async {
  //   if (LvApp.navigatorKey.currentContext == null) return;
  //   showDialog(
  //     context: LvApp.navigatorKey.currentContext!,
  //     builder: (context) {
  //       return Center(
  //         child: AlertDialog.adaptive(
  //           content: Text(
  //             'LOADING',
  //             style: TextStyle(
  //               fontWeight: FontWeight.w900,
  //               fontSize: 18,
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //   // Wait for the dialog content to be fully displayed,
  //   // below method is blocking the main thread.
  //   await Future.delayed(const Duration(milliseconds: 600));
  //   try {
  //     final json = {
  //       'time': DateTime.now().toIso8601String(),
  //       'version': LvConfig.instance.version,
  //       if (data != null)
  //         'data': data
  //       else ...{
  //         'documents': LvDataDocuments.instance.collection
  //             .map(
  //               (document) => document.toJson(),
  //             )
  //             .toList(),
  //         'documentFiles': [
  //           for (final document in LvDataDocuments.instance.collection)
  //             {
  //               'id': document.id,
  //               'filePath': document.filePath,
  //             },
  //         ],
  //       },
  //     };
  //     final jsonText = dart_convert.JsonEncoder.withIndent(' ' * 2).convert(json);
  //     final jsonBytes = dart_convert.utf8.encode(jsonText);
  //     final jsonCompressedBytes = archive.GZipEncoder().encode(jsonBytes);
  //     fileName ??= 'lv_${DateTime.now().millisecondsSinceEpoch}.json.txt.gz';
  //     await file_saver.FileSaver.instance.saveFile(
  //       name: fileName,
  //       bytes: Uint8List.fromList(jsonCompressedBytes),
  //     );
  //   } catch (e) {
  //     debugPrint('$e');
  //   }
  //   Navigator.pop(LvApp.navigatorKey.currentContext!);
  // }

  // /// Imports the data exported with the [dataExport] function.
  // ///
  // Future<void> dataImport() async {
  //   try {
  //     final importFile = await getFile(LvServiceFilesType.importData);
  //     if (importFile != null) {
  //       LvDialogContentBlocking.display();
  //       final fileType = importFile.fileName.split('.').last;
  //       if (LvServiceFilesType.importData.allowedTypeIdentifiers.contains(fileType)) {
  //         late Map<String, dynamic> jsonData;
  //         switch (fileType) {
  //           case 'txt':
  //           case 'json':
  //             final jsonText = dart_convert.utf8.decode(importFile.fileBytes);
  //             final jsonDecoded = dart_convert.jsonDecode(jsonText);
  //             jsonData = Map<String, dynamic>.from(jsonDecoded);
  //             break;
  //           case 'gz':
  //             final decompressedFileBytes = archive.GZipDecoder().decodeBytes(importFile.fileBytes);
  //             final jsonText = dart_convert.utf8.decode(decompressedFileBytes);
  //             final jsonDecoded = dart_convert.jsonDecode(jsonText);
  //             jsonData = Map<String, dynamic>.from(jsonDecoded);
  //             break;
  //           default:
  //             throw 'Not implemented.';
  //         }
  //         if (jsonData['time'] is! String ||
  //             jsonData['version'] is! String ||
  //             jsonData['documents'] is! Iterable ||
  //             jsonData['documentFiles'] is! Iterable) {
  //           throw 'Invalid import data.';
  //         }
  //         LvDataDocuments.instance.collection.clear();
  //         LvDataDocuments.instance.collection.addAll(
  //           [
  //             for (final jsonObject in jsonData['documents']) LvModelDocument.fromJson(jsonObject),
  //           ],
  //         );
  //         for (final documentFile in jsonData['documentFiles']) {
  //           if (documentFile['id'] is String && documentFile['bytes'] is Iterable) {
  //             final pageFileBytes = <Uint8List>[];
  //             for (final fileBytes in documentFile['bytes']) {
  //               try {
  //                 pageFileBytes.add(
  //                   Uint8List.fromList(
  //                     List<int>.from(fileBytes),
  //                   ),
  //                 );
  //               } catch (e) {
  //                 // Do nothing.
  //               }
  //             }
  //             LvDataDocuments.instance.collection
  //                 .firstWhereOrNull(
  //                   (document) => document.id == documentFile['id'],
  //                 )
  //                 ?. = pageFileBytes;
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('$e');
  //   }
  //   LvDialogContentBlocking.close();
  // }
}
