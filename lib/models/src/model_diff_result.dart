/// Model class representing any detected differences in image between 2 separate media content.
///
class LvModelDiffResult {
  /// Default, unnamed class constructor.
  ///
  LvModelDiffResult({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.xPercent,
    required this.yPercent,
    required this.widthPercent,
    required this.heightPercent,
  });

  /// Start coordinates expressed as pixels.
  ///
  int x, y;

  /// The width and height of the highlighted area, starting from [x] and [y].
  ///
  int width, height;

  /// Coordinate values [x] and [y] expressed as a percentage of the media content.
  ///
  double xPercent, yPercent;

  /// Highlighted area [width] and [height], expressed as a percentage of the media content.
  ///
  double widthPercent, heightPercent;

  /// Factory constructor used to generate a class instance from JSON data format.
  ///
  factory LvModelDiffResult.fromJson(Map json) {
    return LvModelDiffResult(
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
      xPercent: json['xPercent'],
      yPercent: json['yPercent'],
      widthPercent: json['widthPercent'],
      heightPercent: json['heightPercent'],
    );
  }

  /// Method used for generating data in the JSON format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'xPercent': xPercent,
      'yPercent': yPercent,
      'widthPercent': widthPercent,
      'heightPercent': heightPercent,
    };
  }
}
