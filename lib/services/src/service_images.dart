import 'dart:async' as dart_async;
import 'dart:typed_data' as dart_typed_data;
import 'dart:ui' as dart_ui;
import 'dart:math' as dart_math;

import 'package:generic_shop_app_architecture/gsar.dart';

/// Utility methods implemented for image manipulation purposes.
///
class LvServiceImages extends GsaService {
  /// Crops the given [imageData] according to the specified coordinates,
  /// returning the display value of this cropped image.
  ///
  static Future<dart_typed_data.Uint8List> cropImage(
    dart_typed_data.Uint8List imageData,
    double positionStartPercentX,
    double positionStartPercentY,
    double positionEndPercentX,
    double positionEndPercentY,
  ) async {
    final completer = dart_async.Completer<dart_ui.Image>();
    dart_ui.decodeImageFromList(
      imageData,
      (dart_ui.Image img) => completer.complete(img),
    );
    dart_ui.Image image = await completer.future;

    final int width = image.width;
    final int height = image.height;

    // Convert percentages to pixel values.
    final cropX1 = width * positionStartPercentX;
    final cropY1 = height * positionStartPercentY;
    final cropX2 = width * positionEndPercentX;
    final cropY2 = height * positionEndPercentY;

    // Ensure correct crop region.
    final cropX = dart_math.min(cropX1, cropX2);
    final cropY = dart_math.min(cropY1, cropY2);
    final cropWidth = (dart_math.max(cropX1, cropX2) - cropX);
    final cropHeight = (dart_math.max(cropY1, cropY2) - cropY);

    final recorder = dart_ui.PictureRecorder();
    final canvas = dart_ui.Canvas(recorder);
    final paint = dart_ui.Paint();

    canvas.drawImageRect(
      image,
      dart_ui.Rect.fromLTWH(cropX, cropY, cropWidth, cropHeight), // Source rectangle
      dart_ui.Rect.fromLTWH(0, 0, cropWidth, cropHeight), // Destination rectangle
      paint,
    );

    final picture = recorder.endRecording();
    final dart_ui.Image croppedImage = await picture.toImage(
      cropWidth.toInt(),
      cropHeight.toInt(),
    );

    // Convert ui.Image to Uint8List.
    dart_typed_data.ByteData? byteData = await croppedImage.toByteData(
      format: dart_ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }
}
