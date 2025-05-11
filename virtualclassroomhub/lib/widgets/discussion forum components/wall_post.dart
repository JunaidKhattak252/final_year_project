import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:virtualclassroomhub/widgets/discussion%20forum%20components/comment.dart';
import 'package:virtualclassroomhub/widgets/discussion%20forum%20components/comment_button.dart';
import 'package:virtualclassroomhub/widgets/discussion%20forum%20components/delete_button.dart';
import 'package:virtualclassroomhub/widgets/discussion%20forum%20components/helper_methods.dart';
import 'package:virtualclassroomhub/widgets/discussion%20forum%20components/like_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String>likes;
  final String? voiceUrl;
  const WallPost({super.key,
  required this.message,
  required this.user,
  required this.postId,
  required this.likes,
  required this.time,
  this.voiceUrl});

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  // Audio player instance
  FlutterSoundPlayer? _audioPlayer;
  bool _isPlaying = false;
  //current user
  final currentUser=FirebaseAuth.instance.currentUser!;
  bool isLiked=false;

  //comment text controller
  final _commentTextController=TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLiked=widget.likes.contains(currentUser.email);
    _audioPlayer = FlutterSoundPlayer();
    initPlayer();
  }
  //initialize player
  Future<void> initPlayer() async {
    await _audioPlayer!.openPlayer();
  }

  // Play or stop audio
  void toggleAudioPlayback() async {
    if (widget.voiceUrl == null) return;

    if (_isPlaying) {
      await _audioPlayer!.stopPlayer();
    } else {
      await _audioPlayer!.startPlayer(
          fromURI: widget.voiceUrl!,
      whenFinished: (){
            setState(() {
              _isPlaying=false;
            });
      });
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  //toggle like
  void toggleLike(){
    setState(() {
      isLiked = !isLiked;
    });

    //access document in firebasefirestore
    DocumentReference postRef=
        FirebaseFirestore.instance.collection("User Posts").doc(widget.postId);

    if(isLiked){
     //if the post is now liked...add the useremail to likes field
      postRef.update({
        'Likes':FieldValue.arrayUnion([currentUser.email])
      });
    }
    
    else{
      postRef.update({
        'Likes':FieldValue.arrayRemove([currentUser.email])
      });
    }

  }


  //add a comment
  void addComment(String commentText){
   FirebaseFirestore.instance
       .collection("User Posts")
       .doc(widget.postId)
       .collection("Comments").add({
        "CommentText":commentText,
         "CommentBy":currentUser.email,
         "CommentTime":Timestamp.now()
   });
  }

  //show a dialog for adding comments
   void showCommentDialog(){
    showDialog(
        context: context,
        builder:(context)=>AlertDialog(
          title: Text("Add a comment"),
          content: TextField(
            controller: _commentTextController,
            decoration: InputDecoration(
              hintText:"Write a comment..."
            ),
          ),

          actions: [
            //cancel button
            TextButton(
                onPressed:(){
                  Navigator.pop(context);
                  _commentTextController.clear();
                } ,
                child: Text("Cancel")),

            //save button
            TextButton(onPressed: (){
              if(_commentTextController.text.isNotEmpty){
                //add a comment
                addComment(_commentTextController.text);
              }
              Navigator.pop(context);
              _commentTextController.clear();

            }, child: Text("Post"))
          ],
        ) );
   }

  //delete a post
  void deletePost(){
    //show dialog for confirmation
    showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: Text("Delete post"),
          content: Text("Are you sure you want to delete this post"),
          actions: [
            //cancel button
            TextButton(
                onPressed:()=>Navigator.pop(context), 
                child: Text("Cancel")),

            //delete button
            TextButton(
                onPressed: ()async{
                  //delete the comments first from firestorex
                  // (if only delete post,the comment will still store in
                  // the firestore)
                  final commentDocs=await FirebaseFirestore.instance
                      .collection("User Posts")
                      .doc(widget.postId)
                      .collection("Comment")
                      .get();

                  for(var doc in commentDocs.docs){
                    await FirebaseFirestore.instance
                        .collection("User Posts")
                        .doc(widget.postId)
                        .collection("Comments")
                        .doc(doc.id)
                        .delete();
                  }

                  // Check if there is a voiceUrl and delete the file from Firebase Storage
                  if (widget.voiceUrl != null) {
                    try {
                      await FirebaseStorage.instance.refFromURL(widget.voiceUrl!).delete();
                      print("Voice file deleted successfully.");
                    } catch (e) {
                      print("Failed to delete voice file: $e");
                    }
                  }

              //then delete the post
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value)=>print("post deleted"))
                  .catchError((error)=>print("failed to delete post $error"));

                  Navigator.pop(context);

                },
                child: Text("Delete"))
          ],
        ));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8)
      ),
      margin: EdgeInsets.only(top: 25,left: 25,right: 25),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //profile pic
          // Container(
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: Colors.grey[400]
          //   ),
          //   child: Icon(Icons.person),
          //  // color: Colors.white,
          // ),

          //wall post

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              //group of texts
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //message
                  Text(widget.message.isNotEmpty
                      ? widget.message
                      : "Voice Post"),
                  const SizedBox(height: 5,),

                  //user
                  Text(widget.user,style: TextStyle(color: Colors.grey[400]),),
                  Text(" . "),
                  Text(widget.time,style: TextStyle(color: Colors.grey[400]),)


                ],
              ),

              //delete button
              if(widget.user==currentUser.email)
                DeleteButton(onTap: deletePost)
            ],
          ),
          const SizedBox(width: 20,),

          //voicepostt row
          if (widget.voiceUrl != null)
            Row(
              children: [
                IconButton(
                  onPressed: toggleAudioPlayback,
                  icon: Icon(
                    _isPlaying ? Icons.stop : Icons.play_arrow,
                    color: Colors.blue,
                  ),
                ),
                Text(_isPlaying ? "Playing..." : "Play Audio"),
              ],
            ),

          ///buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //like button
              Column(
                children: [
                  //like button
                  LikeButton(isLiked: isLiked, onTap: toggleLike),

                  //Like counts
                  SizedBox(height: 5,),
                  Text(widget.likes.length.toString(),style: TextStyle(color: Colors.grey),)
                ],
              ),
              const SizedBox(width: 10,),

              //comment button
              Column(
                children: [
                  //comment button
                  CommentButton(onTap: showCommentDialog),

                  //comment counts
                  SizedBox(height: 5,),
                  Text("0",style: TextStyle(color: Colors.grey),)
                ],
              ),

            ],
          ),

          const SizedBox(height: 10,),
          //comments under the post
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("User Posts").doc(widget.postId).
              collection("Comments").
              orderBy("CommentTime",descending: true)
                  .snapshots(),
              builder: (context,snapshot){
                //show loading circle if no data
                if(!snapshot.hasData){
                  return const Center(child: CircularProgressIndicator(),);
                }
                return ListView(
                  shrinkWrap: true, //for nested lists
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc){
                    //get the comments from firebase
                    final commentData=doc.data() as Map<String,dynamic>;

                    //return the comments
                    return Comment(
                        text: commentData["CommentText"],
                        user: commentData["CommentBy"],
                        time: formatData(commentData["CommentTime"]));
                  }).toList(),
                );
              })
        ],
      ),
    );
  }
}
