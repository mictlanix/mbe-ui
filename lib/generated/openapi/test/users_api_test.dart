import 'package:test/test.dart';
import 'package:mbe_api_client/mbe_api_client.dart';


/// tests for UsersApi
void main() {
  final instance = MbeApiClient().getUsersApi();

  group(UsersApi, () {
    // Create User
    //
    //Future<UserResponse> createUserApiV1UsersPost(UserCreate userCreate) async
    test('test createUserApiV1UsersPost', () async {
      // TODO
    });

    // Delete User
    //
    //Future deleteUserApiV1UsersUserIdDelete(String userId) async
    test('test deleteUserApiV1UsersUserIdDelete', () async {
      // TODO
    });

    // Get User
    //
    //Future<UserResponse> getUserApiV1UsersUserIdGet(String userId) async
    test('test getUserApiV1UsersUserIdGet', () async {
      // TODO
    });

    // List Users
    //
    //Future<UserListResponse> listUsersApiV1UsersGet({ String search, int skip, int limit }) async
    test('test listUsersApiV1UsersGet', () async {
      // TODO
    });

    // Recover Password
    //
    // Admin-triggered: generate a signed time-limited recovery token for the user.
    //
    //Future<RecoverPasswordAdminResponse> recoverPasswordApiV1UsersUserIdRecoverPasswordPost(String userId) async
    test('test recoverPasswordApiV1UsersUserIdRecoverPasswordPost', () async {
      // TODO
    });

    // Update User
    //
    //Future<UserResponse> updateUserApiV1UsersUserIdPut(String userId, UserUpdate userUpdate) async
    test('test updateUserApiV1UsersUserIdPut', () async {
      // TODO
    });

  });
}
