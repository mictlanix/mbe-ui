//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'dart:typed_data';
import 'package:mbe_api_client/src/api_util.dart';
import 'package:mbe_api_client/src/model/add_request_lines.dart';
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/http_validation_error.dart';
import 'package:mbe_api_client/src/model/list_response_cost_change.dart';
import 'package:mbe_api_client/src/model/list_response_purchase_order_summary.dart';
import 'package:mbe_api_client/src/model/order_line_add.dart';
import 'package:mbe_api_client/src/model/order_line_update.dart';
import 'package:mbe_api_client/src/model/purchase_order_balance.dart';
import 'package:mbe_api_client/src/model/purchase_order_create.dart';
import 'package:mbe_api_client/src/model/purchase_order_email_request.dart';
import 'package:mbe_api_client/src/model/purchase_order_response.dart';
import 'package:mbe_api_client/src/model/purchase_order_update.dart';
import 'package:mbe_api_client/src/model/quote_email_response.dart';
import 'package:mbe_api_client/src/model/to_purchase_create.dart';
import 'package:mbe_api_client/src/model/to_purchase_response.dart';

class PurchaseOrdersApi {
  final Dio _dio;

  final Serializers _serializers;

  const PurchaseOrdersApi(this._dio, this._serializers);

  /// Add Purchase Order Line
  ///
  ///
  /// Parameters:
  /// * [orderId]
  /// * [orderLineAdd]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderResponse>>
  addPurchaseOrderLineApiV1PurchaseOrdersOrderIdLinesPost({
    required int orderId,
    required OrderLineAdd orderLineAdd,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}/lines'.replaceAll(
      '{'
      r'order_id'
      '}',
      encodeQueryParameter(
        _serializers,
        orderId,
        const FullType(int),
      ).toString(),
    );
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(OrderLineAdd);
      _bodyData = _serializers.serialize(orderLineAdd, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(_dio.options, _path),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderResponse),
                )
                as PurchaseOrderResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Add Purchase Request Lines
  /// An approved request&#39;s pending lines; lines taken meanwhile come back in &#x60;skipped&#x60;.
  ///
  /// Parameters:
  /// * [orderId]
  /// * [addRequestLines]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderResponse>>
  addPurchaseRequestLinesApiV1PurchaseOrdersOrderIdRequestLinesPost({
    required int orderId,
    required AddRequestLines addRequestLines,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}/request-lines'
        .replaceAll(
          '{'
          r'order_id'
          '}',
          encodeQueryParameter(
            _serializers,
            orderId,
            const FullType(int),
          ).toString(),
        );
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(AddRequestLines);
      _bodyData = _serializers.serialize(addRequestLines, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(_dio.options, _path),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderResponse),
                )
                as PurchaseOrderResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Cancel Purchase Order
  ///
  ///
  /// Parameters:
  /// * [orderId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderResponse>>
  cancelPurchaseOrderApiV1PurchaseOrdersOrderIdCancelPost({
    required int orderId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}/cancel'.replaceAll(
      '{'
      r'order_id'
      '}',
      encodeQueryParameter(
        _serializers,
        orderId,
        const FullType(int),
      ).toString(),
    );
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderResponse),
                )
                as PurchaseOrderResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Confirm Purchase Order
  /// Confirm, creating one draft receipt per destination warehouse (FR-027).
  ///
  /// Parameters:
  /// * [orderId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderResponse>>
  confirmPurchaseOrderApiV1PurchaseOrdersOrderIdConfirmPost({
    required int orderId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}/confirm'.replaceAll(
      '{'
      r'order_id'
      '}',
      encodeQueryParameter(
        _serializers,
        orderId,
        const FullType(int),
      ).toString(),
    );
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderResponse),
                )
                as PurchaseOrderResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Create Purchase Order
  ///
  ///
  /// Parameters:
  /// * [purchaseOrderCreate]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderResponse>>
  createPurchaseOrderApiV1PurchaseOrdersPost({
    required PurchaseOrderCreate purchaseOrderCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(PurchaseOrderCreate);
      _bodyData = _serializers.serialize(
        purchaseOrderCreate,
        specifiedType: _type,
      );
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(_dio.options, _path),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderResponse),
                )
                as PurchaseOrderResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Create Purchase Order From Group
  /// One draft PO from a supplier and facility&#39;s pending lines (FR-025).
  ///
  /// Parameters:
  /// * [toPurchaseCreate]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderResponse>>
  createPurchaseOrderFromGroupApiV1PurchaseOrdersToPurchasePost({
    required ToPurchaseCreate toPurchaseCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/to-purchase';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(ToPurchaseCreate);
      _bodyData = _serializers.serialize(
        toPurchaseCreate,
        specifiedType: _type,
      );
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(_dio.options, _path),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderResponse),
                )
                as PurchaseOrderResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Email Purchase Order
  /// Send a confirmed PO&#39;s PDF to 1–10 addresses, and record the send (FR-041, FR-042).
  ///
  /// Parameters:
  /// * [orderId]
  /// * [purchaseOrderEmailRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [QuoteEmailResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<QuoteEmailResponse>>
  emailPurchaseOrderApiV1PurchaseOrdersOrderIdEmailPost({
    required int orderId,
    required PurchaseOrderEmailRequest purchaseOrderEmailRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}/email'.replaceAll(
      '{'
      r'order_id'
      '}',
      encodeQueryParameter(
        _serializers,
        orderId,
        const FullType(int),
      ).toString(),
    );
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(PurchaseOrderEmailRequest);
      _bodyData = _serializers.serialize(
        purchaseOrderEmailRequest,
        specifiedType: _type,
      );
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(_dio.options, _path),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    QuoteEmailResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(QuoteEmailResponse),
                )
                as QuoteEmailResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<QuoteEmailResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Get Purchase Order
  ///
  ///
  /// Parameters:
  /// * [orderId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderResponse>>
  getPurchaseOrderApiV1PurchaseOrdersOrderIdGet({
    required int orderId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}'.replaceAll(
      '{'
      r'order_id'
      '}',
      encodeQueryParameter(
        _serializers,
        orderId,
        const FullType(int),
      ).toString(),
    );
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderResponse),
                )
                as PurchaseOrderResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Get Purchase Order Payments
  /// The PO&#39;s balance and its supplier-payment applications (spec 032, FR-019).
  ///
  /// Parameters:
  /// * [orderId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderBalance] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderBalance>>
  getPurchaseOrderPaymentsApiV1PurchaseOrdersOrderIdPaymentsGet({
    required int orderId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}/payments'.replaceAll(
      '{'
      r'order_id'
      '}',
      encodeQueryParameter(
        _serializers,
        orderId,
        const FullType(int),
      ).toString(),
    );
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderBalance? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderBalance),
                )
                as PurchaseOrderBalance;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderBalance>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// List Cost Changes
  /// A product&#39;s average-cost changes and restores, newest first (FR-036).
  ///
  /// Parameters:
  /// * [product]
  /// * [skip]
  /// * [limit]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ListResponseCostChange] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ListResponseCostChange>>
  listCostChangesApiV1PurchaseOrdersCostChangesGet({
    required int product,
    int? skip = 0,
    int? limit = 20,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/cost-changes';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      r'product': encodeQueryParameter(
        _serializers,
        product,
        const FullType(int),
      ),
      if (skip != null)
        r'skip': encodeQueryParameter(_serializers, skip, const FullType(int)),
      if (limit != null)
        r'limit': encodeQueryParameter(
          _serializers,
          limit,
          const FullType(int),
        ),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    ListResponseCostChange? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(ListResponseCostChange),
                )
                as ListResponseCostChange;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ListResponseCostChange>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// List Purchase Orders
  ///
  ///
  /// Parameters:
  /// * [all]
  /// * [status]
  /// * [supplier]
  /// * [creator]
  /// * [id]
  /// * [from]
  /// * [to]
  /// * [skip]
  /// * [limit]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ListResponsePurchaseOrderSummary] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ListResponsePurchaseOrderSummary>>
  listPurchaseOrdersApiV1PurchaseOrdersGet({
    bool? all = false,
    String? status,
    int? supplier,
    int? creator,
    int? id,
    Date? from,
    Date? to,
    int? skip = 0,
    int? limit = 20,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (all != null)
        r'all': encodeQueryParameter(_serializers, all, const FullType(bool)),
      if (status != null)
        r'status': encodeQueryParameter(
          _serializers,
          status,
          const FullType(String),
        ),
      if (supplier != null)
        r'supplier': encodeQueryParameter(
          _serializers,
          supplier,
          const FullType(int),
        ),
      if (creator != null)
        r'creator': encodeQueryParameter(
          _serializers,
          creator,
          const FullType(int),
        ),
      if (id != null)
        r'id': encodeQueryParameter(_serializers, id, const FullType(int)),
      if (from != null)
        r'from': encodeQueryParameter(_serializers, from, const FullType(Date)),
      if (to != null)
        r'to': encodeQueryParameter(_serializers, to, const FullType(Date)),
      if (skip != null)
        r'skip': encodeQueryParameter(_serializers, skip, const FullType(int)),
      if (limit != null)
        r'limit': encodeQueryParameter(
          _serializers,
          limit,
          const FullType(int),
        ),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    ListResponsePurchaseOrderSummary? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(
                    ListResponsePurchaseOrderSummary,
                  ),
                )
                as ListResponsePurchaseOrderSummary;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ListResponsePurchaseOrderSummary>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Print Purchase Order Document
  /// The letter-size orden de compra of a confirmed PO (FR-040).
  ///
  /// Parameters:
  /// * [orderId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Uint8List] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Uint8List>>
  printPurchaseOrderDocumentApiV1PurchaseOrdersOrderIdDocumentGet({
    required int orderId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}/document'.replaceAll(
      '{'
      r'order_id'
      '}',
      encodeQueryParameter(
        _serializers,
        orderId,
        const FullType(int),
      ).toString(),
    );
    final _options = Options(
      method: r'GET',
      responseType: ResponseType.bytes,
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Uint8List? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : rawResponse as Uint8List;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Uint8List>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Remove Purchase Order Line
  ///
  ///
  /// Parameters:
  /// * [orderId]
  /// * [lineId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderResponse>>
  removePurchaseOrderLineApiV1PurchaseOrdersOrderIdLinesLineIdDelete({
    required int orderId,
    required int lineId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}/lines/{line_id}'
        .replaceAll(
          '{'
          r'order_id'
          '}',
          encodeQueryParameter(
            _serializers,
            orderId,
            const FullType(int),
          ).toString(),
        )
        .replaceAll(
          '{'
          r'line_id'
          '}',
          encodeQueryParameter(
            _serializers,
            lineId,
            const FullType(int),
          ).toString(),
        );
    final _options = Options(
      method: r'DELETE',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderResponse),
                )
                as PurchaseOrderResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// To Purchase By Supplier
  /// Pending marked lines of approved requests, per supplier and facility (FR-024).
  ///
  /// Parameters:
  /// * [facility]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ToPurchaseResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ToPurchaseResponse>>
  toPurchaseBySupplierApiV1PurchaseOrdersToPurchaseGet({
    int? facility,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/to-purchase';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (facility != null)
        r'facility': encodeQueryParameter(
          _serializers,
          facility,
          const FullType(int),
        ),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    ToPurchaseResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(ToPurchaseResponse),
                )
                as ToPurchaseResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ToPurchaseResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Update Purchase Order
  ///
  ///
  /// Parameters:
  /// * [orderId]
  /// * [purchaseOrderUpdate]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderResponse>>
  updatePurchaseOrderApiV1PurchaseOrdersOrderIdPut({
    required int orderId,
    required PurchaseOrderUpdate purchaseOrderUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}'.replaceAll(
      '{'
      r'order_id'
      '}',
      encodeQueryParameter(
        _serializers,
        orderId,
        const FullType(int),
      ).toString(),
    );
    final _options = Options(
      method: r'PUT',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(PurchaseOrderUpdate);
      _bodyData = _serializers.serialize(
        purchaseOrderUpdate,
        specifiedType: _type,
      );
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(_dio.options, _path),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderResponse),
                )
                as PurchaseOrderResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Update Purchase Order Line
  ///
  ///
  /// Parameters:
  /// * [orderId]
  /// * [lineId]
  /// * [orderLineUpdate]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PurchaseOrderResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PurchaseOrderResponse>>
  updatePurchaseOrderLineApiV1PurchaseOrdersOrderIdLinesLineIdPut({
    required int orderId,
    required int lineId,
    required OrderLineUpdate orderLineUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/purchase-orders/{order_id}/lines/{line_id}'
        .replaceAll(
          '{'
          r'order_id'
          '}',
          encodeQueryParameter(
            _serializers,
            orderId,
            const FullType(int),
          ).toString(),
        )
        .replaceAll(
          '{'
          r'line_id'
          '}',
          encodeQueryParameter(
            _serializers,
            lineId,
            const FullType(int),
          ).toString(),
        );
    final _options = Options(
      method: r'PUT',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'oauth2', 'name': 'OAuth2PasswordBearer'},
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(OrderLineUpdate);
      _bodyData = _serializers.serialize(orderLineUpdate, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(_dio.options, _path),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PurchaseOrderResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(PurchaseOrderResponse),
                )
                as PurchaseOrderResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PurchaseOrderResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
