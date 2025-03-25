part of '../route_revisions.dart';

class _WidgetRevisionEntry extends StatefulWidget {
  const _WidgetRevisionEntry(
    this.index, {
    required this.document,
    required this.originalDocument,
    required this.onDocumentRemoved,
  });

  /// Order index of the specified element.
  ///
  final int index;

  /// [LvModelDocument] or [LvModelDocumentRevision] object specified for this widget entry.
  ///
  final dynamic document;

  /// The document on which any revisions are based.
  ///
  final LvModelDocument originalDocument;

  /// Method invoked on document revision removal, used for updating of the parent view.
  ///
  final Function() onDocumentRemoved;

  @override
  State<_WidgetRevisionEntry> createState() => __WidgetRevisionEntryState();
}

class __WidgetRevisionEntryState extends State<_WidgetRevisionEntry> {
  late Future<List<Uint8List>> _getImageDisplays;

  @override
  void initState() {
    super.initState();
    _getImageDisplays = widget.document.getFileImageDisplays();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        margin: EdgeInsets.zero,
        child: FutureBuilder<List<Uint8List>>(
          future: _getImageDisplays,
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
                  snapshot.data![0],
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: widget.index != 0
                            ? const [
                                Text(
                                  'Review ',
                                ),
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                ),
                              ]
                            : const [
                                Text(
                                  'Configure ',
                                ),
                                Icon(
                                  Icons.edit,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final documentTime = widget.document.createdAt as DateTime;
                                return Text.rich(
                                  TextSpan(
                                    text: '#${widget.index + 1} ',
                                    children: [
                                      TextSpan(
                                        text: '${documentTime.day.toString().padLeft(2, '0')}.'
                                            '${documentTime.month.toString().padLeft(2, '0')}.'
                                            '${documentTime.year} '
                                            '${documentTime.hour.toString().padLeft(2, '0')}:'
                                            '${documentTime.minute.toString().padLeft(2, '0')}:'
                                            '${documentTime.second.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          if (widget.index != 0)
                            OutlinedButton(
                              child: const Text('DELETE'),
                              onPressed: () async {
                                final confirmed = await GsaWidgetOverlayConfirmation(
                                  'Delete document revision #${widget.index + 1}?',
                                ).openDialog(context);
                                if (confirmed == true) {
                                  const GsaWidgetOverlayContentBlocking().openDialog(context);
                                  try {
                                    await LvServiceDatabase.instance.removeDocumentRevision(widget.document.id);
                                    await LvServiceFiles.instance.deleteDocumentRevisionFiles(widget.document);
                                    Navigator.pop(context);
                                    widget.onDocumentRemoved();
                                  } catch (e) {
                                    debugPrint('Error deleting document revision: $e');
                                    Navigator.pop(context);
                                    GsaWidgetOverlayAlert(message: '$e').openDialog(context);
                                  }
                                }
                              },
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
      onTap: widget.index == 0
          ? () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => LvRouteConfigure(
                    document: widget.originalDocument,
                  ),
                ),
              );
            }
          : () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => LvRouteReview(
                    document: widget.originalDocument,
                    comparisonDocument: widget.document,
                  ),
                ),
              );
            },
    );
  }
}
