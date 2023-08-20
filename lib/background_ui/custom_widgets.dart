

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';


class CustomCircularButton extends StatelessWidget {
  final Color color;
  final String imagePath;
  final Function() press;
  const CustomCircularButton({
    Key? key,
    required this.color,
    required this.imagePath,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: color,
          ),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          'assets/icons/google-icon-logo-svgrepo-com.svg',
          height: 40,
          width: 40,
        ),
      ),
    );
  }
}