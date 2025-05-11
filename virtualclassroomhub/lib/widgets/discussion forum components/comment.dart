import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment({super.key,
  required this.text,
  required this.user,
  required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8)
      ),
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(15),
      child: Column(
            children: [
              //text
              Text(text),
              const SizedBox(height: 5,),
              //user
              Text(user,style: TextStyle(color: Colors.grey[400]),),
              
              //time
              Text(time,style: TextStyle(color: Colors.grey[400]),),

           //   const SizedBox(height: 10,),

              //display reply and all replies buttons
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     // Reply Button
              //     TextButton(
              //       onPressed: () {
              //       },
              //       child: const Text("Reply"),
              //     ),
              //     // Display All Replies Button
              //     TextButton(
              //       onPressed: () {
              //         // Navigator.push(
              //         //   context,
              //         //   MaterialPageRoute(
              //         //     builder: (context) => RepliesScreen(
              //         //       postId: postId,
              //         //       commentId: commentId,
              //         //     ),
              //         //   ),
              //        // );
              //       },
              //       child: const Text("View Replies"),
              //     ),
              //   ],
              // ),
            ],
      ),

    );
  }
}
