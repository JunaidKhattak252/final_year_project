import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModuleCard extends StatelessWidget {
  final String moduleName, imagePath;
  final VoidCallback onTap;
  const ModuleCard(
      {super.key,
      required this.moduleName,
      required this.imagePath,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(15), // Rounded ripple effect
      splashColor: Colors.blue.withAlpha(100),
      highlightColor: Colors.blue.withOpacity(0.1),
      child: Card(

        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.deepPurple.shade200,
                  borderRadius: BorderRadius.circular(5),),
                child: Text(
                  moduleName,
                  style: TextStyle(fontSize: 15, fontWeight:FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
