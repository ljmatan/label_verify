import 'dart:typed_data' as dart_typed_data;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:generic_shop_app_content/gsac.dart';
import 'package:label_verify/models/models.dart';
import 'package:label_verify/services/services.dart';
import 'package:label_verify/view/src/common/widgets/widget_media_review_selection.dart';
import 'package:label_verify/view/src/common/widgets/widget_navigation_bar.dart';

part 'widgets/widget_review_item.dart';

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
      throw Exception(
        'No review configuration set up for this document.\n\n'
        'This is required for document processing, and can be specified with the "REVIEW" menu.',
      );
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

  /// Key property used for accessing of the [LvWidgetReviewSelectionState] object.
  ///
  final _reviewSelectionKey = GlobalKey<LvWidgetReviewSelectionState>();

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
                        key: _reviewSelectionKey,
                        contentDocument: widget.document,
                        comparisonDocument: widget.comparisonDocument,
                        differenceResult: _differenceResult,
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
                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            widget.document.label.toUpperCase(),
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            widget.document.createdAt.toIso8601String().substring(0, 16).replaceAll('T', ' '),
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
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
                                      _WidgetReviewItem(
                                        reviewItem,
                                        documentVisualContent: _fileImageDisplays!,
                                        comparisonDocumentVisualContent: _comparisonFileImageDisplays!,
                                        highlightedContours: [
                                          for (final result in _differenceResult!) result.contours,
                                        ],
                                        displayOnScreen: () {
                                          _reviewSelectionKey.currentState?.displayReviewItem(reviewItem);
                                        },
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
