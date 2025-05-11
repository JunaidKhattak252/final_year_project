import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart'as path;

final FirebaseStorage _storage=FirebaseStorage.instance;
final FirebaseFirestore _firestore =FirebaseFirestore.instance;
class StoreData{
  //uplaoding video to firebase storage
  Future<String> uploadVideo(String videoUrl,String classCode,String fileName)async{
   try{
     Reference ref=_storage.ref().child('videos/${classCode}/${fileName}.mp4');

     //uplaoding file
     await ref.putFile(File(videoUrl));

     //retreiving the download url of the uploaded video
     String downloadUrl=await ref.getDownloadURL();
     return downloadUrl;

   }
    catch(e){
     throw Exception('Error $e');
    }

  }

 //saving videos info to firestore
Future<void> saveVideoData({
  required String videoDownloadUrl,
required String classCode,
required String uploaderId,
required String videoTitle})async{

    try{
      await _firestore.collection('videos').add({
        'url':videoDownloadUrl,
        'classCode':classCode,
        'uploaderId':uploaderId,
        'videoTitle':videoTitle,
        'timeStamp':FieldValue.serverTimestamp()
      });
    }
        catch(e){
      throw Exception('Error $e');
        }

}


}