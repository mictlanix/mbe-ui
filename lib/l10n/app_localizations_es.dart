// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get fieldRequired => 'Requerido';

  @override
  String get fieldMinLength6 => 'Debe tener al menos 6 caracteres';

  @override
  String get signInTitle => 'Iniciar sesión';

  @override
  String get usernameLabel => 'Usuario';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get signInButton => 'Iniciar sesión';

  @override
  String get usersMenuTitle => 'Usuarios';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get changePasswordButton => 'Cambiar contraseña';

  @override
  String get passwordChangedSuccess => 'Contraseña cambiada exitosamente.';

  @override
  String get backButton => 'Regresar';

  @override
  String get recoverPasswordTitle => 'Recuperar contraseña';

  @override
  String get recoveryHelpText =>
      'Solicite a su administrador que genere un token de recuperación para su cuenta, luego ingréselo a continuación junto con su nueva contraseña.';

  @override
  String get recoveryTokenLabel => 'Token de recuperación';

  @override
  String get setNewPasswordButton => 'Establecer nueva contraseña';

  @override
  String get passwordResetSuccess =>
      'Contraseña restablecida exitosamente. Ya puede iniciar sesión.';

  @override
  String get usersTitle => 'Usuarios';

  @override
  String get newUserTooltip => 'Nuevo usuario';

  @override
  String usersLoadError(Object error) {
    return 'Error al cargar usuarios: $error';
  }

  @override
  String get noUsersFound => 'No se encontraron usuarios.';

  @override
  String get columnUsername => 'Usuario';

  @override
  String get columnEmail => 'Correo';

  @override
  String get columnAdmin => 'Admin';

  @override
  String get columnStatus => 'Estado';

  @override
  String get statusDisabled => 'Inactivo';

  @override
  String get statusActive => 'Activo';

  @override
  String get editUserTitle => 'Editar usuario';

  @override
  String get newUserTitle => 'Nuevo usuario';

  @override
  String get recoverPasswordTooltip => 'Recuperar contraseña';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get employeeIdLabel => 'ID de empleado (opcional)';

  @override
  String get administratorLabel => 'Administrador';

  @override
  String get disabledLabel => 'Inactivo';

  @override
  String get permissionsLabel => 'Permisos';

  @override
  String get saveButton => 'Guardar';

  @override
  String get recoveryTokenTitle => 'Token de recuperación';

  @override
  String recoveryExpiresAt(String expiresAt) {
    return 'Expira: $expiresAt';
  }

  @override
  String get userIdLengthError => '4–20 caracteres';

  @override
  String get passwordLengthError => 'Al menos 6 caracteres';

  @override
  String get privilegesModuleColumn => 'Módulo';

  @override
  String get privilegesCreateColumn => 'C';

  @override
  String get privilegesReadColumn => 'L';

  @override
  String get privilegesUpdateColumn => 'A';

  @override
  String get privilegesDeleteColumn => 'E';
}
