# Contract: `GET /api/v1/users` (consumed, unchanged)

This feature does not modify mbe-api or re-run codegen (constitution §III
— "Codegen MUST be re-run whenever mbe-api's OpenAPI spec changes";
no spec change here). It only wires up parameters the generated client
already exposes but `UserRepositoryImpl.list()` currently drops.

## Existing generated signature

`lib/generated/openapi/lib/src/api/users_api.dart`:

```dart
Future<Response<UserListResponse>> listUsersApiV1UsersGet({
  String? search,
  int? skip = 0,
  int? limit = 20,
  ...
})
```

`UserListResponse` already exposes `items` (`List<UserListItem>`) and
`total` (`int`), matching the `ListResponse[ProductListItem]` shape
`ProductRepository.list()` already consumes (specs/002).

## Required `UserRepository` change

```dart
// lib/features/auth/domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<UserListResult> list({   // was: Future<List<UserSummary>> list()
    String? search,
    int skip = 0,
    int limit = 20,
  });
  ...
}

class UserListResult {
  const UserListResult({required this.items, required this.total});
  final List<UserSummary> items;
  final int total;
}
```

`UserRepositoryImpl.list()` passes `search`/`skip`/`limit` straight
through to `_api.listUsersApiV1UsersGet(...)`, then maps
`response.data!.items` to `UserSummary` exactly as it does today — the
mapping logic (`UserSummary.fromListItem`) is unchanged.

## Caller impact

`UsersController` (currently `Future<List<UserSummary>> build()`) becomes
paginated/filterable following the exact shape of
`ProductsListController`/`ProductFilterController` (specs/002,
`products_list_controller.dart`): a new `UserFilterController` holds
`{ search }`, and `UsersController.build()` re-fetches page 0 whenever it
changes, with page navigation handled by the new `CatalogPagination`
widget (data-model.md "UserListPage").
