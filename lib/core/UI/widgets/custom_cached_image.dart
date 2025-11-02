import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../resources/asset_manger.dart';
import '../resources/color_manager.dart';
import '../resources/values_manager.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double borderRadius;

  const CustomCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width = AppSize.s60,
    this.height = AppSize.s60,
    this.fit = BoxFit.cover,
    this.borderRadius = AppSize.s8,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder:
          (context, url) => placeholder ?? _DefaultPlaceholder(borderRadius),
      errorWidget: (context, url, error) => errorWidget ?? DefaultErrorWidget(),
      errorListener: (value) => log("$value"),
      imageBuilder:
          (context, imageProvider) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              image: DecorationImage(image: imageProvider, fit: fit),
            ),
          ),
    );
  }
}

class _DefaultPlaceholder extends StatelessWidget {
  final double radius;

  const _DefaultPlaceholder(this.radius);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorManager.shimmerBaseColor,
      highlightColor: ColorManager.shimmerHighlightColor,
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.colorGrey1,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class DefaultErrorWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const DefaultErrorWidget({
    super.key,
    this.width = AppSize.s60,
    this.height = AppSize.s60,
    this.borderRadius = AppSize.s8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: SvgPicture.asset(
        IconsAssets.logoIcon,
        width: width,
        height: height,
      ),
    );
  }
}
