// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loginControllerHash() => r'57cf05d50bc4aa3be3e9d5bc749f571cff07c826';

/// Drives the sign-in form (FR-001, FR-008). Delegates the actual sign-in
/// attempt to [AuthNotifier.signIn] and surfaces a single generic error
/// message on `401`/`422` without indicating which field was wrong.
///
/// Copied from [LoginController].
@ProviderFor(LoginController)
final loginControllerProvider =
    AutoDisposeNotifierProvider<LoginController, LoginFormState>.internal(
      LoginController.new,
      name: r'loginControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$loginControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LoginController = AutoDisposeNotifier<LoginFormState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
