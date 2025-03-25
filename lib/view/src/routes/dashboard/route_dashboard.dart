import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generic_shop_app_content/gsac.dart';
import 'package:label_verify/data/src/data_documents.dart';
import 'package:label_verify/main.dart';
import 'package:label_verify/models/models.dart';
import 'package:label_verify/services/services.dart';
import 'package:label_verify/view/src/common/dialogs/dialog.dart';
import 'package:label_verify/view/src/common/dialogs/dialog_content_blocking.dart';
import 'package:label_verify/view/src/common/widgets/widget_navigation_bar.dart';
import 'package:label_verify/view/src/routes/configure/route_configure.dart';
import 'package:label_verify/view/src/routes/revisions/route_revisions.dart';
import 'package:label_verify/view/src/routes/review/route_review.dart';

part 'dialogs/dialog_document_upload.dart';

/// Landing page with main program content.
///
class LvRouteDashboard extends StatefulWidget {
  /// Default widget constructor.
  ///
  const LvRouteDashboard({super.key});

  @override
  State<LvRouteDashboard> createState() => _LvRouteDashboardState();
}

class _LvRouteDashboardState extends State<LvRouteDashboard> {
  /// Method implemented with the [ChangeNotifier.addListener] function in order to notify the [State] of any updates.
  ///
  /// [State] will therefore be rebuilt using the [setState] method on any document updates.
  ///
  void _onDocumentUpdates() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    LvDataDocuments.instance.addListener(_onDocumentUpdates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: LvServiceDatabase.instance.getAllDocuments().then(
          (value) {
            LvDataDocuments.instance.collection.clear();
            LvDataDocuments.instance.collection.addAll(value);
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: GsaWidgetError(
                snapshot.error.toString() + (kDebugMode ? '\n${snapshot.stackTrace}' : ''),
              ),
            );
          }

          return Column(
            children: [
              const LvWidgetNavigationBar(
                label: 'Dashboard',
                includeBackButton: false,
              ),
              Expanded(
                child: FutureBuilder<List<LvModelDocument>>(
                  future: Future(
                    () {
                      return LvDataDocuments.instance.collection;
                    },
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Documents',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            for (final action in <({
                              String label,
                              String tooltip,
                              IconData icon,
                              Future<void> Function()? onTap,
                            })>{
                              (
                                label: 'NEW DOCUMENT',
                                tooltip: 'Upload a document for review processes. Supported media formats: PDF, PNG, JPG, SVG.',
                                icon: Icons.upload,
                                onTap: () async {
                                  await _DialogDocumentUpload.display();
                                },
                              ),
                            }.indexed)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Tooltip(
                                  message: action.$2.tooltip,
                                  child: OutlinedButton.icon(
                                    label: Text(action.$2.label),
                                    icon: Icon(action.$2.icon),
                                    onPressed: action.$2.onTap,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 30),
                        if (snapshot.data?.isNotEmpty == true) ...[
                          const Text(
                            'Review and edit the available document collection, set configuration review options, '
                            'and update with latest revisions.',
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (snapshot.data?.isNotEmpty != true)
                          const Text.rich(
                            TextSpan(
                              text: 'No documents available for review.\n\n',
                              children: [
                                TextSpan(
                                  text: 'To transfer documents using the program, you may start by using the "NEW DOCUMENT" button. '
                                      'Supported media formats: PDF, PNG, JPG, SVG.\n\n'
                                      'After transferring the documents, you may review them by visiting the "REVIEW" menu.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          GridView(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: MediaQuery.of(context).size.width < 800
                                  ? 1
                                  : MediaQuery.of(context).size.width < 1600
                                      ? 2
                                      : 3,
                              childAspectRatio: 16 / 10,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: [
                              for (final item in snapshot.data!) ...[
                                Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  margin: EdgeInsets.zero,
                                  child: FutureBuilder(
                                    future: item.getFileImageDisplays(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState != ConnectionState.done) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (snapshot.hasError || snapshot.data?.isNotEmpty != true) {
                                        return Center(
                                          child: GsaWidgetError(snapshot.error?.toString() ?? 'No data found.'),
                                        );
                                      }

                                      return Stack(
                                        children: [
                                          Image.memory(
                                            snapshot.data!.first,
                                            width: MediaQuery.of(context).size.width,
                                            height: MediaQuery.of(context).size.height,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: kElevationToShadow[16],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            item.label,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            for (final action in <({
                                                              IconData icon,
                                                              String tooltip,
                                                              VoidCallback? onTap,
                                                            })>{
                                                              (
                                                                icon: Icons.edit,
                                                                tooltip: 'Edit the review parameters.',
                                                                onTap: () async {
                                                                  await Navigator.of(context).push(
                                                                    MaterialPageRoute<void>(
                                                                      builder: (BuildContext context) => LvRouteConfigure(
                                                                        document: item,
                                                                      ),
                                                                    ),
                                                                  );
                                                                  setState(() {});
                                                                },
                                                              ),
                                                              (
                                                                icon: Icons.reviews,
                                                                tooltip: 'Add a new document version for verification.',
                                                                onTap: () async {
                                                                  final file = await LvServiceFiles.instance.getFile(
                                                                    LvServiceFilesType.document,
                                                                  );
                                                                  if (file == null) return;
                                                                  const GsaWidgetOverlayContentBlocking().openDialog(context);
                                                                  try {
                                                                    if (file.pagesNumber != item.pages) {
                                                                      const GsaWidgetOverlayAlert(
                                                                        title: 'Error',
                                                                        message: 'Page number does not match.',
                                                                      ).openDialog(context);
                                                                      return;
                                                                    }
                                                                    final storedFile = await LvServiceFiles.instance.storeFile(
                                                                      fileBytes: file.fileBytes,
                                                                      fileType: file.fileType,
                                                                    );
                                                                    final comparisonDocument = LvModelDocumentRevision(
                                                                      id: -1,
                                                                      documentId: item.id,
                                                                      createdAt: DateTime.now(),
                                                                      filePath: storedFile.filePath,
                                                                      fileImageDisplayPaths: storedFile.fileImageDisplayPaths,
                                                                      successConfigurationIds: [],
                                                                      errorConfigurationIds: [],
                                                                    );
                                                                    final comparisonDocumentId =
                                                                        await LvServiceDatabase.instance.insertDocumentRevision(
                                                                      comparisonDocument,
                                                                    );
                                                                    comparisonDocument.id = comparisonDocumentId;
                                                                    Navigator.pop(context);
                                                                    await Navigator.of(context).push(
                                                                      MaterialPageRoute<void>(
                                                                        builder: (BuildContext context) => LvRouteReview(
                                                                          document: item,
                                                                          comparisonDocument: comparisonDocument,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  } catch (e) {
                                                                    Navigator.pop(context);
                                                                    GsaWidgetOverlayAlert(
                                                                      title: 'Error',
                                                                      message: '$e',
                                                                    ).openDialog(context);
                                                                  }
                                                                },
                                                              ),
                                                              (
                                                                icon: Icons.history,
                                                                tooltip: 'Review revision data.',
                                                                onTap: () {
                                                                  Navigator.of(context).push(
                                                                    MaterialPageRoute<void>(
                                                                      builder: (BuildContext context) => LvRouteDocumentRevisions(
                                                                        document: item,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              (
                                                                icon: Icons.delete,
                                                                tooltip: 'Delete the document entry.',
                                                                onTap: () async {
                                                                  final confirmed = await GsaWidgetOverlayConfirmation(
                                                                    'Are you sure you want to delete "${item.label}"?',
                                                                  ).openDialog(context);
                                                                  if (confirmed == true) {
                                                                    const GsaWidgetOverlayContentBlocking().openDialog(context);
                                                                    try {
                                                                      await LvServiceDatabase.instance.removeDocument(item.id);
                                                                      LvDataDocuments.instance.documentRemove(item);
                                                                      try {
                                                                        await LvServiceFiles.instance.deleteDocumentFiles(item);
                                                                      } catch (e) {
                                                                        debugPrint('Error deleting document files: $e');
                                                                      }
                                                                      Navigator.pop(context);
                                                                    } catch (e) {
                                                                      debugPrint('Error performing delete operation: $e');
                                                                      Navigator.pop(context);
                                                                      GsaWidgetOverlayAlert(
                                                                        title: 'Error',
                                                                        message: '$e',
                                                                      ).openDialog(context);
                                                                    }
                                                                  }
                                                                },
                                                              ),
                                                            })
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 8),
                                                                child: Tooltip(
                                                                  message: action.tooltip,
                                                                  child: OutlinedButton(
                                                                    child: Icon(action.icon),
                                                                    onPressed: action.onTap,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    LvDataDocuments.instance.removeListener(callback: _onDocumentUpdates);
    super.dispose();
  }
}
