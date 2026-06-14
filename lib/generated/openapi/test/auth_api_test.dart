import 'package:test/test.dart';
import 'package:mbe_api_client/mbe_api_client.dart';


/// tests for AuthApi
void main() {
  final instance = MbeApiClient().getAuthApi();

  group(AuthApi, () {
    // Change Password
    //
    // Change the authenticated user's own password (requires old password verification).
    //
    //Future changePasswordApiV1AuthChangePasswordPost(ChangePasswordRequest changePasswordRequest) async
    test('test changePasswordApiV1AuthChangePasswordPost', () async {
      // TODO
    });

    // Confirm Recovery
    //
    // Complete an admin-triggered password recovery using a signed recovery token.
    //
    //Future confirmRecoveryApiV1AuthRecoverPost(ConfirmRecoveryRequest confirmRecoveryRequest) async
    test('test confirmRecoveryApiV1AuthRecoverPost', () async {
      // TODO
    });

    // Get Me
    //
    // Return the authenticated caller's own profile, settings, and privileges.
    //
    //Future<UserResponse> getMeApiV1AuthMeGet() async
    test('test getMeApiV1AuthMeGet', () async {
      // TODO
    });

    // Login
    //
    //Future<TokenResponse> loginApiV1AuthLoginPost(String username, String password, { String grantType, String scope, String clientId, String clientSecret }) async
    test('test loginApiV1AuthLoginPost', () async {
      // TODO
    });

  });
}
