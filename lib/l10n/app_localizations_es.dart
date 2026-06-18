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
  String get forgotPasswordLink => '¿Olvidaste tu contraseña?';

  @override
  String get changePasswordMenuTitle => 'Cambiar contraseña';

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
  String get productsTitle => 'Productos';

  @override
  String get newProductTooltip => 'Nuevo producto';

  @override
  String get productsSearchLabel => 'Buscar por código, nombre, marca o modelo';

  @override
  String get productsShowInactiveFilter => 'Mostrar inactivos';

  @override
  String get productsStockableFilter => 'Almacenable';

  @override
  String get productsSalableFilter => 'Vendible';

  @override
  String get productsPurchasableFilter => 'Comprable';

  @override
  String productsLoadError(Object error) {
    return 'Error al cargar productos: $error';
  }

  @override
  String get noProductsFound => 'No se encontraron productos.';

  @override
  String get columnCode => 'Código';

  @override
  String get columnName => 'Nombre';

  @override
  String get columnBrand => 'Marca';

  @override
  String get columnUnit => 'Unidad';

  @override
  String get loadMoreButton => 'Cargar más';

  @override
  String get newProductTitle => 'Nuevo producto';

  @override
  String get editProductTitle => 'Editar producto';

  @override
  String get codeLabel => 'Código';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get unitOfMeasurementLabel => 'Unidad de medida';

  @override
  String get brandLabel => 'Marca';

  @override
  String get modelLabel => 'Modelo';

  @override
  String get barCodeLabel => 'Código de barras';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get taxRateLabel => 'Tasa de impuesto';

  @override
  String get commentLabel => 'Notas';

  @override
  String get stockableLabel => 'Almacenable';

  @override
  String get perishableLabel => 'Perecedero';

  @override
  String get seriableLabel => 'Con número de serie';

  @override
  String get purchasableLabel => 'Comprable';

  @override
  String get salableLabel => 'Vendible';

  @override
  String get invoiceableLabel => 'Facturable';

  @override
  String get deactivateProductTooltip => 'Desactivar producto';

  @override
  String get deactivateProductConfirmTitle => '¿Desactivar producto?';

  @override
  String deactivateProductConfirmMessage(String code) {
    return '¿Está seguro de que desea desactivar \"$code\"? Se ocultará de nuevas ventas, compras y movimientos de inventario, pero su historial se conserva.';
  }

  @override
  String get deactivateButton => 'Desactivar';

  @override
  String get statusInactiveBadge => 'Inactivo';

  @override
  String get editUserTitle => 'Editar usuario';

  @override
  String get newUserTitle => 'Nuevo usuario';

  @override
  String get recoverPasswordTooltip => 'Recuperar contraseña';

  @override
  String get deleteUserTooltip => 'Eliminar usuario';

  @override
  String get deleteUserConfirmTitle => '¿Eliminar usuario?';

  @override
  String deleteUserConfirmMessage(String userId) {
    return '¿Seguro que deseas eliminar a \"$userId\"? Esta acción no se puede deshacer.';
  }

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get cancelButton => 'Cancelar';

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

  @override
  String get privilegesCreateTooltip => 'Crear';

  @override
  String get privilegesReadTooltip => 'Leer';

  @override
  String get privilegesUpdateTooltip => 'Actualizar';

  @override
  String get privilegesDeleteTooltip => 'Eliminar';

  @override
  String get productCodeRequiredError => 'El código es obligatorio.';

  @override
  String get productCodeWhitespaceError =>
      'El código no debe contener espacios en blanco.';

  @override
  String get productCodeTooLongError =>
      'El código debe tener máximo 25 caracteres.';

  @override
  String get productNameLengthError =>
      'El nombre debe tener entre 4 y 250 caracteres.';

  @override
  String get productUnitRequiredError => 'La unidad de medida es obligatoria.';

  @override
  String get productBarCodeInvalidError =>
      'El código de barras debe estar vacío o tener exactamente 13 dígitos.';

  @override
  String get productLoadFailedError => 'No se pudo cargar el producto.';

  @override
  String get productCreateFailedError => 'No se pudo crear el producto.';

  @override
  String get productUpdateFailedError => 'No se pudo actualizar el producto.';

  @override
  String get productDeactivateFailedError =>
      'No se pudo desactivar el producto.';

  @override
  String get productCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear productos.';

  @override
  String get productUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar productos.';

  @override
  String get productDeactivatePermissionDeniedError =>
      'Ya no tienes permiso para desactivar productos.';

  @override
  String get userEmailRequiredError => 'El correo electrónico es obligatorio.';

  @override
  String get userUsernameRequiredError =>
      'El nombre de usuario es obligatorio.';

  @override
  String get userPasswordLengthError =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get userLoadFailedError => 'No se pudo cargar el usuario.';

  @override
  String get userSaveFailedError => 'No se pudo guardar el usuario.';

  @override
  String get userDeleteFailedError => 'No se pudo eliminar el usuario.';

  @override
  String get userRecoveryFailedError =>
      'No se pudo generar el token de recuperación.';
}
