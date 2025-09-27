import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("Erreur de connexion: code=${e.code}, message=${e.message}");
      }
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Erreur lors de la connexion',
      );
    } catch (e) {
      if (kDebugMode) {
        print("Erreur inattendue lors de la connexion: $e");
      }
      throw Exception('Erreur inattendue lors de la connexion');
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(username);
        await userCredential.user!.reload();
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Erreur lors de la création du compte',
      );
    } catch (e) {
      if (kDebugMode) {
        print("Erreur inattendue lors de la création du compte: $e");
      }
      throw Exception('Erreur inattendue lors de la création du compte');
    }
  }

  Future<void> updateDisplayName(String username) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(username);
      await user.reload();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Connexion Google annulée par l\'utilisateur',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_ID_TOKEN',
          message: 'ID Token manquant lors du Google Sign-In',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) {
        print("Erreur Google Sign-In: $e");
      }
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGitHub() async {
    try {
      const clientId = "Iv23liFybkiMBB3yAQ4k";
      const clientSecret = "ea1a416659bd383c2578cb9cd3ad5370fd549884";

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
    await _googleSignIn.signOut();
  }
}
