import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatterjii/features/auth/authdatamodel.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null
          ? UserModel.fromFirebaseUser(userCredential.user!)
          : null;
    } on FirebaseAuthException catch (_) {
      return null;
    } catch (e) {
      print('An unknown error occurred: $e');
      return null;
    }
  }

  Future<UserModel?> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
        final updatedUser = _firebaseAuth.currentUser;
        final userModel = UserModel.fromFirebaseUser(updatedUser!);

        UserModel? existingUser = await getUserdata(updatedUser.uid);
        if (existingUser == null) {
          await _saveUserDataToFirestore(userModel);
        }

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Failed to sign up with email and password: $e');
      return null;
    } catch (e) {
      print('An unknown error occurred: $e');
      return null;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final userModel = UserModel.fromFirebaseUser(userCredential.user!);
        UserModel? existingUser = await getUserdata(userCredential.user!.uid);

        if (existingUser == null) {
          await _saveUserDataToFirestore(userModel);
        }

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Failed to sign in with Google: $e');
      return null;
    } catch (e) {
      print('An unknown error occurred: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  Stream<UserModel?> get user {
    return _firebaseAuth.authStateChanges().map(
          (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
        );
  }

  Future<UserModel?> getUserdata(String uid) async {
    final DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      return UserModel.fromFirestore(userSnapshot);
    }

    return null;
  }

  Future<void> _saveUserDataToFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
      });
    } catch (e) {
      print('Failed to save user data to Firestore: $e');
      throw Exception('Failed to save user data to Firestore');
    }
  }
}
