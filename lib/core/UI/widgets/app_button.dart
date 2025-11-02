import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:socials_app/core/UI/resources/values_manager.dart';

import '../resources/color_manager.dart';
import '../resources/font_manager.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.text,
    this.icon,
    this.backgroundColor = ColorManager.colorSecondary,
    this.fontColor = Colors.white,
    this.onPressed,
    this.padding,
    this.radius = 50,
    this.fontSize,
    this.fontWeight = FontWeight.bold,
    this.textDirection,
    this.withGradiant = false,
    this.minHeight = 48,
    this.loadingMode = false,
    this.enabled = true,
    this.border,
  });

  final String? text;
  final Widget? icon;
  final Color backgroundColor;
  final void Function()? onPressed;
  final EdgeInsetsGeometry? padding;
  final double minHeight;
  final double? radius;
  final Color fontColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextDirection? textDirection;
  final bool withGradiant;
  final bool loadingMode;
  final bool enabled;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius ?? AppSize.s12),
        border: border,
      ),
      child: ElevatedButton(
        onPressed: !enabled
            ? null
            : loadingMode
            ? null
            : () {
                if (onPressed != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPressed!();
                }
              },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.grey,
          backgroundColor: Colors.transparent,
          //disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: AppSize.sWidth * 0.04,
                vertical: AppSize.s10,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? AppSize.s8),
          ),
        ),
        child: loadingMode
            ? const Center(
                child: SpinKitThreeBounce(
                  color: ColorManager.colorSpin,
                  size: AppSize.s18,
                ),
              )
            : Row(
                textDirection: textDirection,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon != null ? icon! : const SizedBox.shrink(),
                  icon != null && text != null
                      ? const SizedBox(width: AppSize.s8)
                      : const SizedBox.shrink(),
                  text != null
                      ? Text(
                          text!,
                          style: TextStyle(
                            color: fontColor,
                            fontSize: fontSize ?? FontSize.s16,
                            fontWeight: fontWeight,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
      ),
    );
  }
}
