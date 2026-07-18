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
  String get viewActionTooltip => 'Ver';

  @override
  String get editActionTooltip => 'Editar';

  @override
  String get deleteActionTooltip => 'Eliminar';

  @override
  String get searchButtonTooltip => 'Buscar';

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
  String get appTitle => 'Mictlanix Business Essentials';

  @override
  String get homeMenuTitle => 'Inicio';

  @override
  String get homeWelcomeMessage => 'Bienvenido';

  @override
  String get catalogsGroupTitle => 'Catálogos';

  @override
  String get usersMenuTitle => 'Usuarios';

  @override
  String get userMenuLogout => 'Salir';

  @override
  String userMenuStoreFallback(int id) {
    return 'Store $id';
  }

  @override
  String userMenuPosFallback(int id) {
    return 'POS $id';
  }

  @override
  String userMenuDrawerFallback(int id) {
    return 'Drawer $id';
  }

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
  String get usersSearchLabel => 'Buscar por usuario o correo';

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
  String get uploadPhotoButton => 'Subir foto';

  @override
  String get replacePhotoButton => 'Cambiar foto';

  @override
  String get removePhotoButton => 'Quitar foto';

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
  String get productsLabelFilter => 'Etiquetas';

  @override
  String get labelUnavailableTooltip => 'Sin productos que coincidan';

  @override
  String labelWithCount(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filtersButton => 'Filtros';

  @override
  String get filtersTooltip => 'Filtros';

  @override
  String get clearAllFilters => 'Limpiar filtros';

  @override
  String get applyFilters => 'Aplicar';

  @override
  String productsLoadError(Object error) {
    return 'Error al cargar productos: $error';
  }

  @override
  String get noProductsFound => 'No se encontraron productos.';

  @override
  String get columnPhoto => 'Foto';

  @override
  String get columnCode => 'Código';

  @override
  String get copyCodeTooltip => 'Copiar código';

  @override
  String get codeCopiedMessage => 'Código copiado al portapapeles';

  @override
  String get columnName => 'Nombre';

  @override
  String get columnBrand => 'Marca';

  @override
  String get columnUnit => 'Unidad';

  @override
  String get newProductTitle => 'Nuevo producto';

  @override
  String get editProductTitle => 'Editar producto';

  @override
  String get viewProductTitle => 'Ver producto';

  @override
  String get codeLabel => 'Código';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get skuLabel => 'SKU';

  @override
  String get unitOfMeasurementLabel => 'Unidad de medida';

  @override
  String get supplierLabel => 'Proveedor';

  @override
  String get satKeyLabel => 'Clave SAT Producto/Servicio';

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
  String get labelsLabel => 'Etiquetas';

  @override
  String get deleteProductButton => 'Eliminar producto';

  @override
  String get deleteProductConfirmTitle => '¿Eliminar producto permanentemente?';

  @override
  String deleteProductConfirmMessage(String code) {
    return '¿Está seguro de que desea eliminar permanentemente \"$code\"? Esta acción no se puede deshacer: el producto y su historial se eliminarán por completo, no solo se ocultarán.';
  }

  @override
  String get statusInactiveBadge => 'Inactivo';

  @override
  String get mergeProductsTitle => 'Fusión de productos';

  @override
  String get mergeProductsTooltip => 'Fusionar productos';

  @override
  String get mergeProductLabel => 'Producto';

  @override
  String get duplicatedLabel => 'Duplicado';

  @override
  String get mergeButton => 'Fusionar';

  @override
  String get mergeBackTooltip => 'Regresar';

  @override
  String get mergeBothRequiredMessage =>
      'Selecciona un producto y un duplicado para continuar.';

  @override
  String get mergeSameProductMessage =>
      'No puedes fusionar un producto consigo mismo.';

  @override
  String get mergeConfirmTitle => '¿Fusionar productos permanentemente?';

  @override
  String mergeConfirmMessage(String canonicalName, String duplicateName) {
    return '¿Está seguro de que desea fusionar \"$duplicateName\" en \"$canonicalName\"? Esta acción no se puede deshacer: \"$duplicateName\" se eliminará por completo y su historial se transferirá a \"$canonicalName\".';
  }

  @override
  String get mergeSuccess => 'Productos fusionados correctamente.';

  @override
  String get editUserTitle => 'Editar usuario';

  @override
  String get viewUserTitle => 'Ver usuario';

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
  String get editButton => 'Editar';

  @override
  String get editRecordTooltip => 'Cambiar al formulario editable';

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
  String get productPhotoInvalidTypeError =>
      'La foto debe ser un archivo JPEG o PNG.';

  @override
  String get productPhotoTooLargeError => 'La foto debe ser de 2 MB o menos.';

  @override
  String get productPhotoUploadFailedError =>
      'El producto se guardó, pero la foto no se pudo subir. Intenta de nuevo.';

  @override
  String get productLoadFailedError => 'No se pudo cargar el producto.';

  @override
  String get productCreateFailedError => 'No se pudo crear el producto.';

  @override
  String get productUpdateFailedError => 'No se pudo actualizar el producto.';

  @override
  String get productDeleteFailedError => 'No se pudo eliminar el producto.';

  @override
  String get productCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear productos.';

  @override
  String get productUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar productos.';

  @override
  String get productDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar productos.';

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

  @override
  String get priceListsMenuTitle => 'Listas de Precios';

  @override
  String get pricingMenuTitle => 'Precios';

  @override
  String get exchangeRatesMenuTitle => 'Tipos de Cambio';

  @override
  String get priceListsSearchLabel => 'Buscar por nombre';

  @override
  String get newPriceListTooltip => 'Nueva lista de precios';

  @override
  String get noPriceListsFound => 'No se encontraron listas de precios.';

  @override
  String priceListsLoadError(Object error) {
    return 'No se pudieron cargar las listas de precios: $error';
  }

  @override
  String get columnHighProfitMargin => 'Margen alto';

  @override
  String get columnLowProfitMargin => 'Margen bajo';

  @override
  String get priceListNameLabel => 'Nombre';

  @override
  String get priceListHighProfitMarginLabel => 'Margen de utilidad alto';

  @override
  String get priceListLowProfitMarginLabel => 'Margen de utilidad bajo';

  @override
  String get newPriceListTitle => 'Nueva lista de precios';

  @override
  String get editPriceListTitle => 'Editar lista de precios';

  @override
  String get viewPriceListTitle => 'Ver lista de precios';

  @override
  String get deletePriceListButton => 'Eliminar';

  @override
  String get deletePriceListConfirmTitle => '¿Eliminar lista de precios?';

  @override
  String deletePriceListConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get priceListNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get priceListMarginInvalidError =>
      'Ingresa un porcentaje válido no negativo.';

  @override
  String get priceListLoadFailedError =>
      'No se pudo cargar la lista de precios.';

  @override
  String get priceListCreateFailedError =>
      'No se pudo crear la lista de precios.';

  @override
  String get priceListUpdateFailedError =>
      'No se pudo actualizar la lista de precios.';

  @override
  String get priceListDeleteFailedError =>
      'No se pudo eliminar la lista de precios.';

  @override
  String get priceListCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear listas de precios.';

  @override
  String get priceListUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar listas de precios.';

  @override
  String get priceListDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar listas de precios.';

  @override
  String get pricingProductPickerLabel => 'Producto';

  @override
  String get pricingSelectProductPrompt =>
      'Selecciona un producto para ver y editar sus precios.';

  @override
  String get pricingNoPriceListsEmptyState =>
      'Aún no existen listas de precios. Crea una primero.';

  @override
  String get pricingPriceNotSet => 'Sin definir';

  @override
  String pricingLoadError(Object error) {
    return 'No se pudieron cargar los precios: $error';
  }

  @override
  String get pricingSaveFailedError => 'No se pudo guardar el precio.';

  @override
  String get pricingUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar precios.';

  @override
  String get pricingInvalidAmountError =>
      'Ingresa un monto válido no negativo.';

  @override
  String get columnPriceList => 'Lista de precios';

  @override
  String get columnPrice => 'Precio';

  @override
  String get columnLowProfit => 'Utilidad baja';

  @override
  String get columnHighProfit => 'Utilidad alta';

  @override
  String get editPriceTooltip => 'Editar precio';

  @override
  String get savePriceTooltip => 'Guardar';

  @override
  String get cancelPriceEditTooltip => 'Cancelar';

  @override
  String get newExchangeRateTooltip => 'Nuevo tipo de cambio';

  @override
  String get noExchangeRatesFound => 'No se encontraron tipos de cambio.';

  @override
  String exchangeRatesLoadError(Object error) {
    return 'No se pudieron cargar los tipos de cambio: $error';
  }

  @override
  String get columnDate => 'Fecha';

  @override
  String get columnBaseCurrency => 'Base';

  @override
  String get columnTargetCurrency => 'Destino';

  @override
  String get columnRate => 'Tipo de cambio';

  @override
  String get exchangeRateDateLabel => 'Fecha';

  @override
  String get exchangeRateBaseCurrencyLabel => 'Moneda base';

  @override
  String get exchangeRateTargetCurrencyLabel => 'Moneda destino';

  @override
  String get exchangeRateRateLabel => 'Tipo de cambio';

  @override
  String get newExchangeRateTitle => 'Nuevo tipo de cambio';

  @override
  String get editExchangeRateTitle => 'Editar tipo de cambio';

  @override
  String get viewExchangeRateTitle => 'Ver tipo de cambio';

  @override
  String get deleteExchangeRateButton => 'Eliminar';

  @override
  String get deleteExchangeRateConfirmTitle => '¿Eliminar tipo de cambio?';

  @override
  String get deleteExchangeRateConfirmMessage =>
      'Esto eliminará permanentemente este tipo de cambio. Esta acción no se puede deshacer.';

  @override
  String get exchangeRateDateRequiredError => 'La fecha es obligatoria.';

  @override
  String get exchangeRateRateInvalidError =>
      'Ingresa un tipo de cambio positivo válido.';

  @override
  String get exchangeRateCurrencyRequiredError => 'Selecciona una moneda.';

  @override
  String get exchangeRateLoadFailedError =>
      'No se pudo cargar el tipo de cambio.';

  @override
  String get exchangeRateCreateFailedError =>
      'No se pudo crear el tipo de cambio.';

  @override
  String get exchangeRateUpdateFailedError =>
      'No se pudo actualizar el tipo de cambio.';

  @override
  String get exchangeRateDeleteFailedError =>
      'No se pudo eliminar el tipo de cambio.';

  @override
  String get exchangeRateCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear tipos de cambio.';

  @override
  String get exchangeRateUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar tipos de cambio.';

  @override
  String get exchangeRateDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar tipos de cambio.';

  @override
  String get dateRangeFilterLabel => 'Rango de fechas';

  @override
  String get currencyFilterLabel => 'Par de monedas';

  @override
  String get clearDateRangeTooltip => 'Limpiar rango de fechas';

  @override
  String get currencyMxnLabel => 'MXN — Peso Mexicano';

  @override
  String get currencyUsdLabel => 'USD — Dólar Estadounidense';

  @override
  String get currencyEurLabel => 'EUR — Euro';
}
