import 'package:flutter/material.dart';

class AnimatedLocationImage extends StatefulWidget {
  const AnimatedLocationImage({super.key});

  @override
  State<AnimatedLocationImage> createState() => _AnimatedLocationImageState();
}

class _AnimatedLocationImageState extends State<AnimatedLocationImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -_animation.value),
        child: child,
      ),
      child: Image.asset(
        'assets/images/img_main.png',
        width: 240,
        height: 240,
        fit: BoxFit.cover,
      ),
    );
  }
}
