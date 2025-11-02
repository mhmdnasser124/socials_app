import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socials_app/core/UI/resources/values_manager.dart';

import '../../../main.dart';
import '../resources/asset_manger.dart';
import '../resources/color_manager.dart';

Future showCustomBottomSheet({
  required String title,
  required Widget content,
  Color? backgroundColor,
  double? height,
}) {
  return showModalBottomSheet(
    backgroundColor: backgroundColor,
    elevation: 0,
    context: MyApp.appContext!,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: height ?? MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    backgroundColor: ColorManager.colorWhite,
                    title: Text(
                      title,
                      style: Theme.of(MyApp.appContext!)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                    leading: SizedBox(),
                    actions: [
                      InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSize.sWidth * 0.05,
                            vertical: AppSize.s16,
                          ),
                          child: SvgPicture.asset(
                            IconsAssets.cancelIcon,
                            colorFilter: ColorFilter.mode(
                              ColorManager.colorSecondary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Theme.of(context).dividerTheme.color!,
                    height: 1,
                  ),
                  content,
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
