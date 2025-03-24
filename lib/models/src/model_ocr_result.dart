/// Model class representing data retrieved from
///
class LvModelOcrResult {
  /// Default, unnamed class constructor.
  ///
  LvModelOcrResult({
    required this.text,
    required this.positionStartPercentX,
    required this.positionStartPercentY,
    required this.positionEndPercentX,
    required this.positionEndPercentY,
  });

  /// The text detected using the OCR functionality.
  ///
  String text;

  /// Start position of the detected text area.
  ///
  double positionStartPercentX, positionStartPercentY;

  /// End position of the detected text area.
  ///
  double positionEndPercentX, positionEndPercentY;

  /// Factory constructor used to generate a class instance from JSON data format.
  ///
  factory LvModelOcrResult.fromJson(Map json) {
    return LvModelOcrResult(
      text: json['text'],
      positionStartPercentX: json['start']['x'],
      positionStartPercentY: json['start']['y'],
      positionEndPercentX: json['end']['x'],
      positionEndPercentY: json['end']['y'],
    );
  }

  /// Method used for generating data in the JSON format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'start': {
        'x': positionStartPercentX,
        'y': positionStartPercentY,
      },
      'end': {
        'x': positionEndPercentX,
        'y': positionEndPercentY,
      },
    };
  }
}
