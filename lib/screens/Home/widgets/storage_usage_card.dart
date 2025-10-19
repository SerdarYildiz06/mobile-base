import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_lerp/animated_text_lerp.dart';
// No material usage to keep Cupertino-first design

class StorageUsageCard extends StatelessWidget {
  final double usedGb;
  final double totalGb;
  final VoidCallback onStartScan;

  const StorageUsageCard({
    super.key,
    required this.usedGb,
    required this.totalGb,
    required this.onStartScan,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = totalGb > 0 ? (usedGb / totalGb).clamp(0.0, 1.0) : 0.0;
    final textTheme = CupertinoTheme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        final double horizontalPadding = 14;
        final double barHeight = 11;
        final double buttonHeight = 54;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Storage Usage',
                      style: textTheme.navLargeTitleTextStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A0D2F),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedNumberText(
                        (usedGb / 1024),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        formatter: (value) => value.toStringAsFixed(2),
                        style: textTheme.textStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A0D2F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedNumberText(
                            (totalGb / 1024),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            formatter: (value) => value.toStringAsFixed(2),
                            style: textTheme.textStyle.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFA8A8A8),
                            ),
                          ),
                          Text(
                            ' GB used',
                            style: textTheme.textStyle.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFA8A8A8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Progress bar with indicator (animated)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: percent),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, animatedPercent, _) {
                  final double clamped = animatedPercent.clamp(0.0, 1.0);
                  return SizedBox(
                    width: double.infinity,
                    height: barHeight + 6,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Track
                        Container(
                          width: cardWidth - horizontalPadding * 2,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        // Fill (animated)
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (clamped + 0.01).clamp(0.0, 1.0),
                          child: Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGreen,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        // Knob (animated)
                        Positioned(
                          left: ((cardWidth - horizontalPadding * 2) * clamped).clamp(0.0, (cardWidth - horizontalPadding * 2) - 9),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGreen,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3D000000),
                                  blurRadius: 1,
                                ),
                              ],
                              border: Border.all(color: CupertinoColors.white, width: 3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Used more ',
                      style: textTheme.textStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8B8B8B),
                      ),
                    ),
                    TextSpan(
                      text: 'than ${(percent * 100).toStringAsFixed(0)}%',
                      style: textTheme.textStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemGreen,
                      ),
                    ),
                    TextSpan(
                      text: ' of the space on your smartphone',
                      style: textTheme.textStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8B8B8B),
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 16),
              // Divider(color: CupertinoColors.systemGrey5),
              // const SizedBox(height: 16),
              // SizedBox(
              //   width: double.infinity,
              //   height: buttonHeight,
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(10),
              //     child: CupertinoButton(
              //       padding: EdgeInsets.zero,
              //       color: const Color(0xFF2E2F31),
              //       onPressed: onStartScan,
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           const SizedBox(width: 8),
              //           Text(
              //             'Start Smart Scan',
              //             style: textTheme.textStyle.copyWith(
              //               color: CupertinoColors.white,
              //               fontSize: 14,
              //               fontWeight: FontWeight.w500,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
