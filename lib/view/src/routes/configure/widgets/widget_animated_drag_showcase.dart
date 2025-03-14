part of '../route_configure.dart';

class _WidgetAnimatedDragShowcase extends StatefulWidget {
  const _WidgetAnimatedDragShowcase(this.document);

  final LvModelDocument document;

  @override
  _WidgetAnimatedDragShowcaseState createState() => _WidgetAnimatedDragShowcaseState();
}

class _WidgetAnimatedDragShowcaseState extends State<_WidgetAnimatedDragShowcase> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _startAnimation;
  late Animation<Offset> _endAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _startAnimation = Tween<Offset>(
      begin: Offset(60, 100),
      end: Offset(60, 100),
    ).animate(_controller);
    _endAnimation = Tween<Offset>(
      begin: Offset(60, 100),
      end: Offset(240, 240),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: 350,
            maxHeight: 350,
          ),
          child: FutureBuilder(
            future: widget.document.getFileImageDisplays(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
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
                snapshot.data!.first,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                CustomPaint(
                  painter: _PainterDragSelection(
                    _startAnimation.value,
                    _endAnimation.value,
                  ),
                  child: const SizedBox(),
                ),
                Transform.translate(
                  offset: Offset(
                    _endAnimation.value.dx - 15,
                    _endAnimation.value.dy - 15,
                  ),
                  child: Icon(
                    Icons.ads_click,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _PainterDragSelection extends CustomPainter {
  _PainterDragSelection(
    this.start,
    this.end,
  );

  final Offset start;
  final Offset end;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(
      Rect.fromPoints(start, end),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromPoints(start, end),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
