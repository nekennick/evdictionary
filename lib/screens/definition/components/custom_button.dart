import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.icon,
    this.onPressed,
  });

  final Icon icon;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: icon,
      onPressed: onPressed as void Function()?,
      elevation: 2,
      constraints: const BoxConstraints.tightFor(
        width: 40,
        height: 40,
      ),
      shape: CircleBorder(), // Button Tròn
      fillColor: Colors.white,
    );
  }
}
