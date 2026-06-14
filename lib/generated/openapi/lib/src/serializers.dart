//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:mbe_api_client/src/date_serializer.dart';
import 'package:mbe_api_client/src/model/date.dart';

import 'package:mbe_api_client/src/model/change_password_request.dart';
import 'package:mbe_api_client/src/model/confirm_recovery_request.dart';
import 'package:mbe_api_client/src/model/http_validation_error.dart';
import 'package:mbe_api_client/src/model/location_inner.dart';
import 'package:mbe_api_client/src/model/privilege_response.dart';
import 'package:mbe_api_client/src/model/privilege_update.dart';
import 'package:mbe_api_client/src/model/recover_password_admin_response.dart';
import 'package:mbe_api_client/src/model/token_response.dart';
import 'package:mbe_api_client/src/model/user_create.dart';
import 'package:mbe_api_client/src/model/user_list_item.dart';
import 'package:mbe_api_client/src/model/user_list_response.dart';
import 'package:mbe_api_client/src/model/user_response.dart';
import 'package:mbe_api_client/src/model/user_settings_response.dart';
import 'package:mbe_api_client/src/model/user_settings_update.dart';
import 'package:mbe_api_client/src/model/user_update.dart';
import 'package:mbe_api_client/src/model/validation_error.dart';

part 'serializers.g.dart';

@SerializersFor([
  ChangePasswordRequest,
  ConfirmRecoveryRequest,
  HTTPValidationError,
  LocationInner,
  PrivilegeResponse,
  PrivilegeUpdate,
  RecoverPasswordAdminResponse,
  TokenResponse,
  UserCreate,
  UserListItem,
  UserListResponse,
  UserResponse,
  UserSettingsResponse,
  UserSettingsUpdate,
  UserUpdate,
  ValidationError,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(String)]),
        () => MapBuilder<String, String>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
