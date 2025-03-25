import 'dart:async';
import 'dart:math' as dart_math;
import 'dart:typed_data' as dart_typed_data;

import 'package:flutter/material.dart';
import 'package:generic_shop_app_content/gsac.dart';
import 'package:label_verify/models/models.dart';
import 'package:label_verify/services/src/service_images.dart';
import 'package:label_verify/view/src/common/dialogs/dialog.dart';

/// A widget that allows the user to review and select a section of the media content.
///
class LvWidgetMediaReviewSelection extends StatefulWidget {
  /// Default [Widget] constructor.
  ///
  const LvWidgetMediaReviewSelection({
    super.key,
    required this.contentDocument,
    this.comparisonDocument,
    this.addReviewItem,
    this.differenceResult,
  });

  /// Media content representation in the [Uint8List] format.
  ///
  final LvModelDocument contentDocument;

  /// Media content introduced for visual comparison purposes.
  ///
  final LvModelDocumentRevision? comparisonDocument;

  /// Method invoked on successful addition of a review item.
  ///
  final void Function(LvModelDocumentReviewConfiguration value)? addReviewItem;

  /// Detected document image results, with index set in accordance with the document page number.
  ///
  final List<
      ({
        dart_typed_data.Uint8List visualDisplay,
        List<LvModelDiffResult> contours,
      })>? differenceResult;

  @override
  State<LvWidgetMediaReviewSelection> createState() => LvWidgetReviewSelectionState();
}

/// [State] object defined for the [LvWidgetMediaReviewSelection] widget.
///
class LvWidgetReviewSelectionState extends State<LvWidgetMediaReviewSelection> {
  /// A key to access the render object of the media [Widget].
  ///
  final _mediaWidgetKey = GlobalKey();

  /// A render object in a 2D Cartesian coordinate system for the widget
  /// represented with the [_mediaWidgetKey] object.
  ///
  RenderBox? _mediaRenderBox;

  /// Set the [_mediaRenderBox] value to the current render object of the media [Widget].
  ///
  void _setMediaRenderBox() {
    _mediaRenderBox = _mediaWidgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (_mediaRenderBox != null) setState(() {});
  }

  /// Once the user starts the section selection process, these values are updated.
  ///
  ({
    double x,
    double xPercent,
    double y,
    double yPercent,
  })? _startPosition, _endPosition;

  void _setStartPosition(
    double x,
    double offsetX,
    double y,
    double offsetY,
  ) {
    _startPosition = (
      x: x,
      xPercent: offsetX,
      y: y,
      yPercent: offsetY,
    );
    setState(() {});
  }

  void _setEndPosition(
    double x,
    double offsetX,
    double y,
    double offsetY,
  ) {
    _endPosition = (
      x: x,
      xPercent: offsetX,
      y: y,
      yPercent: offsetY,
    );
    setState(() {});
  }

  void _resetPositionInfo() {
    _startPosition = null;
    _endPosition = null;
    setState(() {});
  }

  /// Value determining whether content panning is enabled.
  ///
  late bool _panEnabled;

  void _setPanState() {
    _panEnabled = !_panEnabled;
    setState(() {});
  }

  /// The amount of offset applied to the content by panning.
  ///
  Offset _panOffset = const Offset(0, 0);

  /// Adjust the position of the media content on the screen by a given [Offset].
  ///
  void _panAdjust(Offset delta) {
    _panOffset += delta;
    setState(() {});
  }

  /// The adjustable scale of the content.
  ///
  double _scale = 1;

  /// Selected amount by which to scale the media content.
  ///
  final _scaleRatio = .1;

  /// Enlarges the display size of the media content.
  ///
  void _scaleIncrease() {
    if (_scale < 100) {
      _scale += _scaleRatio;
      setState(() {});
    }
  }

  /// Decreases the display size of the media content.
  ///
  void _scaleDecrease() {
    if (_scale - _scaleRatio > 0) {
      _scale -= _scaleRatio;
      setState(() {});
    }
  }

  int _page = 0;

  bool get _previousPageAvailable => _documentDisplays!.length > 1 && _page - 1 >= 0;

  void _previousPage() {
    if (_previousPageAvailable) {
      _page--;
      setState(() {});
    }
  }

  bool get _nextPageAvailable => _documentDisplays!.length > 1 && _page + 1 < _documentDisplays!.length;

  void _nextPage() {
    if (_nextPageAvailable) {
      _page++;
      setState(() {});
    }
  }

  double _sliderPosition = .5;

  void _setSliderPosition(double primaryDelta) {
    setState(() {
      _sliderPosition += primaryDelta / (MediaQuery.of(context).size.width * (2 / 3));
      _sliderPosition = _sliderPosition.clamp(.02, .98);
    });
  }

