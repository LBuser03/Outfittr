// ModelPreviewCard — framed card containing a 2x2 collage of the four outfit
// slots. Each tile is slightly tilted for a graffiti/streetwear aesthetic.

import 'dart:math' as math;
import 'package:flutter/material.dart';


import '../models/item.dart';
import '../theme/app_theme.dart';

class ModelPreviewCard extends StatelessWidget
{
  final Item? hat;
  final Item? shirt;
  final Item? pants;
  final Item? shoes;

  const ModelPreviewCard({
    super.key,
    this.hat,
    this.shirt,
    this.pants,
    this.shoes,
  });

  static double _deg(double d) => d * math.pi / 180;

  @override
  Widget build(BuildContext context)
  {
    return Container(
      width: 260,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.inputBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentAqua.withValues(alpha: 0.35),
            offset: const Offset(-6, 0),
            blurRadius: 24,
          ),
          BoxShadow(
            color: AppColors.accentPink.withValues(alpha: 0.35),
            offset: const Offset(6, 0),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Radial gradient backdrop.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 2x2 collage grid, padded inside the card.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(child: _CollageTile(item: hat,   icon: 'assets/images/hat.png',   label: 'HAT',   angle: _deg(-5))),
                      const SizedBox(width: 10),
                      Expanded(child: _CollageTile(item: shirt, icon: 'assets/images/shirt.png', label: 'SHIRT', angle: _deg(4))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _CollageTile(item: pants, icon: 'assets/images/pants.png', label: 'PANTS', angle: _deg(3))),
                      const SizedBox(width: 10),
                      Expanded(child: _CollageTile(item: shoes, icon: 'assets/images/shoes.png', label: 'SHOES', angle: _deg(-6))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollageTile extends StatelessWidget
{
  final Item?  item;
  final String icon;
  final String label;
  final double angle;

  const _CollageTile({
    required this.item,
    required this.icon,
    required this.label,
    required this.angle,
  });

  @override
  Widget build(BuildContext context)
  {
    final bool hasImage = item != null && item!.imageUrl.isNotEmpty;

    return Transform.rotate(
      angle: angle,
      child: AspectRatio(
        aspectRatio: 1,
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item!.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _Placeholder(icon: icon, label: label),
                ),
              )
            : _Placeholder(icon: icon, label: label),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget
{
  final String icon;
  final String label;

  const _Placeholder({required this.icon, required this.label});

  @override
  Widget build(BuildContext context)
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(icon, width: 32, height: 32),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.inputBorder,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
