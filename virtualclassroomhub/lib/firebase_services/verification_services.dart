import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkEmailVerificationAndStoreData(String email, String password, String role) async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Refresh user data to check for verification
      await user.reload();
      user = _auth.currentUser;

      // Check if the email is verified
      if (user!.emailVerified) {
        // Email is verified, now store the user data in Firestore
        String customUID = DateTime.now().millisecondsSinceEpoch.toString();
        await _firestore.collection('users').doc(customUID).set({
          'email': email,
          'role': role,
          'uid': customUID,
          'emailVerified': true, // Mark as verified
        });

        print('User data stored successfully.');
        return true;
      } else {
        print("Email is not verified yet.");
        return false;
      }
    }

    print("No user is signed in.");
    return false;
  }

}