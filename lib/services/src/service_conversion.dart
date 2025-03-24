import 'dart:typed_data' as dart_typed_data;
import 'dart:ui' as dart_ui;

import 'package:generic_shop_app_architecture/gsar.dart';
import 'package:flutter_svg/flutter_svg.dart' as flutter_svg;
import 'package:label_verify/services/services.dart';

/// Class implementing file conversion services.
///
class LvServiceConversion extends GsaService {
  LvServiceConversion._();

  /// Globally-accessible class instance.
  ///
  static final instance = LvServiceConversion._();

  /// Converts a Scalable Vector Graphics format image to a Portable Network Graphics format image.
  ///
  Future<dart_typed_data.Uint8List> convertSvgToPng(
    String svgData, [
    double targetWidth = 1024,
  ]) async {
    final svgStringLoader = flutter_svg.SvgStringLoader(svgData);
    final pictureInfo = await flutter_svg.vg.loadPicture(svgStringLoader, null);
    final recorder = dart_ui.PictureRecorder();
    final scaleFactor = targetWidth / pictureInfo.size.width;
    final targetHeight = pictureInfo.size.height * scaleFactor;
    final canvas = dart_ui.Canvas(
      recorder,
      dart_ui.Rect.fromPoints(
        dart_ui.Offset.zero,
        dart_ui.Offset(
          targetWidth,
          targetHeight,
        ),
      ),
    );
    canvas.scale(
      targetWidth / pictureInfo.size.width,
      targetHeight / pictureInfo.size.height,
    );
    canvas.drawPicture(pictureInfo.picture);
    final imgByteData = await recorder.endRecording().toImage(
          targetWidth.ceil(),
          targetHeight.ceil(),
        );
    final bytesData = await imgByteData.toByteData(
      format: dart_ui.ImageByteFormat.png,
    );
    final imageData = bytesData?.buffer.asUint8List() ?? dart_typed_data.Uint8List(0);
    pictureInfo.picture.dispose();
    return imageData;
  }

  /// Converts pages from a Portable Document Format to Portable Network Graphics format images.
  ///
  Future<List<dart_typed_data.Uint8List>> convertPdfToPng(
    dart_typed_data.Uint8List fileBytes,
  ) async {
    return await LvServicePythonRuntime.instance.convertPdfToPng(fileBytes);
  }
}
