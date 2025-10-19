import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredProgressIndicator extends StatelessWidget {
  const BlurredProgressIndicator({super.key, required this.show, this.text, required this.child});
  final String? text;
  final bool show;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: show,
          child: child,
        ),
        show
            ? Container(
                color: Colors.transparent,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5, tileMode: TileMode.decal),
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Center(child: CircularProgressIndicator.adaptive()),
                            const SizedBox(height: 20),
                            if (text != null)
                              Text(
                                text!,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
