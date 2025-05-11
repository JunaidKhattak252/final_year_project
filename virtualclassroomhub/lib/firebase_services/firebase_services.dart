import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//signup
//   Future<dynamic> signUpUser(String email,String password,String role){
//     bool flag=false;
//     return _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password).then((UserCredential userCredential){
//           flag=true;
//           String customUID=DateTime.now().millisecondsSinceEpoch.toString();
//           return _firestore.collection('users').doc(customUID).set({
//             'email':email,
//             'role':role,
//             'uid':customUID
//           });
//     }).then((_){
//       flag=true;
//       print('user signedup successfully');
//     }).catchError((error){
//       flag=false;
//       print('Error'+error);
//     });
//   }

  //signup2222
  // Future<bool> signUpUser(String email, String password, String role) {
  //   bool flag = false;
  //
  //   return _auth
  //       .createUserWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   )
  //       .then((UserCredential userCredential) async {
  //     await userCredential.user!.sendEmailVerification();
  //     await _auth.currentUser!.reload();
  //     User? currentUser = _auth.currentUser;
  //
  //     if (currentUser != null && currentUser.emailVerified) {
  //       String customUID = DateTime.now().millisecondsSinceEpoch.toString();
  //       await _firestore.collection('users').doc(customUID).set({
  //         'email': email,
  //         'role': role,
  //         'uid': customUID,
  //       });
  //     }
  //   }).then((_) {
  //
  //     flag = true;
  //     print('User signed up and verified successfully');
  //     return flag;
  //   }).catchError((error) {
  //     flag = false;
  //     print('Please verified your email');
  //     return flag;
  //   });
  // }


  //signup3333
  Future<bool> signUpUser(String email, String password, String role) async {
    bool flag = false;

    try {
      // Create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email
      await userCredential.user!.sendEmailVerification();
      print("Verification email sent. Please check your inbox.");

      flag = true; // Indicate that the sign-up was successful
    } catch (error) {
      flag=false;
      print('Error during sign-up: $error');
    }

    return flag;
  }






  //login
  // Future loginUser(String email, String password) {
  //   return _auth.signInWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   ).then((UserCredential userCredential) {
  //     User? user = userCredential.user;
  //
  //     // Fetch role based on UID from Firestore
  //     if (user != null) {
  //       return _firestore.collection('users').doc(user.uid).get().then((DocumentSnapshot snapshot) {
  //         return snapshot['role'].toString();
  //       }).catchError((error) {
  //         print('Error fetching role from Firestore: $error');
  //         return null;
  //       });
  //     } else {
  //       return Future.error('User is null after sign-in.');
  //     }
  //   }).catchError((error) {
  //     // Handle errors for Firebase Authentication
  //     print('Error during login: $error');
  //     return null;
  //   });
  // }





  //login01
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot snapshot = querySnapshot.docs.first;

          // Check if the document exists and fetch the custom UID and role
          if (snapshot.exists) {
            String customUID = snapshot['uid'];
            String? role = snapshot['role'].toString();
            return {'success': true, 'role': role, 'uid': customUID};
          } else {
            print('No user document found for email: $email');
            return {'success': false, 'role': null, 'uid': null};
          }
        } else {
          print('No user found with the provided email.');
          return {'success': false, 'role': null, 'uid': null};
        }
      } else {
        print('verify your email');
        return {'success': false, 'role': null, 'uid': null};
      }
      // Fetch the custom UID based on email or another identifier
    } catch (error) {
      // Handle errors during login or fetching role
      print('Error during login or fetching role: $error');
      return {'success': false, 'role': null, 'uid': null};
    }
  }

  //reset password
  Future<bool> resetPassword(String email) {
    bool flag = false;
    return _auth.sendPasswordResetEmail(email: email).then((value) {
      flag = true;
      print('check your email,we have sent you email to recover your password');
      return flag;
    }).onError((error, stackTrace) {
      flag = false;
      print(error);
      return flag;
    });
  }









  //isverified

}
