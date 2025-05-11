import 'package:flutter/material.dart';

class HeadingContainer extends StatelessWidget {
  final String title;
  const HeadingContainer({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 400,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade300,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          topLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
          bottomLeft: Radius.circular(0)
        ),
        border: Border.all(color: Colors.black,width: 1),

          boxShadow: const [
            BoxShadow(color: Colors.black, blurRadius: 10)
          ]),

      child: Center(
          child: Text(title, textAlign:TextAlign.center,style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),)),
    );
  }
}
