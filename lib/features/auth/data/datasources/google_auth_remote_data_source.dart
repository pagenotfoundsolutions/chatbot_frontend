class GoogleAuthResult {
  final String idToken;
  final String email;
  final String displayName;
  final String id;

  GoogleAuthResult({
    required this.idToken,
    required this.email,
    required this.displayName,
    required this.id,
  });
}

abstract class GoogleAuthRemoteDataSource {
  Future<GoogleAuthResult> googleSignIn();
  Future<void> googleSignOut();
}

class GoogleAuthRemoteDataSourceImpl implements GoogleAuthRemoteDataSource {
  // Google login is temporarily disabled.
  // final GoogleSignIn googleSignInPlugin;

  GoogleAuthRemoteDataSourceImpl();

  @override
  Future<GoogleAuthResult> googleSignIn() async {
    throw Exception('Google Sign In is temporarily disabled.');
  }

  @override
  Future<void> googleSignOut() async {
    // await googleSignInPlugin.signOut();
  }
}
