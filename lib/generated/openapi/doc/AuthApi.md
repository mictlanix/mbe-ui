# mbe_api_client.api.AuthApi

## Load the API package
```dart
import 'package:mbe_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**changePasswordApiV1AuthChangePasswordPost**](AuthApi.md#changepasswordapiv1authchangepasswordpost) | **POST** /api/v1/auth/change-password | Change Password
[**confirmRecoveryApiV1AuthRecoverPost**](AuthApi.md#confirmrecoveryapiv1authrecoverpost) | **POST** /api/v1/auth/recover | Confirm Recovery
[**getMeApiV1AuthMeGet**](AuthApi.md#getmeapiv1authmeget) | **GET** /api/v1/auth/me | Get Me
[**loginApiV1AuthLoginPost**](AuthApi.md#loginapiv1authloginpost) | **POST** /api/v1/auth/login | Login


# **changePasswordApiV1AuthChangePasswordPost**
> changePasswordApiV1AuthChangePasswordPost(changePasswordRequest)

Change Password

Change the authenticated user's own password (requires old password verification).

### Example
```dart
import 'package:mbe_api_client/api.dart';
// TODO Configure OAuth2 access token for authorization: OAuth2PasswordBearer
//defaultApiClient.getAuthentication<OAuth>('OAuth2PasswordBearer').accessToken = 'YOUR_ACCESS_TOKEN';

final api = MbeApiClient().getAuthApi();
final ChangePasswordRequest changePasswordRequest = ; // ChangePasswordRequest | 

try {
    api.changePasswordApiV1AuthChangePasswordPost(changePasswordRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->changePasswordApiV1AuthChangePasswordPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changePasswordRequest** | [**ChangePasswordRequest**](ChangePasswordRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmRecoveryApiV1AuthRecoverPost**
> confirmRecoveryApiV1AuthRecoverPost(confirmRecoveryRequest)

Confirm Recovery

Complete an admin-triggered password recovery using a signed recovery token.

### Example
```dart
import 'package:mbe_api_client/api.dart';

final api = MbeApiClient().getAuthApi();
final ConfirmRecoveryRequest confirmRecoveryRequest = ; // ConfirmRecoveryRequest | 

try {
    api.confirmRecoveryApiV1AuthRecoverPost(confirmRecoveryRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->confirmRecoveryApiV1AuthRecoverPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **confirmRecoveryRequest** | [**ConfirmRecoveryRequest**](ConfirmRecoveryRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMeApiV1AuthMeGet**
> UserResponse getMeApiV1AuthMeGet()

Get Me

Return the authenticated caller's own profile, settings, and privileges.

### Example
```dart
import 'package:mbe_api_client/api.dart';
// TODO Configure OAuth2 access token for authorization: OAuth2PasswordBearer
//defaultApiClient.getAuthentication<OAuth>('OAuth2PasswordBearer').accessToken = 'YOUR_ACCESS_TOKEN';

final api = MbeApiClient().getAuthApi();

try {
    final response = api.getMeApiV1AuthMeGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->getMeApiV1AuthMeGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserResponse**](UserResponse.md)

### Authorization

[OAuth2PasswordBearer](../README.md#OAuth2PasswordBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginApiV1AuthLoginPost**
> TokenResponse loginApiV1AuthLoginPost(username, password, grantType, scope, clientId, clientSecret)

Login

### Example
```dart
import 'package:mbe_api_client/api.dart';

final api = MbeApiClient().getAuthApi();
final String username = username_example; // String | 
final String password = password_example; // String | 
final String grantType = grantType_example; // String | 
final String scope = scope_example; // String | 
final String clientId = clientId_example; // String | 
final String clientSecret = clientSecret_example; // String | 

try {
    final response = api.loginApiV1AuthLoginPost(username, password, grantType, scope, clientId, clientSecret);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->loginApiV1AuthLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**|  | 
 **password** | **String**|  | 
 **grantType** | **String**|  | [optional] 
 **scope** | **String**|  | [optional] [default to '']
 **clientId** | **String**|  | [optional] 
 **clientSecret** | **String**|  | [optional] 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/x-www-form-urlencoded
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

