import 'dart:convert' as dart_convert;
import 'dart:io' as dart_io;
import 'dart:math' as dart_math;

import 'package:flutter/foundation.dart';
import 'package:generic_shop_app_architecture/gsar.dart';
import 'package:label_verify/models/models.dart';
import 'package:label_verify/services/src/service_conversion.dart';
import 'package:collection/collection.dart' as collection;
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:printing/printing.dart' as printing;

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
            : await printing.Printing.raster(
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
    String? directoryName,
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
    if (!await appSupportDirectory.exists()) {
      await appSupportDirectory.create(recursive: true);
    }

    // Create the subdirectory if it doesn't exist.
    if (directoryName != null) {
      final subdirectoryPath = path.join(appSupportDirectory.path, directoryName);
      final subdirectory = dart_io.Directory(subdirectoryPath);
      if (!await subdirectory.exists()) {
        await subdirectory.create(recursive: true);
      }
    }

    // Determine a valid filename.
    String fileName = generateRandomFileName(20) + fileType.filePathExtension;
    String filePath = directoryName == null
        ? path.join(
            appSupportDirectory.path,
            fileName,
          )
        : path.join(
            appSupportDirectory.path,
            directoryName,
            fileName,
          );
    dart_io.File file = dart_io.File(filePath);
    while (await file.exists()) {
      fileName = generateRandomFileName(20) + fileType.filePathExtension;
      String filePath = directoryName == null
          ? path.join(
              appSupportDirectory.path,
              fileName,
            )
          : path.join(
              appSupportDirectory.path,
              directoryName,
              fileName,
            );
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
      directoryName: 'original',
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
        fileType: LvServiceFilesExtensionTypes.png,
        directoryName: 'converted',
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
          fileType: LvServiceFilesExtensionTypes.png,
          directoryName: 'converted',
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

  /// Removes the specified document files from the local file system.
  ///
  Future<void> deleteDocumentFiles(LvModelDocument document) async {
    for (final filePath in <String>{
      document.filePath,
      ...document.fileImageDisplayPaths,
    }) {
      await dart_io.File(filePath).delete();
    }
  }

  /// Removes the document revision files from the local file system.
  ///
  Future<void> deleteDocumentRevisionFiles(LvModelDocumentRevision documentRevision) async {
    for (final filePath in <String>{
      documentRevision.filePath,
      ...documentRevision.fileImageDisplayPaths,
    }) {
      await dart_io.File(filePath).delete();
    }
  }
}
