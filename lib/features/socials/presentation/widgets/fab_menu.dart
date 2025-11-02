import 'dart:math' as math;

import 'package:flutter/material.dart';

class FabMenu extends StatefulWidget {
  const FabMenu({super.key});

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _handleNavigation(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$label" is coming soon.')),
    );
    _toggle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Positioned(
            bottom: 70,
            right: 0,
            child: _FabOption(
              label: 'Map',
              icon: Icons.map_outlined,
              visible: _isExpanded,
              onTap: () => _handleNavigation('Map'),
            ),
          ),
          Positioned(
            bottom: 130,
            right: 0,
            child: _FabOption(
              label: 'My Unit',
              icon: Icons.home_outlined,
              visible: _isExpanded,
              onTap: () => _handleNavigation('My Unit'),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 80,
            child: _FabOption(
              label: 'Socials',
              icon: Icons.people_outline,
              visible: _isExpanded,
              onTap: _toggle,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              onPressed: _toggle,
              child: AnimatedBuilder(
                animation: _rotation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotation.value * math.pi * 2,
                    child: child,
                  );
                },
                child: Icon(
                  _isExpanded ? Icons.close : Icons.add,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FabOption extends StatelessWidget {
  const _FabOption({
    required this.label,
    required this.icon,
    required this.visible,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: visible ? 1 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: visible ? 1 : 0,
        child: Material(
          color: colorScheme.surface,
          elevation: 4,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(32),
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(color: colorScheme.onSurface),
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
