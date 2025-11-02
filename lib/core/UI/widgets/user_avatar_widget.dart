import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../resources/asset_manger.dart';
import '../resources/color_manager.dart';

class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({
    super.key,
    required this.image,
    required this.radius,
  });

  final String? image;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ColorManager.colorWhite,
      backgroundImage: image == null || image!.isEmpty
          ? AssetImage(ImageAssets.userImage)
          : CachedNetworkImageProvider(image!),
    );
  }
}
