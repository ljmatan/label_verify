import 'package:flutter/material.dart';
import 'package:generic_shop_app_content/gsac.dart';
import 'package:label_verify/config.dart';

/// Splash route displayed on every app startup.
///
/// The user is presented with this screen contents until all of the app resources are allocated.
///
class LvRouteSplash extends StatefulWidget {
  /// Default, unnamed widget constructor.
  ///
  const LvRouteSplash({super.key});

  @override
  State<LvRouteSplash> createState() => _LvRouteSplashState();
}

class _LvRouteSplashState extends State<LvRouteSplash> {
  /// The number of visible dots displayed with the custom loading indicator.
  ///
  int _dotNumber = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: LvConfig.instance.init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 36),
                  StatefulBuilder(
                    builder: (context, setState) {
                      Future.delayed(
                        const Duration(milliseconds: 300),
                        () {
                          if (_dotNumber < 2) {
                            _dotNumber++;
                          } else {
                            _dotNumber = 0;
                          }
                          if (mounted) setState(() {});
                        },
                      );
                      return Text.rich(
                        TextSpan(
                          text: 'Initialising the application.\n\nThis may take a few minutes.',
                          children: [
                            for (int i = 0; i < 2; i++)
                              TextSpan(
                                text: '.',
                                style: TextStyle(
                                  color: i < _dotNumber ? Colors.black : Colors.transparent,
                                ),
                              ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: GsaWidgetError(
                snapshot.error.toString(),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
