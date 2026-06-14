// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authNotifierHash() => r'dfe5fd38e3265eab1ec9addcd04c89150fbd2011';

/// Session-scoped notifier (data-model.md "AuthSession / AuthState").
///
/// On first read, attempts to restore a session from `TokenStorage` via
/// `GET /api/v1/auth/me`. Drives `signIn`/`signOut` (FR-001, FR-004) and
/// reacts to `401`s from any request via [AuthInterceptor.onUnauthorized]
/// (FR-003).
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>.internal(
      AuthNotifier.new,
      name: r'authNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthNotifier = AsyncNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
