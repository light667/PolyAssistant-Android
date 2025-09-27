import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Configuration spécifique pour le web
    clientId: kIsWeb
        ? '39495723329-7umbp2plplt743kmj7ekehtha15rsplm.apps.googleusercontent.com'
        : null,
  );

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Mise à jour du profil avec le pseudo
    await userCredential.user!.updateDisplayName(username);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Méthode spécifique pour le web
        return await _signInWithGoogleWeb();
      } else {
        // Méthode pour mobile
        return await _signInWithGoogleMobile();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur Google Sign-In: $e");
      }
      rethrow;
    }
  }

  Future<UserCredential> _signInWithGoogleMobile() async {
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Connexion Google annulée par l\'utilisateur',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> _signInWithGoogleWeb() async {
    // Pour le web, utilise la méthode native de Firebase Auth
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    return await _firebaseAuth.signInWithPopup(googleProvider);
  }

  Future<UserCredential?> signInWithGitHub() async {
    try {
      const clientId = "Ov23lisp9CxpO1uOAY7H";
      const clientSecret = "9f44ec56471457918afe3b3eb5d6a11be7265ac5";

      final result = await FlutterWebAuth.authenticate(
        url:
            "https://github.com/login/oauth/authorize?client_id=$clientId&scope=read:user%20user:email",
        callbackUrlScheme: "https",
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Code GitHub non reçu');
      }

      final response = await http.post(
        Uri.parse("https://github.com/login/oauth/access_token"),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': code,
        },
      );

      final responseBody = json.decode(response.body);
      if (responseBody['access_token'] == null) {
        throw Exception('Access token GitHub non reçu');
      }

      final accessToken = responseBody['access_token'];
      final githubAuthCredential = GithubAuthProvider.credential(accessToken);
      return await _firebaseAuth.signInWithCredential(githubAuthCredential);
    } catch (e) {
      if (kDebugMode) {
        print("Erreur GitHub Sign-In: $e");
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}
