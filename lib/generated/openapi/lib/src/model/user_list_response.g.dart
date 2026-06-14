// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserListResponse extends UserListResponse {
  @override
  final BuiltList<UserListItem> items;
  @override
  final int total;

  factory _$UserListResponse(
          [void Function(UserListResponseBuilder)? updates]) =>
      (UserListResponseBuilder()..update(updates))._build();

  _$UserListResponse._({required this.items, required this.total}) : super._();
  @override
  UserListResponse rebuild(void Function(UserListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserListResponseBuilder toBuilder() =>
      UserListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserListResponse &&
        items == other.items &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserListResponse')
          ..add('items', items)
          ..add('total', total))
        .toString();
  }
}

class UserListResponseBuilder
    implements Builder<UserListResponse, UserListResponseBuilder> {
  _$UserListResponse? _$v;

  ListBuilder<UserListItem>? _items;
  ListBuilder<UserListItem> get items =>
      _$this._items ??= ListBuilder<UserListItem>();
  set items(ListBuilder<UserListItem>? items) => _$this._items = items;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  UserListResponseBuilder() {
    UserListResponse._defaults(this);
  }

  UserListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserListResponse other) {
    _$v = other as _$UserListResponse;
  }

  @override
  void update(void Function(UserListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserListResponse build() => _build();

  _$UserListResponse _build() {
    _$UserListResponse _$result;
    try {
      _$result = _$v ??
          _$UserListResponse._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'UserListResponse', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
