import 'package:flutter/material.dart';
class Button extends StatelessWidget {
  final String? buttonName;
  final dynamic onPressed;
  final double horizontal;
  final double vertical;
  const Button({Key? key,this.buttonName,this.onPressed,required this.horizontal,required this.vertical}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      ),
      child:Text('$buttonName',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
    );
  }
}