import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:socials_app/core/UI/resources/locale_keys.dart';
import 'package:socials_app/core/UI/resources/values_manager.dart';

class SocialsQuickNav extends StatelessWidget {
  const SocialsQuickNav({
    super.key,
    required this.currentTab,
    required this.onMapTap,
    required this.onSocialsTap,
    required this.onMyUnitTap,
    required this.onAddTap,
  });

  final QuickNavTab currentTab;
  final VoidCallback onMapTap;
  final VoidCallback onSocialsTap;
  final VoidCallback onMyUnitTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    final size = MediaQuery.of(context).size;
    final double navItemExtent = (size.width / 6.2).clamp(52.0, 74.0);
    final double iconExtent = (navItemExtent * 0.38).clamp(22.0, 30.0);
    final double addOuter = (navItemExtent * 0.92).clamp(54.0, 80.0);
    final double addInner = addOuter * 0.84;

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.all(AppSize.s4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: AppSize.s40 + AppSize.s4,
                offset: Offset(0, AppSize.s4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuickNavItem(
                icon: Icons.alt_route_rounded,
                label: LocaleKeys.map.tr(),
                isSelected: currentTab == QuickNavTab.map,
                onTap: onMapTap,
                extent: navItemExtent,
                iconSize: iconExtent,
              ),
              SizedBox(width: AppSize.s6),
              _QuickNavItem(
                icon: Icons.people_alt,
                label: LocaleKeys.socials.tr(),
                isSelected: currentTab == QuickNavTab.socials,
                onTap: onSocialsTap,
                extent: navItemExtent,
                iconSize: iconExtent,
              ),
              SizedBox(width: AppSize.s6),
              _QuickNavItem(
                icon: Icons.folder_open,
                label: LocaleKeys.myUnit.tr(),
                isSelected: currentTab == QuickNavTab.myUnit,
                onTap: onMyUnitTap,
                extent: navItemExtent,
                iconSize: iconExtent,
              ),
              SizedBox(width: AppSize.s6),
              _AddButton(onTap: onAddTap, outerSize: addOuter, innerSize: addInner),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickNavItem extends StatelessWidget {
  const _QuickNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.extent,
    required this.iconSize,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double extent;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected ? Colors.black : Colors.black.withValues(alpha: 0.3);
    final Color textColor = isSelected ? Colors.black : Colors.black.withValues(alpha: 0.3);
    final TextStyle textStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 12,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      letterSpacing: -0.45,
      height: 2.08,
    );

    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.94,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : 0.65,
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            width: extent,
            height: extent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: iconSize + 6,
                  height: iconSize + 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black.withValues(alpha: 0.06) : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(icon, color: iconColor, size: iconSize),
                ),
                SizedBox(height: AppSize.s1),
                Text(
                  label,
                  style: textStyle.copyWith(color: textColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap, required this.outerSize, required this.innerSize});

  final VoidCallback onTap;
  final double outerSize;
  final double innerSize;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_controller.isAnimating) return;
    widget.onTap();
    await _controller.forward(from: 0);
    if (mounted) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: widget.outerSize,
          height: widget.outerSize,
          padding: EdgeInsets.all(widget.outerSize * 0.075),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: AppSize.s40 + AppSize.s4,
                offset: Offset(0, AppSize.s4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(100),
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 0.92).animate(curve),
                child: RotationTransition(
                  turns: Tween<double>(begin: 0.0, end: 0.25).animate(curve),
                  child: Container(
                    width: widget.innerSize,
                    height: widget.innerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Color(0xFF006C5D),
                          Color(0xFF03BEA4),
                          Color(0xFF016D5E),
                          Color(0xFF01A08A),
                          Color(0xFF017867),
                          Color(0xFF00B098),
                          Color(0xFF006C5D),
                        ],
                        stops: [0.0, 0.21, 0.36, 0.46, 0.62, 0.82, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.35),
                          blurRadius: AppSize.s24,
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                    child: Icon(Icons.add, size: widget.innerSize * 0.5, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum QuickNavTab { map, socials, myUnit }
