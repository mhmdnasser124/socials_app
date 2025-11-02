import 'package:flutter/material.dart';

import 'package:socials_app/core/UI/resources/values_manager.dart';
import 'package:socials_app/features/socials/presentation/theme/socials_theme.dart';

class ComingSoonBadge extends StatefulWidget {
  const ComingSoonBadge({super.key});

  static void show(BuildContext context, {Offset? offset}) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => _ComingSoonOverlay(offset: offset),
    );
  }

  @override
  State<ComingSoonBadge> createState() => _ComingSoonBadgeState();
}

class _ComingSoonBadgeState extends State<ComingSoonBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSize.s20, vertical: AppSize.s12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSize.s16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: AppSize.s20,
                offset: Offset(0, AppSize.s8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars_rounded,
                size: AppSize.s20,
                color: SocialsTheme.accent,
              ),
              SizedBox(width: AppSize.s8),
              Text(
                'This feature is coming soon',
                style: TextStyle(
                  fontSize: AppSize.s14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonOverlay extends StatelessWidget {
  const _ComingSoonOverlay({this.offset});

  final Offset? offset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Transform.translate(
              offset: offset ?? Offset.zero,
              child: const ComingSoonBadge(),
            ),
          ),
        ),
      ),
    );
  }
}

