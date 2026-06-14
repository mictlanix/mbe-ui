# mbe_api_client.api.HealthApi

## Load the API package
```dart
import 'package:mbe_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthCheckApiV1HealthGet**](HealthApi.md#healthcheckapiv1healthget) | **GET** /api/v1/health | Health Check


# **healthCheckApiV1HealthGet**
> BuiltMap<String, String> healthCheckApiV1HealthGet()

Health Check

### Example
```dart
import 'package:mbe_api_client/api.dart';

final api = MbeApiClient().getHealthApi();

try {
    final response = api.healthCheckApiV1HealthGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->healthCheckApiV1HealthGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**BuiltMap&lt;String, String&gt;**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

