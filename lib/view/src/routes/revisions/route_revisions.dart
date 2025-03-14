import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:generic_shop_app_content/gsac.dart';
import 'package:label_verify/models/src/model_db_document.dart';
import 'package:label_verify/services/src/service_db.dart';
import 'package:label_verify/view/src/common/widgets/widget_navigation_bar.dart';
import 'package:label_verify/view/src/routes/review/route_review.dart';

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
              future: LvServiceDatabase.instance.getDocumentRevisionsForId(
                widget.document.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
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

                final documentCollection = List.from(snapshot.data!)..insert(0, widget.document);

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    Text(
                      'Compare changes, track edits, and view version history in a structured layout.\n\n'
                      'Each revision highlights modifications, additions, and deletions for clarity. '
                      'Navigation tools allow switching between versions.',
                    ),
                    const SizedBox(height: 30),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                        return InkWell(
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            margin: EdgeInsets.zero,
                            child: FutureBuilder<List<Uint8List>>(
                              future: document.getFileImageDisplays(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState != ConnectionState.done) {
                                  return Center(
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
                                      snapshot.data![0],
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height,
                                      fit: BoxFit.cover,
                                    ),
                                    if (index != 0)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Card(
                                          margin: EdgeInsets.zero,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Review ',
                                                ),
                                                Icon(
                                                  Icons.info_outline,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
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
                                          child: Builder(
                                            builder: (context) {
                                              final documentTime = document.createdAt as DateTime;
                                              return Text.rich(
                                                TextSpan(
                                                  text: '#${index + 1} ',
                                                  children: [
                                                    TextSpan(
                                                      text: '${documentTime.day.toString().padLeft(2, '0')}.'
                                                          '${documentTime.month.toString().padLeft(2, '0')}.'
                                                          '${documentTime.year} '
                                                          '${documentTime.hour.toString().padLeft(2, '0')}:'
                                                          '${documentTime.minute.toString().padLeft(2, '0')}:'
                                                          '${documentTime.second.toString().padLeft(2, '0')}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          onTap: index == 0
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) => LvRouteReview(
                                        document: widget.document,
                                        comparisonDocument: document,
                                      ),
                                    ),
                                  );
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
