//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:mbe_api_client/src/serializers.dart';
import 'package:mbe_api_client/src/auth/api_key_auth.dart';
import 'package:mbe_api_client/src/auth/basic_auth.dart';
import 'package:mbe_api_client/src/auth/bearer_auth.dart';
import 'package:mbe_api_client/src/auth/oauth.dart';
import 'package:mbe_api_client/src/api/auth_api.dart';
import 'package:mbe_api_client/src/api/cash_drawers_api.dart';
import 'package:mbe_api_client/src/api/customers_api.dart';
import 'package:mbe_api_client/src/api/employees_api.dart';
import 'package:mbe_api_client/src/api/exchange_rates_api.dart';
import 'package:mbe_api_client/src/api/expenses_api.dart';
import 'package:mbe_api_client/src/api/facilities_api.dart';
import 'package:mbe_api_client/src/api/health_api.dart';
import 'package:mbe_api_client/src/api/labels_api.dart';
import 'package:mbe_api_client/src/api/payment_method_options_api.dart';
import 'package:mbe_api_client/src/api/points_of_sale_api.dart';
import 'package:mbe_api_client/src/api/price_lists_api.dart';
import 'package:mbe_api_client/src/api/product_prices_api.dart';
import 'package:mbe_api_client/src/api/products_api.dart';
import 'package:mbe_api_client/src/api/sat_catalogs_api.dart';
import 'package:mbe_api_client/src/api/suppliers_api.dart';
import 'package:mbe_api_client/src/api/taxpayer_recipients_api.dart';
import 'package:mbe_api_client/src/api/users_api.dart';
import 'package:mbe_api_client/src/api/vehicle_operators_api.dart';
import 'package:mbe_api_client/src/api/vehicles_api.dart';
import 'package:mbe_api_client/src/api/warehouses_api.dart';

class MbeApiClient {
  static const String basePath = r'http://localhost';

  final Dio dio;
  final Serializers serializers;

  MbeApiClient({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  }) : this.serializers = serializers ?? standardSerializers,
       this.dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: basePathOverride ?? basePath,
               connectTimeout: const Duration(milliseconds: 5000),
               receiveTimeout: const Duration(milliseconds: 3000),
             ),
           ) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor)
                  as OAuthInterceptor)
              .tokens[name] =
          token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor)
                  as BearerAuthInterceptor)
              .tokens[name] =
          token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor)
              as BasicAuthInterceptor)
          .authInfo[name] = BasicAuthInfo(
        username,
        password,
      );
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere(
                    (element) => element is ApiKeyAuthInterceptor,
                  )
                  as ApiKeyAuthInterceptor)
              .apiKeys[name] =
          apiKey;
    }
  }

  /// Get AuthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AuthApi getAuthApi() {
    return AuthApi(dio, serializers);
  }

  /// Get CashDrawersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CashDrawersApi getCashDrawersApi() {
    return CashDrawersApi(dio, serializers);
  }

  /// Get CustomersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CustomersApi getCustomersApi() {
    return CustomersApi(dio, serializers);
  }

  /// Get EmployeesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  EmployeesApi getEmployeesApi() {
    return EmployeesApi(dio, serializers);
  }

  /// Get ExchangeRatesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ExchangeRatesApi getExchangeRatesApi() {
    return ExchangeRatesApi(dio, serializers);
  }

  /// Get ExpensesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ExpensesApi getExpensesApi() {
    return ExpensesApi(dio, serializers);
  }

  /// Get FacilitiesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  FacilitiesApi getFacilitiesApi() {
    return FacilitiesApi(dio, serializers);
  }

  /// Get HealthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  HealthApi getHealthApi() {
    return HealthApi(dio, serializers);
  }

  /// Get LabelsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  LabelsApi getLabelsApi() {
    return LabelsApi(dio, serializers);
  }

  /// Get PaymentMethodOptionsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PaymentMethodOptionsApi getPaymentMethodOptionsApi() {
    return PaymentMethodOptionsApi(dio, serializers);
  }

  /// Get PointsOfSaleApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PointsOfSaleApi getPointsOfSaleApi() {
    return PointsOfSaleApi(dio, serializers);
  }

  /// Get PriceListsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PriceListsApi getPriceListsApi() {
    return PriceListsApi(dio, serializers);
  }

  /// Get ProductPricesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ProductPricesApi getProductPricesApi() {
    return ProductPricesApi(dio, serializers);
  }

  /// Get ProductsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ProductsApi getProductsApi() {
    return ProductsApi(dio, serializers);
  }

  /// Get SatCatalogsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SatCatalogsApi getSatCatalogsApi() {
    return SatCatalogsApi(dio, serializers);
  }

  /// Get SuppliersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SuppliersApi getSuppliersApi() {
    return SuppliersApi(dio, serializers);
  }

  /// Get TaxpayerRecipientsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  TaxpayerRecipientsApi getTaxpayerRecipientsApi() {
    return TaxpayerRecipientsApi(dio, serializers);
  }

  /// Get UsersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UsersApi getUsersApi() {
    return UsersApi(dio, serializers);
  }

  /// Get VehicleOperatorsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  VehicleOperatorsApi getVehicleOperatorsApi() {
    return VehicleOperatorsApi(dio, serializers);
  }

  /// Get VehiclesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  VehiclesApi getVehiclesApi() {
    return VehiclesApi(dio, serializers);
  }

  /// Get WarehousesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WarehousesApi getWarehousesApi() {
    return WarehousesApi(dio, serializers);
  }
}
