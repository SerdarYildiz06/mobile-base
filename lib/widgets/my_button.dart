import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.text,
    this.onTap,
    this.margin,
    this.loading = false,
    this.color = CupertinoColors.systemGreen,
    this.textColor = Colors.white,
    this.icon,
    this.iconLeft = false,
    this.borderRadius = 40,
    this.padding = 8,
    this.padding2 = 6,
    this.fontWeight = FontWeight.w600,
    this.side,
  });

  final String text;
  final Function()? onTap;
  final EdgeInsetsGeometry? margin;
  final bool loading;
  final Color color;
  final Color textColor;
  final Widget? icon;
  final bool iconLeft;
  final double borderRadius;
  final double padding;
  final double padding2;
  final FontWeight fontWeight;
  final BorderSide? side;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ),
    );
    return CupertinoButton.filled(
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: fontWeight,
        ),
      ),
      onPressed: onTap,
    );
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: side ?? BorderSide.none,
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Center(
          child: !loading
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Opacity(opacity: iconLeft ? 1 : 0, child: icon),
                      ],
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: padding),
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: fontWeight,
                            ),
                          )),
                      if (icon != null && iconLeft == false) ...[
                        Opacity(opacity: iconLeft == false ? 1 : 0, child: icon),
                      ],
                    ],
                  ),
                )
              : const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
        ),
      ),
    );
  }
}
