import 'package:flutter/material.dart';

import 'package:socials_app/core/UI/resources/values_manager.dart';
import 'package:socials_app/core/UI/widgets/coming_soon_badge.dart';

class SocialsAppBar extends StatelessWidget {
  const SocialsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    AppSize.refresh(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.s16, vertical: AppSize.s12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.black),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const _AvatarChip(initials: 'A', color: Color(0xFF5263F1)),
                    Positioned(left: 24, child: _AvatarChipWithImage()),
                  ],
                ),
                const SizedBox(width: 20),
                _AddChip(onTap: () => ComingSoonBadge.show(context)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black),
            onPressed: () => ComingSoonBadge.show(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: color,
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

class _AvatarChipWithImage extends StatelessWidget {
  const _AvatarChipWithImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.transparent,
        backgroundImage: const NetworkImage(
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=80&q=80',
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFF375F),
          borderRadius: BorderRadius.circular(80),
          border: Border.all(color: const Color(0xFFFF9FB4), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFC6D6), width: 1),
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
