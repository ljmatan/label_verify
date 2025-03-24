import 'dart:typed_data' as dart_typed_data;

import 'package:flutter/material.dart';
import 'package:generic_shop_app_content/gsac.dart';
import 'package:label_verify/models/models.dart';
import 'package:label_verify/models/src/model_diff_result.dart';
import 'package:label_verify/services/services.dart';
import 'package:label_verify/view/src/common/widgets/widget_media_review_selection.dart';
import 'package:label_verify/view/src/common/widgets/widget_navigation_bar.dart';

/// Route for establishing the process of reviewing the media content.
///
class LvRouteReview extends StatefulWidget {
  /// Default widget constructor.
  ///
  const LvRouteReview({
    super.key,
    required this.document,
    required this.comparisonDocument,
  });

  /// Media content used for review and comparison of submitted changes.
  ///
  final LvModelDocument document;

  /// Media content used for review and comparison of submitted changes.
  ///
  final LvModelDocumentRevision comparisonDocument;

  @override
  State<LvRouteReview> createState() => _LvRouteReviewState();
}

class _LvRouteReviewState extends State<LvRouteReview> {
  /// Document image displays.
  ///
  List<dart_typed_data.Uint8List>? _fileImageDisplays, _comparisonFileImageDisplays;

  /// A collection of review configurations set up with this document.
  ///
  List<LvModelDocumentReviewConfiguration>? _reviewConfiguration;

  /// Detected document image results, with index set in accordance with the document page number.
  ///
  List<
      ({
        dart_typed_data.Uint8List visualDisplay,
        List<LvModelDiffResult> contours,
      })>? _differenceResult;

  Future<void> _initialiseContentData() async {
    final fileImageDisplays = await widget.document.getFileImageDisplays();
    if (fileImageDisplays.isEmpty) {
      throw Exception('Document image displays is empty.');
    }
    _fileImageDisplays = fileImageDisplays;
    final comparisonFileImageDisplays = await widget.comparisonDocument.getFileImageDisplays();
    if (comparisonFileImageDisplays.isEmpty) {
      throw Exception('Comparison document image displays is empty.');
    }
    _comparisonFileImageDisplays = comparisonFileImageDisplays;
    final reviewConfiguration = await LvServiceDatabase.instance.getDocumentReviewConfigurationsForId(
      widget.document.id,
    );
    if (reviewConfiguration.isEmpty) {
      throw Exception('No review configuration set up for this document.');
    }
    _reviewConfiguration = reviewConfiguration;
    final differenceResult = [
      for (int i = 0; i < _fileImageDisplays!.length; i++)
        await LvServiceImages.instance.highlightDifferences(
          _fileImageDisplays![i],
          _comparisonFileImageDisplays![i],
        ),
    ];
    _differenceResult = differenceResult;
  }

  /// Notifier implemented to track the view tab selection.
  ///
  final _selectedTabNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const LvWidgetNavigationBar(
            label: 'Review',
          ),
          Expanded(
            child: FutureBuilder(
              future: _initialiseContentData(),
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

                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: LvWidgetMediaReviewSelection(
                        contentDocument: widget.document,
                        comparisonDocument: widget.comparisonDocument,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Ink(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          widget.document.label.toUpperCase(),
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.end,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        for (final button in <({
                                          String label,
                                          int length,
                                        })>{
                                          (
                                            label: 'CHECKLIST',
                                            length: 0,
                                          ),
                                          (
                                            label: 'RESOLVED',
                                            length: 0,
                                          ),
                                          (
                                            label: 'ERRORS',
                                            length: 0,
                                          ),
                                        }.indexed)
                                          Padding(
                                            padding: button.$1 == 0 ? EdgeInsets.zero : const EdgeInsets.only(left: 8),
                                            child: ValueListenableBuilder<int>(
                                              valueListenable: _selectedTabNotifier,
                                              builder: (context, value, child) {
                                                return TextButton(
                                                  child: Text(
                                                    '${button.$2.label} (${button.$2.length})',
                                                    style: TextStyle(
                                                      color: button.$1 == value ? Colors.white : Colors.grey.shade200,
                                                      fontWeight: button.$1 == value ? FontWeight.w900 : null,
                                                      decoration: button.$1 == value ? TextDecoration.underline : null,
                                                      decorationColor: Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: button.$1 == value
                                                      ? null
                                                      : () {
                                                          _selectedTabNotifier.value = button.$1;
                                                        },
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: _selectedTabNotifier,
                              builder: (context, value, child) {
                                return ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                  children: [
                                    for (final reviewItem in _reviewConfiguration!)
                                      Card(
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade200,
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        minWidth: MediaQuery.of(context).size.width,
                                                        maxHeight: 400,
                                                      ),
                                                      child: FutureBuilder(
                                                        future: widget.document.getFileImageDisplays().then(
                                                          (value) {
                                                            return reviewItem.getImageDisplay(
                                                              originalImage: value[reviewItem.page],
                                                            );
                                                          },
                                                        ),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.connectionState != ConnectionState.done) {
                                                            return const Center(
                                                              child: CircularProgressIndicator(),
                                                            );
                                                          }

                                                          if (snapshot.hasError || snapshot.data?.isNotEmpty != true) {
                                                            return Center(
                                                              child: GsaWidgetError(
                                                                snapshot.error?.toString() ?? 'No data found.',
                                                              ),
                                                            );
                                                          }

                                                          return Image.memory(
                                                            snapshot.data!,
                                                            width: MediaQuery.of(context).size.width,
                                                            fit: BoxFit.contain,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: ElevatedButton(
                                                      child: const Icon(Icons.zoom_in),
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      reviewItem.label,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    child: const Icon(Icons.close),
                                                    onPressed: () {},
                                                  ),
                                                  const SizedBox(width: 6),
                                                  FilledButton(
                                                    child: const Icon(Icons.check),
                                                    onPressed: () {},
                                                  ),
                                                ],
                                              ),
                                              if (reviewItem.description != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    reviewItem.description!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade800,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _selectedTabNotifier.dispose();
    super.dispose();
  }
}
