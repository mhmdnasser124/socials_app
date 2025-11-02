import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socials_app/core/UI/resources/values_manager.dart';

import '../resources/asset_manger.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';

class CustomDropdownField<T> extends StatelessWidget {
  const CustomDropdownField({
    super.key,
    required this.title,
    required this.hint,
    required this.items,
    this.controller,
    this.value,
    this.onChanged,
    this.icon,
    required this.fillColor,
    this.requiredField,
    this.titleColor,
    this.fontColor,
    this.fontWeight = FontWeight.w600,
    this.minHeight = 70,
    this.borderRadius = 8,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.prefixConstraints = const BoxConstraints(minWidth: 0, minHeight: 0),
    this.validator,
  });

  final String? title;
  final String hint;
  final List<DropdownMenuEntry<T>> items;
  final T? value;
  final TextEditingController? controller;
  final void Function(T?)? onChanged;
  final Widget? icon;
  final Color fillColor;
  final bool? requiredField;
  final Color? titleColor;
  final Color? fontColor;
  final FontWeight fontWeight;
  final double minHeight;
  final double borderRadius;
  final TextAlign textAlign;
  final EdgeInsets? contentPadding;
  final BoxConstraints? prefixConstraints;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              RichText(
                text: TextSpan(
                  text: title!,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: titleColor),
                  children: requiredField == true
                      ? [
                          TextSpan(
                            text: ' *',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: ColorManager.colorError),
                          ),
                        ]
                      : [],
                ),
              ),
            if (title != null) const SizedBox(height: 8.0),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  alignment: title == null ? Alignment.center : null,
                  constraints: BoxConstraints(
                    minHeight: field.hasError ? 0 : minHeight,
                  ),
                  child: DropdownMenu<T>(
                    width: constraints.maxWidth,
                    controller: controller,
                    initialSelection: value,
                    enableFilter: false,
                    requestFocusOnTap: false,
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: fillColor,
                      isDense: true,
                      contentPadding:
                          contentPadding ??
                          const EdgeInsets.symmetric(horizontal: 10),
                      prefixIconConstraints: prefixConstraints,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide(
                          color: field.hasError
                              ? ColorManager.colorTextFieldErrorBorder
                              : ColorManager.colorTextFieldFocusedBorder,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide(
                          color: field.hasError
                              ? ColorManager.colorTextFieldErrorBorder
                              : ColorManager.colorTextFieldFocusedBorder,
                          width: 1,
                        ),
                      ),
                      errorStyle: const TextStyle(height: 0),
                    ),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        ColorManager.colorWhite,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                      ),
                      maximumSize: WidgetStatePropertyAll(
                        Size(constraints.maxWidth, AppSize.sHeight * 0.3),
                      ),
                    ),
                    textStyle: TextStyle(
                      fontSize: FontSize.s16,
                      fontWeight: fontWeight,
                      color: fontColor ?? ColorManager.colorFontPrimary,
                    ),
                    hintText: hint,
                    selectedTrailingIcon: Transform.rotate(
                      angle: pi,
                      child: SvgPicture.asset(IconsAssets.arrowDown),
                    ),
                    trailingIcon: SvgPicture.asset(IconsAssets.arrowDown),
                    onSelected: (val) {
                      field.didChange(val);
                      onChanged?.call(val);
                    },
                    dropdownMenuEntries: items,
                  ),
                );
              },
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSize.s6,
                  horizontal: AppSize.s8,
                ),
                child: Text(
                  field.errorText!,
                  style: Theme.of(context).inputDecorationTheme.errorStyle,
                ),
              ),
          ],
        );
      },
    );
  }
}

class CustomDropDownChild extends StatelessWidget {
  const CustomDropDownChild({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
