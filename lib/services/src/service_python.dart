import 'dart:convert' as dart_convert;
import 'dart:io' as dart_io;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as services;
import 'package:generic_shop_app_architecture/gsar.dart';
import 'package:label_verify/config.dart';
import 'package:label_verify/models/src/model_diff_result.dart';
import 'package:label_verify/models/src/model_ocr_result.dart';
import 'package:label_verify/services/src/service_cache.dart';
import 'package:label_verify/services/src/service_files.dart';
import 'package:label_verify/services/src/service_http.dart';

/// Python runtime is implemented for desktop app usage,
/// in order to access services such as OpenCV or Tesseract.
///
/// The runtime is setup as a REST API server with which the
/// Flutter frontend communicates for task fulfillment purposes.
///
class LvServicePythonRuntime extends GsaService {
  LvServicePythonRuntime._();

  /// Globally-accessible class instance.
  ///
  static final instance = LvServicePythonRuntime._();

  /// The file path of the Python executable stored on the user device.
  ///
  late String _executablePath;

  /// The compiled Python binary must be stored to the device in order to have it initialised.
  ///
  /// The method should load the binary from the assets directory, and store it to the device if not stored.
  ///
  Future<void> _processExecutable() async {
    final assetId = 'assets/bin/python.exec';
    final cachedExecutablePath = LvServiceCache.instance.getString(assetId);
    if (cachedExecutablePath != null) {
      if (LvConfig.instance.binAssetUpdate) {
        try {
          await dart_io.File(cachedExecutablePath).delete();
        } catch (e) {
          debugPrint('Error deleting existing binary asset: $e');
        }
      } else {
        _executablePath = cachedExecutablePath;
        return;
      }
    }
    final executableByteData = await services.rootBundle.load(assetId);
    final executableBytes = executableByteData.buffer.asUint8List();
    final storedFile = await LvServiceFiles.instance.storeStandaloneFile(
      fileBytes: executableBytes,
      fileType: LvServiceFilesExtensionTypes.exec,
    );
    await LvServiceCache.instance.setString(assetId, storedFile.path);
    _executablePath = storedFile.path;
    await dart_io.Process.run(
      'chmod',
      [
        '+x',
        _executablePath,
      ],
    );
  }

  /// Free port used for connection with the Python server.
  ///
  late int _port;

  /// The address of the Python server running on this device.
  ///
  late String _serverAddress;

  /// Method used for scanning available device ports for Python server connection.
  ///
  Future<void> _findAvailablePort() async {
    final dynamicPortRanges = (49152, 65535);
    final scanPortRanges = List.generate(
      dynamicPortRanges.$2 - dynamicPortRanges.$1,
      (index) => dynamicPortRanges.$1 + index,
    );
    for (final port in scanPortRanges) {
      try {
        final server = await dart_io.ServerSocket.bind(
          dart_io.InternetAddress.loopbackIPv4,
          port,
        );
        await server.close();
        _port = port;
        _serverAddress = 'http://localhost:$_port';
        return;
      } catch (e) {
        // Port is in use, try the next one.
      }
    }
    throw Exception('No available ports found.');
  }

  Future<void> _runExecutable() async {
    final process = await dart_io.Process.start(
      _executablePath,
      [
        '--port',
        '$_port',
        '--ppid',
        '${dart_io.pid}',
      ],
    );
    dart_io.stdout.addStream(process.stdout);
    dart_io.stderr.addStream(process.stderr);
  }

  /// Pings the local device network with the specified [_port] info
  /// until a connection is confirmed as being established.
  ///
  Future<void> _confirmConnection() async {
    bool loading = true;
    while (loading) {
      // Debounce the method for the specified duration.
      await Future.delayed(const Duration(milliseconds: 100));
      // Below method will throw an error unless a 200 status code response is received.
      try {
        await LvServiceHttp.instance.get(
          Uri.parse(_serverAddress),
          timeout: const Duration(milliseconds: 100),
        );
        loading = false;
      } catch (e) {
        // Do nothing.
      }
    }
  }

  @override
  Future<void> init() async {
    await super.init();
    await _findAvailablePort();
    await _processExecutable();
    await _runExecutable();
    await _confirmConnection();
  }

  /// Scans the input [image] data for any text content,
  /// and returns the results as a list of findings.
  ///
  Future<List<LvModelOcrResult>> ocrScan(
    Uint8List image,
  ) async {
    final response = await LvServiceHttp.instance.post(
      Uri.parse('$_serverAddress/img/ocr'),
      {
        'imageBase64': dart_convert.base64Encode(image),
      },
    );
    if (response['data'] is! Iterable) {
      throw Exception('Response[\'data\'] type not Iterable: ${response.runtimeType}');
    }
    return [
      for (final jsonEntry in response['data'])
        LvModelOcrResult.fromJson(
          Map<String, dynamic>.from(jsonEntry),
        ),
    ];
  }

  /// Returns an image composed of 2 input images,
  /// with any differences highlighted on this new image display.
  ///
  Future<
      ({
        Uint8List visualDisplay,
        List<LvModelDiffResult> contours,
      })> highlightDifferences(
    Uint8List image1,
    Uint8List image2,
  ) async {
    final response = await LvServiceHttp.instance.post(
      Uri.parse('$_serverAddress/img/diff'),
      {
        'image1Base64': dart_convert.base64Encode(image1),
        'image2Base64': dart_convert.base64Encode(image2),
      },
    );
    if (response['data'] is! String) {
      throw Exception('Response[\'data\'] type not String: ${response['data'].runtimeType}');
    }
    if (response['contours'] is! Iterable) {
      throw Exception('Response[\'contours\'] type not Map: ${response['contours'].runtimeType}');
    }
    return (
      visualDisplay: dart_convert.base64Decode(response['data']),
      contours: [
        for (final jsonObject in response['contours'])
          LvModelDiffResult.fromJson(
            jsonObject,
          ),
      ],
    );
  }

  /// Converts given PDF [fileBytes] to a PNG image representation.
  ///
  Future<List<Uint8List>> convertPdfToPng(
    Uint8List fileBytes,
  ) async {
    final response = await LvServiceHttp.instance.post(
      Uri.parse('$_serverAddress/convert/pdf'),
      {
        'pdfBase64': dart_convert.base64Encode(fileBytes),
      },
    );
    if (response['data'] is! Iterable) {
      throw Exception('Response[\'data\'] type not Iterable: ${response['data'].runtimeType}');
    }
    return [
      for (final jsonData in response['data']) dart_convert.base64Decode(jsonData),
    ];
  }
}
