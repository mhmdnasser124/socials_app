import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:socials_app/core/UI/pages/splash_page.dart';
import 'package:socials_app/features/socials/presentation/pages/socials_shell_page.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter(GlobalKey<NavigatorState> navigatorKey) : super(navigatorKey: navigatorKey);

  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, path: '/', initial: true),
    AutoRoute(page: SocialsShellRoute.page, path: '/home'),
  ];
}