  late Future<void> _getContentDisplays;

  List<dart_typed_data.Uint8List>? _documentDisplays, _comparisonDocumentDisplays;

  @override
  void initState() {
    super.initState();
    _panEnabled = widget.addReviewItem == null;
    _getContentDisplays = Future(
      () async {
        final documentDisplays = await widget.contentDocument.getFileImageDisplays();
        if (documentDisplays.isEmpty) {
          throw Exception('Document display list is empty.');
        }
        final comparisonDocumentDisplays = await widget.comparisonDocument?.getFileImageDisplays();
        if (comparisonDocumentDisplays?.isEmpty == true) {
          throw Exception('Comparison document provided but display list is empty.');
        }
        _documentDisplays = documentDisplays;
        _comparisonDocumentDisplays = comparisonDocumentDisplays;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            _setMediaRenderBox();
          },
        );
      },
    );
  }

  /// Displays and higlights the specified [reviewItem].
  ///
  void displayReviewItem(LvModelDocumentReviewConfiguration reviewItem) {
    setState(
      () {
        _page = reviewItem.page;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<void>(
          future: _getContentDisplays,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError || _documentDisplays?.isNotEmpty != true) {
              return Center(
                child: GsaWidgetError(snapshot.error?.toString() ?? 'No data found.'),
              );
            }

            return ClipRect(
              child: Stack(
                children: [
                  Center(
                    child: Transform.translate(
                      offset: _panOffset,
                      child: Transform.scale(
                        scale: _scale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Listener(
                              child: MouseRegion(
                                cursor: _panEnabled ? SystemMouseCursors.grab : SystemMouseCursors.precise,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    boxShadow: kElevationToShadow[16],
                                  ),
                                  child: Image.memory(
                                    key: _mediaWidgetKey,
                                    _documentDisplays![_page],
                                    gaplessPlayback: true,
                                  ),
                                ),
                              ),
                              onPointerDown: _panEnabled
                                  ? (event) => _panAdjust(event.delta)
                                  : widget.addReviewItem == null
                                      ? null
                                      : (event) {
                                          final offsetX = event.localPosition.dx / _mediaRenderBox!.size.width;
                                          final offsetY = event.localPosition.dy / _mediaRenderBox!.size.height;
                                          _setStartPosition(
                                            event.localPosition.dx,
                                            offsetX,
                                            event.localPosition.dy,
                                            offsetY,
                                          );
                                        },
                              onPointerMove: _panEnabled
                                  ? (event) => _panAdjust(event.delta)
                                  : widget.addReviewItem == null
                                      ? null
                                      : (event) {
                                          final offsetX = event.localPosition.dx / _mediaRenderBox!.size.width;
                                          final offsetY = event.localPosition.dy / _mediaRenderBox!.size.height;
                                          _setEndPosition(
                                            event.localPosition.dx,
                                            offsetX,
                                            event.localPosition.dy,
                                            offsetY,
                                          );
                                        },
                              onPointerUp: _panEnabled
                                  ? (event) => _panAdjust(event.delta)
                                  : widget.addReviewItem == null
                                      ? null
                                      : (event) async {
                                          if (_startPosition == null || _endPosition == null) return;
                                          final positionStartPercentX = _startPosition!.xPercent,
                                              positionStartPercentY = _startPosition!.yPercent,
                                              positionEndPercentX = _endPosition!.xPercent,
                                              positionEndPercentY = _endPosition!.yPercent;
                                          final differenceX = _startPosition!.x - _endPosition!.x,
                                              differenceY = _startPosition!.y - _endPosition!.y;
                                          _resetPositionInfo();
                                          if ((differenceX < 0 && differenceX > -2 || differenceX >= 0 && differenceX < 2) &&
                                              (differenceY < 0 && differenceY > -2 || differenceY >= 0 && differenceY < 2)) {
                                            return;
                                          }
                                          const GsaWidgetOverlayContentBlocking().openDialog(context);
                                          try {
                                            await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return _DialogReviewInput(
                                                  document: widget.contentDocument,
                                                  page: _page,
                                                  positionStartPercentX: positionStartPercentX < positionEndPercentX
                                                      ? positionStartPercentX
                                                      : positionEndPercentX,
                                                  positionStartPercentY: positionStartPercentY < positionEndPercentY
                                                      ? positionStartPercentY
                                                      : positionEndPercentY,
                                                  positionEndPercentX: positionEndPercentX > positionStartPercentX
                                                      ? positionEndPercentX
                                                      : positionStartPercentX,
                                                  positionEndPercentY: positionEndPercentY > positionStartPercentY
                                                      ? positionEndPercentY
                                                      : positionStartPercentY,
                                                  addReviewItem: widget.addReviewItem!,
                                                );
                                              },
                                            );
                                            Navigator.pop(context);
                                          } catch (e) {
                                            Navigator.pop(context);
                                            GsaWidgetOverlayAlert(
                                              title: 'Error',
                                              message: '$e',
                                            ).openDialog(context);
                                          }
                                        },
                            ),
                            if (_comparisonDocumentDisplays?.isNotEmpty == true) ...[
                              ClipRect(
                                clipper: _ClipperHorizontal(_sliderPosition),
                                child: Image.memory(
                                  _comparisonDocumentDisplays![_page],
                                  fit: BoxFit.contain,
                                  gaplessPlayback: true,
                                ),
                              ),
                              Positioned(
                                left: _sliderPosition * (MediaQuery.of(context).size.width * (2 / 3)) - 14,
                                top: 0,
                                bottom: 0,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Tooltip(
                                    richMessage: WidgetSpan(
                                      child: SizedBox(
                                        width: 140,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              for (final label in const <String>{
                                                'NEW',
                                                '',
                                                'OLD',
                                              })
                                                Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      label,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: SizedBox(
                                        width: 28,
                                        height: MediaQuery.of(context).size.height,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade200.withValues(alpha: .5),
                                              ),
                                              child: SizedBox(
                                                width: 2,
                                                height: MediaQuery.of(context).size.height,
                                              ),
                                            ),
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade200,
                                              ),
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width,
                                                child: const Icon(
                                                  Icons.drag_handle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onHorizontalDragUpdate: (details) {
                                        if (details.primaryDelta != null) {
                                          _setSliderPosition(details.primaryDelta!);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (_startPosition != null && _endPosition != null)
                              Positioned(
                                left: _startPosition!.x < _endPosition!.x ? _startPosition!.x : _endPosition!.x,
                                top: _startPosition!.y < _endPosition!.y ? _startPosition!.y : _endPosition!.y,
                                child: IgnorePointer(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade300.withValues(alpha: .3),
                                      border: Border.all(
                                        color: Colors.amber,
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: (_endPosition!.x - _startPosition!.x).abs(),
                                      height: (_endPosition!.y - _startPosition!.y).abs(),
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.differenceResult != null && _mediaRenderBox != null)
                              for (final contour in widget.differenceResult![_page].contours)
                                Positioned(
                                  left: contour.positionStartPercentX * _mediaRenderBox!.size.width,
                                  top: contour.positionStartPercentY * _mediaRenderBox!.size.height,
                                  child: IgnorePointer(
                                    child: _HighlightedArea(
                                      child: SizedBox(
                                        width: _mediaRenderBox!.size.width * contour.widthPercent,
                                        height: _mediaRenderBox!.size.height * contour.heightPercent,
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              child: const Icon(Icons.chevron_left),
                              onPressed: _previousPageAvailable ? () => _previousPage() : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Card(
                                margin: EdgeInsets.zero,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  child: Text(
                                    '${_page + 1}/${_documentDisplays!.length}',
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              child: const Icon(Icons.chevron_right),
                              onPressed: _nextPageAvailable ? () => _nextPage() : null,
                            ),
                          ],
                        ),
                        for (final action in {
                          if (widget.addReviewItem != null)
                            (
                              icon: _panEnabled ? Icons.pan_tool : Icons.pan_tool_outlined,
                              onPressed: () {
                                _setPanState();
                              },
                            ),
                          (
                            icon: Icons.zoom_in,
                            onPressed: () => _scaleIncrease(),
                          ),
                          (
                            icon: Icons.zoom_out,
                            onPressed: () => _scaleDecrease(),
                          ),
                        }.indexed)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                              child: Icon(action.$2.icon),
                              onPressed: action.$2.onPressed,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DialogReviewInput extends StatefulWidget {
  const _DialogReviewInput({
    required this.document,
    required this.page,
    required this.positionStartPercentX,
    required this.positionStartPercentY,
    required this.positionEndPercentX,
    required this.positionEndPercentY,
    required this.addReviewItem,
  });

  final LvModelDocument document;

  final int page;

  final double positionStartPercentX, positionStartPercentY, positionEndPercentX, positionEndPercentY;

  /// Method invoked on successful addition of a review item.
  ///
  final void Function(LvModelDocumentReviewConfiguration value) addReviewItem;

  @override
  State<_DialogReviewInput> createState() => _DialogReviewInputState();
}

class _DialogReviewInputState extends State<_DialogReviewInput> {
  /// State associated with a [Form] widget.
  ///
  final _formKey = GlobalKey<FormState>();

  /// Text editing controller object handling user input changes.
  ///
  final _textControllerTitle = TextEditingController(), _textControllerDescription = TextEditingController();

  /// The selected type of the review item.
  ///
  LvModelDocumentReviewConfigurationType? _reviewItemType;

  /// Property holding the value of the generated, cropped image display.
  ///
  dart_typed_data.Uint8List? _croppedImageDisplay;

  late Future<void> _getCroppedImage;

  @override
  void initState() {
    super.initState();
    _getCroppedImage = widget.document.getFileImageDisplays().then(
      (value) async {
        final croppedImage = await LvServiceImages.instance.cropImage(
          value[widget.page],
          widget.positionStartPercentX,
          widget.positionStartPercentY,
          widget.positionEndPercentX,
          widget.positionEndPercentY,
        );
        _croppedImageDisplay = croppedImage;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LvDialog(
      title: 'Parameter Entry',
      children: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Below cropped image section will be used to reference any follow-up updates in the submitted media.',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 0,
                  maxHeight: 300,
                ),
                child: Center(
                  heightFactor: 1,
                  child: FutureBuilder(
                    future: _getCroppedImage,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: GsaWidgetError(
                            snapshot.error.toString(),
                          ),
                        );
                      }

                      return Image.memory(
                        _croppedImageDisplay!,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Title and description are entered for labeling and communication purposes.',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _textControllerTitle,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value?.length == null || value!.trim().length < 3) {
                    return 'Title must be at least 3 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _textControllerDescription,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description (optional)',
                ),
                minLines: 3,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  text: 'The type of the content is required to be selected for follow-up processing purposes:\n\n',
                  children: [
                    for (final entry in <(String, String)>{
                      (
                        'Static Text',
                        'should not be changed across document versions. Any subsequent changes for the type must be verified.\n',
                      ),
                      (
                        'Dynamic Text',
                        'must be changed across document versions. Alert will be raised if no changes are made, and otherwise, '
                            'a prompt will appear to confirm the changes.\n',
                      ),
                      (
                        'Graphics',
                        'visual media representation, such as brand logo. Any subsequent changes for the type must be verified.',
                      ),
                    }) ...[
                      const TextSpan(
                        text: '- ',
                      ),
                      TextSpan(
                        text: entry.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: ' - ${entry.$2}',
                      ),
                    ],
                  ],
                ),
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                hint: const Text('Content Type'),
                isExpanded: true,
                elevation: 0,
                padding: EdgeInsets.zero,
                items: [
                  for (final reviewItemType in LvModelDocumentReviewConfigurationType.values)
                    DropdownMenuItem(
                      child: Text(reviewItemType.displayName),
                      value: reviewItemType,
                    ),
                ],
                onChanged: (value) {
                  setState(() => _reviewItemType = value);
                },
                validator: (value) {
                  if (_reviewItemType == null) {
                    return 'Please select an option.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    child: const Text('Submit'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final reviewItem = LvModelDocumentReviewConfiguration(
                          id: -1,
                          documentId: widget.document.id,
                          page: widget.page,
                          label: _textControllerTitle.text.trim(),
                          description: _textControllerDescription.text.trim(),
                          type: _reviewItemType!,
                          positionStartPercentX: widget.positionStartPercentX,
                          positionStartPercentY: widget.positionStartPercentY,
                          positionEndPercentX: widget.positionEndPercentX,
                          positionEndPercentY: widget.positionEndPercentY,
                        )..imageDisplay = _croppedImageDisplay;
                        widget.addReviewItem(reviewItem);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textControllerTitle.dispose();
    _textControllerDescription.dispose();
    super.dispose();
  }
}

class _ClipperHorizontal extends CustomClipper<Rect> {
  _ClipperHorizontal(this.dragPosition);

  final double dragPosition;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, dragPosition * size.width, size.height);
  }

  @override
  bool shouldReclip(_ClipperHorizontal oldClipper) {
    return oldClipper.dragPosition != dragPosition;
  }
}

class _HighlightedArea extends StatefulWidget {
  const _HighlightedArea({
    required this.child,
  });

  final Widget child;

  @override
  _HighlightedAreaState createState() => _HighlightedAreaState();
}

class _HighlightedAreaState extends State<_HighlightedArea> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _duration = const Duration(seconds: 2);

  static final _colors = <Color>[
    for (int i = 0; i < 100; i++)
      Color.fromARGB(
        255,
        dart_math.Random().nextInt(256),
        dart_math.Random().nextInt(256),
        dart_math.Random().nextInt(256),
      ),
  ];

  int _colorIndex = 0;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _duration,
      vsync: this,
      lowerBound: 0,
      upperBound: .6,
    )..repeat(reverse: true);
    _timer = Timer.periodic(
      _duration * 2,
      (_) {
        setState(() => _colorIndex + 1 < _colors.length ? _colorIndex++ : _colorIndex = 0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _colors[_colorIndex],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }
}
