//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/api_util.dart';
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:mbe_api_client/src/model/http_validation_error.dart';
import 'package:mbe_api_client/src/model/list_response_product_list_item.dart';
import 'package:mbe_api_client/src/model/product_create.dart';
import 'package:mbe_api_client/src/model/product_label_facet.dart';
import 'package:mbe_api_client/src/model/product_merge_preview_response.dart';
import 'package:mbe_api_client/src/model/product_merge_request.dart';
import 'package:mbe_api_client/src/model/product_missing_price_facet.dart';
import 'package:mbe_api_client/src/model/product_response.dart';
import 'package:mbe_api_client/src/model/product_update.dart';

class ProductsApi {
  final Dio _dio;

  final Serializers _serializers;

  const ProductsApi(this._dio, this._serializers);

  /// Create Product
  ///
  ///
  /// Parameters:
  /// * [productCreate]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ProductResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ProductResponse>> createProductApiV1ProductsPost({
    required ProductCreate productCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/products';
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
      const _type = FullType(ProductCreate);
      _bodyData = _serializers.serialize(productCreate, specifiedType: _type);
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

    ProductResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(ProductResponse),
                )
                as ProductResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ProductResponse>(
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

  /// Delete Product
  ///
  ///
  /// Parameters:
  /// * [productId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> deleteProductApiV1ProductsProductIdDelete({
    required int productId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/products/{product_id}'.replaceAll(
      '{'
      r'product_id'
      '}',
      encodeQueryParameter(
        _serializers,
        productId,
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

    return _response;
  }

  /// Get Product
  ///
  ///
  /// Parameters:
  /// * [productId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ProductResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ProductResponse>> getProductApiV1ProductsProductIdGet({
    required int productId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/products/{product_id}'.replaceAll(
      '{'
      r'product_id'
      '}',
      encodeQueryParameter(
        _serializers,
        productId,
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

    ProductResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(ProductResponse),
                )
                as ProductResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ProductResponse>(
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

  /// Get Product Label Facets
  ///
  ///
  /// Parameters:
  /// * [search]
  /// * [label]
  /// * [status]
  /// * [stockable]
  /// * [salable]
  /// * [purchasable]
  /// * [perishable]
  /// * [seriable]
  /// * [invoiceable]
  /// * [supplier]
  /// * [missingPriceList] - Only products with no price on this price list (#184)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BuiltList<ProductLabelFacet>] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BuiltList<ProductLabelFacet>>>
  getProductLabelFacetsApiV1ProductsLabelsFacetsGet({
    String? search,
    BuiltList<int>? label,
    EntityStatus? status,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    bool? perishable,
    bool? seriable,
    bool? invoiceable,
    int? supplier,
    int? missingPriceList,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/products/labels/facets';
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
      if (search != null)
        r'search': encodeQueryParameter(
          _serializers,
          search,
          const FullType(String),
        ),
      if (label != null)
        r'label': encodeCollectionQueryParameter<int>(
          _serializers,
          label,
          const FullType(BuiltList, [FullType(int)]),
          format: ListFormat.multi,
        ),
      if (status != null)
        r'status': encodeQueryParameter(
          _serializers,
          status,
          const FullType(EntityStatus),
        ),
      if (stockable != null)
        r'stockable': encodeQueryParameter(
          _serializers,
          stockable,
          const FullType(bool),
        ),
      if (salable != null)
        r'salable': encodeQueryParameter(
          _serializers,
          salable,
          const FullType(bool),
        ),
      if (purchasable != null)
        r'purchasable': encodeQueryParameter(
          _serializers,
          purchasable,
          const FullType(bool),
        ),
      if (perishable != null)
        r'perishable': encodeQueryParameter(
          _serializers,
          perishable,
          const FullType(bool),
        ),
      if (seriable != null)
        r'seriable': encodeQueryParameter(
          _serializers,
          seriable,
          const FullType(bool),
        ),
      if (invoiceable != null)
        r'invoiceable': encodeQueryParameter(
          _serializers,
          invoiceable,
          const FullType(bool),
        ),
      if (supplier != null)
        r'supplier': encodeQueryParameter(
          _serializers,
          supplier,
          const FullType(int),
        ),
      if (missingPriceList != null)
        r'missing_price_list': encodeQueryParameter(
          _serializers,
          missingPriceList,
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

    BuiltList<ProductLabelFacet>? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(BuiltList, [
                    FullType(ProductLabelFacet),
                  ]),
                )
                as BuiltList<ProductLabelFacet>;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BuiltList<ProductLabelFacet>>(
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

  /// Get Product Missing Price Facets
  /// One row per price list: how many matching products still have no price on it (#184).  Read by the same privilege as the products list rather than by &#x60;PRICING&#x60;, because that is what it counts — products, narrowed by the product filters, with the price lists supplying only the columns to count against.
  ///
  /// Parameters:
  /// * [search]
  /// * [label]
  /// * [status]
  /// * [stockable]
  /// * [salable]
  /// * [purchasable]
  /// * [perishable]
  /// * [seriable]
  /// * [invoiceable]
  /// * [supplier]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BuiltList<ProductMissingPriceFacet>] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BuiltList<ProductMissingPriceFacet>>>
  getProductMissingPriceFacetsApiV1ProductsPricesMissingFacetsGet({
    String? search,
    BuiltList<int>? label,
    EntityStatus? status,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    bool? perishable,
    bool? seriable,
    bool? invoiceable,
    int? supplier,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/products/prices/missing-facets';
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
      if (search != null)
        r'search': encodeQueryParameter(
          _serializers,
          search,
          const FullType(String),
        ),
      if (label != null)
        r'label': encodeCollectionQueryParameter<int>(
          _serializers,
          label,
          const FullType(BuiltList, [FullType(int)]),
          format: ListFormat.multi,
        ),
      if (status != null)
        r'status': encodeQueryParameter(
          _serializers,
          status,
          const FullType(EntityStatus),
        ),
      if (stockable != null)
        r'stockable': encodeQueryParameter(
          _serializers,
          stockable,
          const FullType(bool),
        ),
      if (salable != null)
        r'salable': encodeQueryParameter(
          _serializers,
          salable,
          const FullType(bool),
        ),
      if (purchasable != null)
        r'purchasable': encodeQueryParameter(
          _serializers,
          purchasable,
          const FullType(bool),
        ),
      if (perishable != null)
        r'perishable': encodeQueryParameter(
          _serializers,
          perishable,
          const FullType(bool),
        ),
      if (seriable != null)
        r'seriable': encodeQueryParameter(
          _serializers,
          seriable,
          const FullType(bool),
        ),
      if (invoiceable != null)
        r'invoiceable': encodeQueryParameter(
          _serializers,
          invoiceable,
          const FullType(bool),
        ),
      if (supplier != null)
        r'supplier': encodeQueryParameter(
          _serializers,
          supplier,
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

    BuiltList<ProductMissingPriceFacet>? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(BuiltList, [
                    FullType(ProductMissingPriceFacet),
                  ]),
                )
                as BuiltList<ProductMissingPriceFacet>;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BuiltList<ProductMissingPriceFacet>>(
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

  /// List Products
  ///
  ///
  /// Parameters:
  /// * [search]
  /// * [label]
  /// * [status]
  /// * [stockable]
  /// * [salable]
  /// * [purchasable]
  /// * [perishable]
  /// * [seriable]
  /// * [invoiceable]
  /// * [supplier]
  /// * [missingPriceList] - Only products with no price on this price list (#184)
  /// * [skip]
  /// * [limit]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ListResponseProductListItem] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ListResponseProductListItem>> listProductsApiV1ProductsGet({
    String? search,
    BuiltList<int>? label,
    EntityStatus? status,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    bool? perishable,
    bool? seriable,
    bool? invoiceable,
    int? supplier,
    int? missingPriceList,
    int? skip = 0,
    int? limit = 20,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/products';
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
      if (search != null)
        r'search': encodeQueryParameter(
          _serializers,
          search,
          const FullType(String),
        ),
      if (label != null)
        r'label': encodeCollectionQueryParameter<int>(
          _serializers,
          label,
          const FullType(BuiltList, [FullType(int)]),
          format: ListFormat.multi,
        ),
      if (status != null)
        r'status': encodeQueryParameter(
          _serializers,
          status,
          const FullType(EntityStatus),
        ),
      if (stockable != null)
        r'stockable': encodeQueryParameter(
          _serializers,
          stockable,
          const FullType(bool),
        ),
      if (salable != null)
        r'salable': encodeQueryParameter(
          _serializers,
          salable,
          const FullType(bool),
        ),
      if (purchasable != null)
        r'purchasable': encodeQueryParameter(
          _serializers,
          purchasable,
          const FullType(bool),
        ),
      if (perishable != null)
        r'perishable': encodeQueryParameter(
          _serializers,
          perishable,
          const FullType(bool),
        ),
      if (seriable != null)
        r'seriable': encodeQueryParameter(
          _serializers,
          seriable,
          const FullType(bool),
        ),
      if (invoiceable != null)
        r'invoiceable': encodeQueryParameter(
          _serializers,
          invoiceable,
          const FullType(bool),
        ),
      if (supplier != null)
        r'supplier': encodeQueryParameter(
          _serializers,
          supplier,
          const FullType(int),
        ),
      if (missingPriceList != null)
        r'missing_price_list': encodeQueryParameter(
          _serializers,
          missingPriceList,
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

    ListResponseProductListItem? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(ListResponseProductListItem),
                )
                as ListResponseProductListItem;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ListResponseProductListItem>(
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

  /// Merge Products
  ///
  ///
  /// Parameters:
  /// * [productMergeRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> mergeProductsApiV1ProductsMergePost({
    required ProductMergeRequest productMergeRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/products/merge';
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
      const _type = FullType(ProductMergeRequest);
      _bodyData = _serializers.serialize(
        productMergeRequest,
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

    return _response;
  }

  /// Preview Product Merge
  ///
  ///
  /// Parameters:
  /// * [productId]
  /// * [duplicateId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ProductMergePreviewResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ProductMergePreviewResponse>>
  previewProductMergeApiV1ProductsMergePreviewGet({
    required int productId,
    required int duplicateId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/products/merge/preview';
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
      r'product_id': encodeQueryParameter(
        _serializers,
        productId,
        const FullType(int),
      ),
      r'duplicate_id': encodeQueryParameter(
        _serializers,
        duplicateId,
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

    ProductMergePreviewResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(ProductMergePreviewResponse),
                )
                as ProductMergePreviewResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ProductMergePreviewResponse>(
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

  /// Update Product
  ///
  ///
  /// Parameters:
  /// * [productId]
  /// * [productUpdate]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ProductResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ProductResponse>> updateProductApiV1ProductsProductIdPut({
    required int productId,
    required ProductUpdate productUpdate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/products/{product_id}'.replaceAll(
      '{'
      r'product_id'
      '}',
      encodeQueryParameter(
        _serializers,
        productId,
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
      const _type = FullType(ProductUpdate);
      _bodyData = _serializers.serialize(productUpdate, specifiedType: _type);
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

    ProductResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(ProductResponse),
                )
                as ProductResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ProductResponse>(
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

  /// Upload Product Image
  ///
  ///
  /// Parameters:
  /// * [productId]
  /// * [file]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ProductResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ProductResponse>>
  uploadProductImageApiV1ProductsProductIdImagePost({
    required int productId,
    required String file,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/products/{product_id}/image'.replaceAll(
      '{'
      r'product_id'
      '}',
      encodeQueryParameter(
        _serializers,
        productId,
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
      contentType: 'multipart/form-data',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      _bodyData = FormData.fromMap(<String, dynamic>{
        r'file': encodeFormParameter(
          _serializers,
          file,
          const FullType(String),
        ),
      });
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

    ProductResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
                  rawResponse,
                  specifiedType: const FullType(ProductResponse),
                )
                as ProductResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ProductResponse>(
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
