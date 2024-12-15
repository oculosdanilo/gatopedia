import 'package:flutter/material.dart';

class LoadingImage extends StatefulWidget {
  const LoadingImage({super.key});

  @override
  State<LoadingImage> createState() => _LoadingImageState();
}

class _LoadingImageState extends State<LoadingImage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late CurvedAnimation _animCurve;
  late Animation<double> _anim;

  bool alt = false;
  bool cicloAlt = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        setState(() {
          if (_anim.value < 0.5) {
            alt = !alt;
          }
        });
      });
    _animCurve = CurvedAnimation(parent: _animController, curve: Curves.easeInCubic);
    _anim = Tween<double>(begin: 1, end: 0).animate(_animCurve);

    _animController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _anim.value,
      child: ClipOval(
        child: Container(
          color: alt ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
