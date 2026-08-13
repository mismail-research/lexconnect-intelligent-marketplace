import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:lexbid/core/constants/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';

@lazySingleton
class FirebaseAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService(this._auth, this._firestore);

  // ---------------- SIGN UP ----------------
  // ---------------- SIGN UP ----------------
  Future<UserEntity> signup(
      String name,
      String email,
      String password,
      String userType,
      String deviceToken,
      ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    /// ✅ SEND VERIFICATION EMAIL RIGHT AFTER ACCOUNT CREATION
    await credential.user!.sendEmailVerification();

    final normalizedRole = userType.toLowerCase();

    final collection =
    normalizedRole == 'client' ? 'clients' : 'lawyers';

    await _firestore.collection(collection).doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'userType': normalizedRole,
      'deviceTokens': [deviceToken],
      'createdAt': FieldValue.serverTimestamp(),
    });

    /// ✅ SIGN OUT IMMEDIATELY — they must verify + log in again before getting access
    await _auth.signOut();

    return UserEntity(
      uid: uid,
      name: name,
      email: email,
      userType: normalizedRole,
      deviceTokens: [deviceToken],
      emailVerified: false,
    );
  }

  // ---------------- LOGIN ----------------
  Future<UserEntity> login(
      String email,
      String password,
      String expectedUserType,
      String deviceToken,
      ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    /// ✅ REFRESH TO GET THE LATEST VERIFICATION STATUS FROM FIREBASE
    await credential.user!.reload();
    final refreshedUser = _auth.currentUser;

    if (refreshedUser == null) {
      throw AuthException("Something went wrong. Please try again.");
    }

    if (!refreshedUser.emailVerified) {
      /// Resend a fresh link so they always have a working one to click
      try {
        await refreshedUser.sendEmailVerification();
      } catch (_) {
        // Ignore resend failures (e.g. rate-limited) — earlier link may still work
      }

      await _auth.signOut();
      throw AuthException(
        "Please verify your email before logging in. We've sent a new verification link to $email.",
      );
    }

    final uid = refreshedUser.uid;

    final clientDoc =
    await _firestore.collection('clients').doc(uid).get();

    final lawyerDoc =
    await _firestore.collection('lawyers').doc(uid).get();

    if (!clientDoc.exists && !lawyerDoc.exists) {
      await _auth.signOut();
      throw AuthException("User data not found");
    }

    String actualRole;

    if (clientDoc.exists) {
      actualRole = 'client';
    } else if (lawyerDoc.exists) {
      actualRole = 'lawyer';
    } else {
      await _auth.signOut();
      throw AuthException("User data not found");
    }

    final normalizedExpected = expectedUserType.toLowerCase();

    debugPrint("EXPECTED ROLE: $normalizedExpected");
    debugPrint("ACTUAL ROLE: $actualRole");
    debugPrint("CLIENT EXISTS: ${clientDoc.exists}");
    debugPrint("LAWYER EXISTS: ${lawyerDoc.exists}");

    if (actualRole != normalizedExpected) {
      await _auth.signOut();
      throw AuthException(
        "You are not registered as a $expectedUserType",
      );
    }

    final doc = actualRole == 'client' ? clientDoc : lawyerDoc;
    final collection = actualRole == 'client' ? 'clients' : 'lawyers';

    final data = doc.data()!;

    final docRef = _firestore.collection(collection).doc(uid);

    final List<String> tokens =
    List<String>.from(data['deviceTokens'] ?? []);

    if (deviceToken.isNotEmpty && !tokens.contains(deviceToken)) {
      tokens.add(deviceToken);
      await docRef.update({'deviceTokens': tokens});
    }

    return UserEntity(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      userType: data['userType'] ?? actualRole,
      deviceTokens: tokens,
      emailVerified: true, // ✅ Only reach here if verified
    );
  }

  // ---------------- FORGOT PASSWORD ----------------
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout(String uid, String deviceToken) async {
    final clientRef = _firestore.collection('clients').doc(uid);
    final lawyerRef = _firestore.collection('lawyers').doc(uid);

    if ((await clientRef.get()).exists) {
      await clientRef.update({
        'deviceTokens': FieldValue.arrayRemove([deviceToken]),
      });
    } else if ((await lawyerRef.get()).exists) {
      await lawyerRef.update({
        'deviceTokens': FieldValue.arrayRemove([deviceToken]),
      });
    }

    await _auth.signOut();
  }
}