/// Model class representing any detected differences in image between 2 separate media content.
///
class LvModelDiffResult {
  /// Default, unnamed class constructor.
  ///
  LvModelDiffResult({
    required this.startPositionX,
    required this.startPositionY,
    required this.width,
    required this.height,
    required this.positionStartPercentX,
    required this.positionStartPercentY,
    required this.widthPercent,
    required this.heightPercent,
  });

  /// Start coordinates expressed as pixels.
  ///
  int startPositionX, startPositionY;

  /// The width and height of the highlighted area, starting from [x] and [y].
  ///
  int width, height;

  /// Start coordinate values expressed as a percentage of the media content.
  ///
  double positionStartPercentX, positionStartPercentY;

  /// Highlighted area [width] and [height], expressed as a percentage of the media content.
  ///
  double widthPercent, heightPercent;

  /// End position X coordinate value expressed as a percentage of the media content.
  ///
  double get positionEndPercentX => positionStartPercentX + widthPercent;

  /// End position Y coordinate value expressed as a percentage of the media content.
  ///
  double get positionEndPercentY => positionStartPercentY + heightPercent;

  /// Factory constructor used to generate a class instance from JSON data format.
  ///
  factory LvModelDiffResult.fromJson(Map json) {
    return LvModelDiffResult(
      startPositionX: json['x'],
      startPositionY: json['y'],
      width: json['width'],
      height: json['height'],
      positionStartPercentX: json['xPercent'],
      positionStartPercentY: json['yPercent'],
      widthPercent: json['widthPercent'],
      heightPercent: json['heightPercent'],
    );
  }

  /// Method used for generating data in the JSON format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'x': startPositionX,
      'y': startPositionY,
      'width': width,
      'height': height,
      'xPercent': positionStartPercentX,
      'yPercent': positionStartPercentY,
      'widthPercent': widthPercent,
      'heightPercent': heightPercent,
    };
  }
}
