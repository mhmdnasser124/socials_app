import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:socials_app/core/UI/resources/values_manager.dart';

import 'custom_cached_image.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  final TransformationController _transformationController =
      TransformationController();
  final double _minScale = 1.0;
  final double _maxScale = 4.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => context.pop(),
        child: Center(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: _minScale,
            maxScale: _maxScale,
            panEnabled: true,
            scaleEnabled: true,
            child: GestureDetector(
              onTap: () {},
              child: Hero(
                tag: widget.heroTag ?? widget.imageUrl,
                child: CustomCachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: AppSize.sWidth,
                  height: AppSize.sHeight,
                  fit: BoxFit.contain,
                  borderRadius: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
