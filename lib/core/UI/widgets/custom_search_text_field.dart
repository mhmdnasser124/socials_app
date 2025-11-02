import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../resources/asset_manger.dart';
import '../resources/color_manager.dart';

class CustomSearchTextField extends StatelessWidget {
  const CustomSearchTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.suffixIcon,
    this.fillColor,
  });

  final String hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      cursorHeight: 20,
      cursorColor: ColorManager.colorPrimary,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        constraints: const BoxConstraints(minHeight: 55),
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: UnconstrainedBox(
          child: SvgPicture.asset(
            IconsAssets.searchIcon,
            width: 24,
            height: 24,
          ),
        ),
        contentPadding: const EdgeInsets.all(0),
        filled: true,
        fillColor: fillColor ?? ColorManager.colorBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorManager.colorGrey3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorManager.colorGrey3),
        ),
      ),
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
