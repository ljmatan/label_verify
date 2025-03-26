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

  ({
    List<LvModelDocumentReviewConfiguration> checklist,
    List<LvModelDocumentReviewConfiguration> success,
    List<LvModelDocumentReviewConfiguration> error,
  })? _reviewItems;

  void _setReviewItems() {
    if (_reviewConfiguration != null) {
      _reviewItems = (
        checklist: _reviewConfiguration!.where(
          (reviewItem) {
            return !widget.comparisonDocument.successConfigurationIds.contains(
                  reviewItem.id,
                ) &&
                !widget.comparisonDocument.errorConfigurationIds.contains(
                  reviewItem.id,
                );
          },
        ).toList(),
        success: _reviewConfiguration!.where(
          (reviewItem) {
            return widget.comparisonDocument.successConfigurationIds.contains(
              reviewItem.id,
            );
          },
        ).toList(),
        error: _reviewConfiguration!.where(
          (reviewItem) {
            return widget.comparisonDocument.errorConfigurationIds.contains(
              reviewItem.id,
            );
          },
        ).toList(),
      );
    }
  }

  /// Detected document image results, with index set in accordance with the document page number.
  ///
  List<
      ({
        dart_typed_data.Uint8List visualDisplay,
        List<LvModelDiffResult> contours,
      })>? _differenceResult;

  late Future<void> _initialiseContentData;

  @override
  void initState() {
    super.initState();
    _initialiseContentData = Future(
      () async {
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
        _setReviewItems();
        final differenceResult = [
          for (int i = 0; i < _fileImageDisplays!.length; i++)
            await LvServiceImages.instance.highlightDifferences(
              _fileImageDisplays![i],
              _comparisonFileImageDisplays![i],
            ),
        ];
        _differenceResult = differenceResult;
      },
    );
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
              future: _initialiseContentData,
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
                                      child: Row(
                                        children: [
                                          Tooltip(
                                            message: 'Confirm all of the current changes without exiting the screen.',
                                            child: FilledButton.icon(
                                              label: const Text('SAVE'),
                                              icon: const Icon(Icons.save),
                                              onPressed: () async {},
                                            ),
                                          ),
                                          Expanded(
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
                                        ],
                                      ),
                                    ),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.end,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        for (final buttonLabel in <String>{
                                          'CHECKLIST (${_reviewItems?.checklist.length})',
                                          'SUCCESS (${_reviewItems?.success.length})',
                                          'ERROR (${_reviewItems?.error.length})',
                                        }.indexed)
                                          Padding(
                                            padding: buttonLabel.$1 == 0 ? EdgeInsets.zero : const EdgeInsets.only(left: 8),
                                            child: ValueListenableBuilder<int>(
                                              valueListenable: _selectedTabNotifier,
                                              builder: (context, value, child) {
                                                return TextButton(
                                                  child: Text(
                                                    buttonLabel.$2,
                                                    style: TextStyle(
                                                      color: buttonLabel.$1 == value ? Colors.white : Colors.grey.shade200,
                                                      fontWeight: buttonLabel.$1 == value ? FontWeight.w900 : null,
                                                      decoration: buttonLabel.$1 == value ? TextDecoration.underline : null,
                                                      decorationColor: Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: buttonLabel.$1 == value
                                                      ? null
                                                      : () {
                                                          _selectedTabNotifier.value = buttonLabel.$1;
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
                                final selectedReviewItems = switch (value) {
                                  0 => _reviewItems?.checklist,
                                  1 => _reviewItems?.success,
                                  2 => _reviewItems?.error,
                                  _ => throw UnimplementedError('List at tab number $value not implemented.'),
                                };

                                if (selectedReviewItems?.isNotEmpty != true) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: const Text(
                                        'No review items found in the specified category.',
                                      ),
                                    ),
                                  );
                                }

                                return ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                  children: [
                                    for (final reviewItem in selectedReviewItems!)
                                      _WidgetReviewItem(
                                        reviewItem,
                                        documentVisualContent: _fileImageDisplays!,
                                        comparisonDocumentVisualContent: _comparisonFileImageDisplays!,
                                        highlightedContours: [
                                          for (final result in _differenceResult!) result.contours,
                                        ],
                                        reviewed: widget.comparisonDocument.successConfigurationIds.contains(
                                              reviewItem.id,
                                            ) ||
                                            widget.comparisonDocument.errorConfigurationIds.contains(
                                              reviewItem.id,
                                            ),
                                        onStateUpdate: (value) {
                                          switch (value) {
                                            case null:
                                              widget.comparisonDocument.successConfigurationIds.remove(reviewItem.id);
                                              widget.comparisonDocument.errorConfigurationIds.remove(reviewItem.id);
                                              break;
                                            case true:
                                              widget.comparisonDocument.successConfigurationIds.add(reviewItem.id);
                                              break;
                                            case false:
                                              widget.comparisonDocument.errorConfigurationIds.add(reviewItem.id);
                                              break;
                                          }
                                          _setReviewItems();
                                          setState(() {});
                                        },
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
