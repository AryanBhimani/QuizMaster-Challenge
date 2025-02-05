import 'package:flutter/material.dart';
import 'package:quizmaster_challenge/Services/Colors.dart';

//We are going to design our own button

class Button extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const Button({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    //Query width and height of device for being fit or responsive
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: size.width *.9,
      height: 55,
      decoration: BoxDecoration(
        color: green,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: black, width: 1.5),
      ),

      child: TextButton(
        onPressed: onPressed,
        child: Text(label,style: const TextStyle(color: white),),
      ),
    );
  }
}