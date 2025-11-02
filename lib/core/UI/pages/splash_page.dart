import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

import 'package:socials_app/core/UI/resources/values_manager.dart';
import 'package:socials_app/features/socials/presentation/theme/socials_theme.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _slideController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _slideController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) {
      context.router.replaceNamed('/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return Scaffold(
      backgroundColor: SocialsTheme.scaffoldBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: EdgeInsets.all(AppSize.s28),
                      decoration: BoxDecoration(
                        color: SocialsTheme.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: SocialsTheme.accent.withValues(alpha: 0.4),
                            blurRadius: AppSize.s40,
                            spreadRadius: AppSize.s10,
                          ),
                        ],
                      ),
                      child: Icon(Icons.forum_rounded, size: AppSize.s(72), color: Colors.white),
                    ),
                  ),
                  SizedBox(height: AppSize.s36),
                  Text(
                    'Socials',
                    style: TextStyle(
                      fontSize: AppSize.s(40),
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: AppSize.s(2),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: AppSize.s6),
                  Text(
                    'app',
                    style: TextStyle(
                      fontSize: AppSize.s(20),
                      fontWeight: FontWeight.w400,
                      color: SocialsTheme.textSecondary,
                      letterSpacing: AppSize.s(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
