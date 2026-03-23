// // auth_controller.dart
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../model/social_auth_model.dart';

// class SocialAuthController {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
  
//   Future<AuthResponse> loginWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return AuthResponse.failure("Google login cancelled.");

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final String? idToken = googleAuth.idToken;
//       if (idToken == null) return AuthResponse.failure("Failed to get Google ID token.");

//       return _sendTokenToBackend('google', idToken);
//     } catch (e) {
//       return AuthResponse.failure("Google sign-in error: $e");
//     }
//   }

//   Future<AuthResponse> loginWithFacebook() async {
//     try {
//       final LoginResult result = await FacebookAuth.instance.login();
//       if (result.status == LoginStatus.success) {
//        final String accessToken = result.accessToken!.tokenString;

//         return _sendTokenToBackend('facebook', accessToken);
//       } else {
//         return AuthResponse.failure("Facebook login failed: ${result.message}");
//       }
//     } catch (e) {
//       return AuthResponse.failure("Facebook sign-in error: $e");
//     }
//   }

//   Future<AuthResponse> loginWithApple() async {
//     try {
//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//       );
//       final String idToken = appleCredential.identityToken!;
//       return _sendTokenToBackend('apple', idToken);
//     } catch (e) {
//       return AuthResponse.failure("Apple sign-in error: $e");
//     }
//   }

//   Future<AuthResponse> _sendTokenToBackend(String provider, String token) async {
//     final String apiUrl = 'https://yourapi.com/auth/$provider-login';
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'token': token}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return AuthResponse.success(data['token']);
//       } else {
//         return AuthResponse.failure("Backend error: ${response.body}");
//       }
//     } catch (e) {
//       return AuthResponse.failure("Error communicating with backend: $e");
//     }
//   }
// }
