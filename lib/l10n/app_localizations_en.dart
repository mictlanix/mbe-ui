// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get fieldRequired => 'Required';

  @override
  String get fieldMinLength6 => 'Must be at least 6 characters';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get usersMenuTitle => 'Users';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get changePasswordButton => 'Change password';

  @override
  String get passwordChangedSuccess => 'Password changed successfully.';

  @override
  String get backButton => 'Back';

  @override
  String get recoverPasswordTitle => 'Recover Password';

  @override
  String get recoveryHelpText =>
      'Ask your administrator to generate a recovery token for your account, then enter it below along with your new password.';

  @override
  String get recoveryTokenLabel => 'Recovery token';

  @override
  String get setNewPasswordButton => 'Set new password';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully. You can now sign in.';

  @override
  String get usersTitle => 'Users';

  @override
  String get newUserTooltip => 'New user';

  @override
  String usersLoadError(Object error) {
    return 'Failed to load users: $error';
  }

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get columnUsername => 'Username';

  @override
  String get columnEmail => 'Email';

  @override
  String get columnAdmin => 'Admin';

  @override
  String get columnStatus => 'Status';

  @override
  String get statusDisabled => 'Disabled';

  @override
  String get statusActive => 'Active';

  @override
  String get editUserTitle => 'Edit User';

  @override
  String get newUserTitle => 'New User';

  @override
  String get recoverPasswordTooltip => 'Recover password';

  @override
  String get emailLabel => 'Email';

  @override
  String get employeeIdLabel => 'Employee ID (optional)';

  @override
  String get administratorLabel => 'Administrator';

  @override
  String get disabledLabel => 'Disabled';

  @override
  String get permissionsLabel => 'Permissions';

  @override
  String get saveButton => 'Save';

  @override
  String get recoveryTokenTitle => 'Recovery Token';

  @override
  String recoveryExpiresAt(String expiresAt) {
    return 'Expires: $expiresAt';
  }

  @override
  String get userIdLengthError => '4–20 characters';

  @override
  String get passwordLengthError => 'At least 6 characters';

  @override
  String get privilegesModuleColumn => 'Module';

  @override
  String get privilegesCreateColumn => 'C';

  @override
  String get privilegesReadColumn => 'R';

  @override
  String get privilegesUpdateColumn => 'U';

  @override
  String get privilegesDeleteColumn => 'D';

  @override
  String get privilegesCreateTooltip => 'Create';

  @override
  String get privilegesReadTooltip => 'Read';

  @override
  String get privilegesUpdateTooltip => 'Update';

  @override
  String get privilegesDeleteTooltip => 'Delete';
}
