import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:generic_shop_app_content/gsac.dart';
import 'package:label_verify/models/src/model_db_document.dart';
import 'package:label_verify/models/src/model_db_document_revision.dart';
import 'package:label_verify/services/services.dart';
import 'package:label_verify/view/src/common/widgets/widget_navigation_bar.dart';
import 'package:label_verify/view/src/routes/configure/route_configure.dart';
import 'package:label_verify/view/src/routes/review/route_review.dart';

part 'widgets/widget_revision_entry.dart';

/// Route used for reviewing of any recorded historical document data.
///
class LvRouteDocumentRevisions extends StatefulWidget {
  /// Default, unnamed widget constructor.
  ///
  const LvRouteDocumentRevisions({
    super.key,
    required this.document,
  });

  /// The document identifier for which to display historical data.
  ///
  final LvModelDocument document;

  @override
  State<LvRouteDocumentRevisions> createState() => _LvRouteDocumentRevisionsState();
}

class _LvRouteDocumentRevisionsState extends State<LvRouteDocumentRevisions> {
  /// Future object implemented for retrieving any relevant revision data.
  ///
  late Future<List<LvModelDocumentRevision>> _getRevisionData;

  /// A collection of revisions collected from the [_getRevisionData] method.
  ///
  List<LvModelDocumentRevision>? _revisions;

  @override
  void initState() {
    super.initState();
    _getRevisionData = LvServiceDatabase.instance
        .getDocumentRevisionsForId(
      widget.document.id,
    )
        .then(
      (value) {
        _revisions = value;
        return _revisions!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LvWidgetNavigationBar(
            label: 'Revision Data - ${widget.document.label}',
          ),
          Expanded(
            child: FutureBuilder(
              future: _getRevisionData,
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

                final documentCollection = List.from(_revisions!)..insert(0, widget.document);

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    const Text(
                      'Compare changes, track edits, and view version history in a structured layout.\n\n'
                      'Each revision highlights modifications, additions, and deletions for clarity. '
                      'Navigation tools allow switching between versions.',
                    ),
                    const SizedBox(height: 30),
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 16 / 10,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documentCollection.length,
                      itemBuilder: (context, index) {
                        final document = documentCollection[index];
                        return _WidgetRevisionEntry(
                          index,
                          document: document,
                          originalDocument: widget.document,
                          onDocumentRemoved: () {
                            _revisions?.removeWhere((revision) => revision.id == document.id);
                            setState(() {});
                          },
                        );
                      },
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
}
