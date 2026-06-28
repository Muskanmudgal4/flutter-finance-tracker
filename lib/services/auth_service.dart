import 'package:firebase_auth/firebase_auth.dart';

/// Handles all Firebase Authentication operations.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the currently signed-in [User], or null if not signed in.
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in a user with [email] and [password].
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registers a new user with [email] and [password].
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}