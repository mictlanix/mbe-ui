//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_customer_request.g.dart';

/// One customer and period; the export and saved-view form of the route's parameters.
///
/// Properties:
/// * [customer]
/// * [start]
/// * [end]
/// * [facility] - Omitted: the caller's own, or every facility for callers who may see them all.
@BuiltValue()
abstract class AnalyticsCustomerRequest
    implements
        Built<AnalyticsCustomerRequest, AnalyticsCustomerRequestBuilder> {
  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'start')
  Date get start;

  @BuiltValueField(wireName: r'end')
  Date get end;

  /// Omitted: the caller's own, or every facility for callers who may see them all.
  @BuiltValueField(wireName: r'facility')
  int? get facility;

  AnalyticsCustomerRequest._();

  factory AnalyticsCustomerRequest([
    void updates(AnalyticsCustomerRequestBuilder b),
  ]) = _$AnalyticsCustomerRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsCustomerRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsCustomerRequest> get serializer =>
      _$AnalyticsCustomerRequestSerializer();
}

class _$AnalyticsCustomerRequestSerializer
    implements PrimitiveSerializer<AnalyticsCustomerRequest> {
  @override
  final Iterable<Type> types = const [
    AnalyticsCustomerRequest,
    _$AnalyticsCustomerRequest,
  ];

  @override
  final String wireName = r'AnalyticsCustomerRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsCustomerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'customer';
    yield serializers.serialize(
      object.customer,
      specifiedType: const FullType(int),
    );
    yield r'start';
    yield serializers.serialize(
      object.start,
      specifiedType: const FullType(Date),
    );
    yield r'end';
    yield serializers.serialize(
      object.end,
      specifiedType: const FullType(Date),
    );
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsCustomerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(
      serializers,
      object,
      specifiedType: specifiedType,
    ).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AnalyticsCustomerRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'customer':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customer = valueDes;
          break;
        case r'start':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.start = valueDes;
          break;
        case r'end':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.end = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facility = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsCustomerRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsCustomerRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
