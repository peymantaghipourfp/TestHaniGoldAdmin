

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BlinkingSvg extends StatefulWidget {
  const BlinkingSvg({
    super.key,
    required this.assetPath,
    required this.color,
    this.size = 22,
  });

  final String assetPath;
  final Color color;
  final double size;

  @override
  State<BlinkingSvg> createState() => _BlinkingSvgState();
}

class _BlinkingSvgState extends State<BlinkingSvg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.2,
        end: 1.0,
      ).animate(_controller),
      child: SvgPicture.asset(
        widget.assetPath,
        height: widget.size,
        colorFilter: ColorFilter.mode(
          widget.color,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}