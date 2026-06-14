# mbe_api_client.api.UsersApi

## Load the API package
```dart
import 'package:mbe_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createUserApiV1UsersPost**](UsersApi.md#createuserapiv1userspost) | **POST** /api/v1/users | Create User
[**deleteUserApiV1UsersUserIdDelete**](UsersApi.md#deleteuserapiv1usersuseriddelete) | **DELETE** /api/v1/users/{user_id} | Delete User
[**getUserApiV1UsersUserIdGet**](UsersApi.md#getuserapiv1usersuseridget) | **GET** /api/v1/users/{user_id} | Get User
[**listUsersApiV1UsersGet**](UsersApi.md#listusersapiv1usersget) | **GET** /api/v1/users | List Users
[**recoverPasswordApiV1UsersUserIdRecoverPasswordPost**](UsersApi.md#recoverpasswordapiv1usersuseridrecoverpasswordpost) | **POST** /api/v1/users/{user_id}/recover-password | Recover Password
[**updateUserApiV1UsersUserIdPut**](UsersApi.md#updateuserapiv1usersuseridput) | **PUT** /api/v1/users/{user_id} | Update User


# **createUserApiV1UsersPost**
> UserResponse createUserApiV1UsersPost(userCreate)

Create User

### Example
```dart
import 'package:mbe_api_client/api.dart';
// TODO Configure OAuth2 access token for authorization: OAuth2PasswordBearer
//defaultApiClient.getAuthentication<OAuth>('OAuth2PasswordBearer').accessToken = 'YOUR_ACCESS_TOKEN';

final api = MbeApiClient().getUsersApi();
final UserCreate userCreate = ; // UserCreate | 

try {
    final response = api.createUserApiV1UsersPost(userCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->createUserApiV1UsersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userCreate** | [**UserCreate**](UserCreate.md)|  | 

### Return type

[**UserResponse**](UserResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteUserApiV1UsersUserIdDelete**
> deleteUserApiV1UsersUserIdDelete(userId)

Delete User

### Example
```dart
import 'package:mbe_api_client/api.dart';
// TODO Configure OAuth2 access token for authorization: OAuth2PasswordBearer
//defaultApiClient.getAuthentication<OAuth>('OAuth2PasswordBearer').accessToken = 'YOUR_ACCESS_TOKEN';

final api = MbeApiClient().getUsersApi();
final String userId = userId_example; // String | 

try {
    api.deleteUserApiV1UsersUserIdDelete(userId);
} on DioException catch (e) {
    print('Exception when calling UsersApi->deleteUserApiV1UsersUserIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserApiV1UsersUserIdGet**
> UserResponse getUserApiV1UsersUserIdGet(userId)

Get User

### Example
```dart
import 'package:mbe_api_client/api.dart';
// TODO Configure OAuth2 access token for authorization: OAuth2PasswordBearer
//defaultApiClient.getAuthentication<OAuth>('OAuth2PasswordBearer').accessToken = 'YOUR_ACCESS_TOKEN';

final api = MbeApiClient().getUsersApi();
final String userId = userId_example; // String | 

try {
    final response = api.getUserApiV1UsersUserIdGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getUserApiV1UsersUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**UserResponse**](UserResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listUsersApiV1UsersGet**
> UserListResponse listUsersApiV1UsersGet(search, skip, limit)

List Users

### Example
```dart
import 'package:mbe_api_client/api.dart';
// TODO Configure OAuth2 access token for authorization: OAuth2PasswordBearer
//defaultApiClient.getAuthentication<OAuth>('OAuth2PasswordBearer').accessToken = 'YOUR_ACCESS_TOKEN';

final api = MbeApiClient().getUsersApi();
final String search = search_example; // String | Search by username or email
final int skip = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.listUsersApiV1UsersGet(search, skip, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->listUsersApiV1UsersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **search** | **String**| Search by username or email | [optional] 
 **skip** | **int**|  | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**UserListResponse**](UserListResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recoverPasswordApiV1UsersUserIdRecoverPasswordPost**
> RecoverPasswordAdminResponse recoverPasswordApiV1UsersUserIdRecoverPasswordPost(userId)

Recover Password

Admin-triggered: generate a signed time-limited recovery token for the user.

### Example
```dart
import 'package:mbe_api_client/api.dart';
// TODO Configure OAuth2 access token for authorization: OAuth2PasswordBearer
//defaultApiClient.getAuthentication<OAuth>('OAuth2PasswordBearer').accessToken = 'YOUR_ACCESS_TOKEN';

final api = MbeApiClient().getUsersApi();
final String userId = userId_example; // String | 

try {
    final response = api.recoverPasswordApiV1UsersUserIdRecoverPasswordPost(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->recoverPasswordApiV1UsersUserIdRecoverPasswordPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**RecoverPasswordAdminResponse**](RecoverPasswordAdminResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUserApiV1UsersUserIdPut**
> UserResponse updateUserApiV1UsersUserIdPut(userId, userUpdate)

Update User

### Example
```dart
import 'package:mbe_api_client/api.dart';
// TODO Configure OAuth2 access token for authorization: OAuth2PasswordBearer
//defaultApiClient.getAuthentication<OAuth>('OAuth2PasswordBearer').accessToken = 'YOUR_ACCESS_TOKEN';

final api = MbeApiClient().getUsersApi();
final String userId = userId_example; // String | 
final UserUpdate userUpdate = ; // UserUpdate | 

try {
    final response = api.updateUserApiV1UsersUserIdPut(userId, userUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->updateUserApiV1UsersUserIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **userUpdate** | [**UserUpdate**](UserUpdate.md)|  | 

### Return type

[**UserResponse**](UserResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

