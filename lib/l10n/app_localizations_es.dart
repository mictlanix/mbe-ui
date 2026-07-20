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
  String get moreActionsTooltip => 'Más acciones';

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
  String get salesGroupTitle => 'Ventas';

  @override
  String get usersMenuTitle => 'Usuarios';

  @override
  String get userMenuLogout => 'Salir';

  @override
  String userMenuFacilityFallback(int id) {
    return 'Instalación $id';
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
  String get currencyLabel => 'Moneda';

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
  String get viewPricingButton => 'Ver precios';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get employeeIdLabel => 'Empleado (opcional)';

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

  @override
  String get suppliersMenuTitle => 'Proveedores';

  @override
  String get labelsMenuTitle => 'Etiquetas';

  @override
  String get employeesMenuTitle => 'Empleados';

  @override
  String get customersMenuTitle => 'Clientes';

  @override
  String get taxpayerRecipientsMenuTitle => 'Receptores Fiscales';

  @override
  String get expensesMenuTitle => 'Gastos';

  @override
  String get vehiclesMenuTitle => 'Vehículos';

  @override
  String get vehicleOperatorsMenuTitle => 'Operadores de Vehículo';

  @override
  String get zoneLabel => 'Zona';

  @override
  String get creditLimitLabel => 'Límite de crédito';

  @override
  String get creditDaysLabel => 'Días de crédito';

  @override
  String get creditLimitInvalidError => 'Ingresa un monto válido no negativo.';

  @override
  String get creditDaysInvalidError =>
      'Ingresa un número entero no negativo válido.';

  @override
  String get suppliersSearchLabel => 'Buscar por código o nombre';

  @override
  String get newSupplierTooltip => 'Nuevo proveedor';

  @override
  String get noSuppliersFound => 'No se encontraron proveedores.';

  @override
  String suppliersLoadError(Object error) {
    return 'No se pudieron cargar los proveedores: $error';
  }

  @override
  String get newSupplierTitle => 'Nuevo proveedor';

  @override
  String get editSupplierTitle => 'Editar proveedor';

  @override
  String get viewSupplierTitle => 'Ver proveedor';

  @override
  String get deleteSupplierButton => 'Eliminar proveedor';

  @override
  String get deleteSupplierConfirmTitle => '¿Eliminar proveedor?';

  @override
  String deleteSupplierConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get supplierLoadFailedError => 'No se pudo cargar el proveedor.';

  @override
  String get supplierCreateFailedError => 'No se pudo crear el proveedor.';

  @override
  String get supplierUpdateFailedError => 'No se pudo actualizar el proveedor.';

  @override
  String get supplierDeleteFailedError => 'No se pudo eliminar el proveedor.';

  @override
  String get supplierCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear proveedores.';

  @override
  String get supplierUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar proveedores.';

  @override
  String get supplierDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar proveedores.';

  @override
  String get supplierCodeRequiredError => 'El código es obligatorio.';

  @override
  String get supplierNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get labelsSearchLabel => 'Buscar por nombre';

  @override
  String get newLabelTooltip => 'Nueva etiqueta';

  @override
  String get noLabelsFound => 'No se encontraron etiquetas.';

  @override
  String labelsLoadError(Object error) {
    return 'No se pudieron cargar las etiquetas: $error';
  }

  @override
  String get newLabelTitle => 'Nueva etiqueta';

  @override
  String get editLabelTitle => 'Editar etiqueta';

  @override
  String get viewLabelTitle => 'Ver etiqueta';

  @override
  String get deleteLabelButton => 'Eliminar etiqueta';

  @override
  String get deleteLabelConfirmTitle => '¿Eliminar etiqueta?';

  @override
  String deleteLabelConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get labelLoadFailedError => 'No se pudo cargar la etiqueta.';

  @override
  String get labelCreateFailedError => 'No se pudo crear la etiqueta.';

  @override
  String get labelUpdateFailedError => 'No se pudo actualizar la etiqueta.';

  @override
  String get labelDeleteFailedError => 'No se pudo eliminar la etiqueta.';

  @override
  String get labelCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear etiquetas.';

  @override
  String get labelUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar etiquetas.';

  @override
  String get labelDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar etiquetas.';

  @override
  String get labelNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get expensesSearchLabel => 'Buscar por nombre';

  @override
  String get newExpenseTooltip => 'Nuevo gasto';

  @override
  String get noExpensesFound => 'No se encontraron gastos.';

  @override
  String expensesLoadError(Object error) {
    return 'Error al cargar los gastos: $error';
  }

  @override
  String get newExpenseTitle => 'Nuevo gasto';

  @override
  String get editExpenseTitle => 'Editar gasto';

  @override
  String get viewExpenseTitle => 'Ver gasto';

  @override
  String get deleteExpenseButton => 'Eliminar gasto';

  @override
  String get deleteExpenseConfirmTitle => '¿Eliminar gasto?';

  @override
  String deleteExpenseConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get expenseLoadFailedError => 'Error al cargar el gasto.';

  @override
  String get expenseCreateFailedError => 'Error al crear el gasto.';

  @override
  String get expenseUpdateFailedError => 'Error al actualizar el gasto.';

  @override
  String get expenseDeleteFailedError => 'Error al eliminar el gasto.';

  @override
  String get expenseCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear gastos.';

  @override
  String get expenseUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar gastos.';

  @override
  String get expenseDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar gastos.';

  @override
  String get expenseNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get licensePlateLabel => 'Placa';

  @override
  String get tonsCapacityLabel => 'Capacidad en toneladas';

  @override
  String get vehiclesSearchLabel => 'Buscar por placa, nombre o apodo';

  @override
  String get newVehicleTooltip => 'Nuevo vehículo';

  @override
  String get noVehiclesFound => 'No se encontraron vehículos.';

  @override
  String vehiclesLoadError(Object error) {
    return 'Error al cargar los vehículos: $error';
  }

  @override
  String get newVehicleTitle => 'Nuevo vehículo';

  @override
  String get editVehicleTitle => 'Editar vehículo';

  @override
  String get viewVehicleTitle => 'Ver vehículo';

  @override
  String get deleteVehicleButton => 'Eliminar vehículo';

  @override
  String get deleteVehicleConfirmTitle => '¿Eliminar vehículo?';

  @override
  String deleteVehicleConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get vehicleLoadFailedError => 'Error al cargar el vehículo.';

  @override
  String get vehicleCreateFailedError => 'Error al crear el vehículo.';

  @override
  String get vehicleUpdateFailedError => 'Error al actualizar el vehículo.';

  @override
  String get vehicleDeleteFailedError => 'Error al eliminar el vehículo.';

  @override
  String get vehicleCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear vehículos.';

  @override
  String get vehicleUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar vehículos.';

  @override
  String get vehicleDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar vehículos.';

  @override
  String get vehicleLicensePlateRequiredError => 'La placa es obligatoria.';

  @override
  String get vehicleNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get vehicleNicknameRequiredError => 'El apodo es obligatorio.';

  @override
  String get vehicleTonsCapacityInvalidError =>
      'Ingresa un número entero no negativo válido.';

  @override
  String get driverLabel => 'Operador';

  @override
  String get licenseTypeLabel => 'Tipo de licencia';

  @override
  String get driverLicenseNumberLabel => 'Número de licencia';

  @override
  String get issueDateLabel => 'Fecha de expedición';

  @override
  String get expirationDateLabel => 'Fecha de vencimiento';

  @override
  String get issuingLocationLabel => 'Lugar de expedición';

  @override
  String get daysUntilExpiryColumn => 'Vencimiento';

  @override
  String expiresInDays(int days) {
    return 'Vence en $days días';
  }

  @override
  String get expiresToday => 'Vence hoy';

  @override
  String expiredDaysAgo(int days) {
    return 'Venció hace $days días';
  }

  @override
  String get vehicleOperatorsDriverFilter => 'Operador';

  @override
  String get vehicleOperatorsSearchLabel =>
      'Buscar por operador o número de licencia';

  @override
  String get newVehicleOperatorTooltip => 'Nuevo operador de vehículo';

  @override
  String get noVehicleOperatorsFound =>
      'No se encontraron operadores de vehículo.';

  @override
  String vehicleOperatorsLoadError(Object error) {
    return 'Error al cargar los operadores de vehículo: $error';
  }

  @override
  String get newVehicleOperatorTitle => 'Nuevo operador de vehículo';

  @override
  String get editVehicleOperatorTitle => 'Editar operador de vehículo';

  @override
  String get viewVehicleOperatorTitle => 'Ver operador de vehículo';

  @override
  String get deleteVehicleOperatorButton => 'Eliminar operador de vehículo';

  @override
  String get deleteVehicleOperatorConfirmTitle =>
      '¿Eliminar operador de vehículo?';

  @override
  String deleteVehicleOperatorConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get vehicleOperatorLoadFailedError =>
      'Error al cargar el operador de vehículo.';

  @override
  String get vehicleOperatorCreateFailedError =>
      'Error al crear el operador de vehículo.';

  @override
  String get vehicleOperatorUpdateFailedError =>
      'Error al actualizar el operador de vehículo.';

  @override
  String get vehicleOperatorDeleteFailedError =>
      'Error al eliminar el operador de vehículo.';

  @override
  String get vehicleOperatorCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear operadores de vehículo.';

  @override
  String get vehicleOperatorUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar operadores de vehículo.';

  @override
  String get vehicleOperatorDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar operadores de vehículo.';

  @override
  String get vehicleOperatorDriverRequiredError =>
      'El operador es obligatorio.';

  @override
  String get vehicleOperatorLicenseTypeRequiredError =>
      'El tipo de licencia es obligatorio.';

  @override
  String get vehicleOperatorDriverLicenseNumberRequiredError =>
      'El número de licencia es obligatorio.';

  @override
  String get vehicleOperatorIssueDateRequiredError =>
      'La fecha de expedición es obligatoria.';

  @override
  String get vehicleOperatorExpirationDateRequiredError =>
      'La fecha de vencimiento es obligatoria.';

  @override
  String get vehicleOperatorExpirationBeforeIssueError =>
      'La fecha de vencimiento no debe ser anterior a la fecha de expedición.';

  @override
  String get vehicleOperatorIssuingLocationRequiredError =>
      'El lugar de expedición es obligatorio.';

  @override
  String get genderFemaleLabel => 'Femenino';

  @override
  String get genderMaleLabel => 'Masculino';

  @override
  String get genderLabel => 'Género';

  @override
  String get firstNameLabel => 'Nombre(s)';

  @override
  String get lastNameLabel => 'Apellidos';

  @override
  String get nicknameLabel => 'Nombre preferido';

  @override
  String get birthdayLabel => 'Fecha de nacimiento';

  @override
  String get taxpayerIdLabel => 'RFC';

  @override
  String get salesPersonLabel => 'Vendedor';

  @override
  String get activeLabel => 'Activo';

  @override
  String get personalIdLabel => 'CURP';

  @override
  String get startJobDateLabel => 'Fecha de ingreso';

  @override
  String get enrollNumberLabel => 'Número de empleado';

  @override
  String get columnFullName => 'Nombre';

  @override
  String get employeesSearchLabel => 'Buscar por nombre o apodo';

  @override
  String get newEmployeeTooltip => 'Nuevo empleado';

  @override
  String get noEmployeesFound => 'No se encontraron empleados.';

  @override
  String employeesLoadError(Object error) {
    return 'No se pudieron cargar los empleados: $error';
  }

  @override
  String get employeesActiveFilter => 'Activo';

  @override
  String get employeesSalesPersonFilter => 'Vendedor';

  @override
  String get newEmployeeTitle => 'Nuevo empleado';

  @override
  String get editEmployeeTitle => 'Editar empleado';

  @override
  String get viewEmployeeTitle => 'Ver empleado';

  @override
  String get deleteEmployeeButton => 'Eliminar empleado';

  @override
  String get deleteEmployeeConfirmTitle => '¿Eliminar empleado?';

  @override
  String deleteEmployeeConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get employeeLoadFailedError => 'No se pudo cargar el empleado.';

  @override
  String get employeeCreateFailedError => 'No se pudo crear el empleado.';

  @override
  String get employeeUpdateFailedError => 'No se pudo actualizar el empleado.';

  @override
  String get employeeDeleteFailedError => 'No se pudo eliminar el empleado.';

  @override
  String get employeeCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear empleados.';

  @override
  String get employeeUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar empleados.';

  @override
  String get employeeDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar empleados.';

  @override
  String get employeeFirstNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get employeeLastNameRequiredError => 'Los apellidos son obligatorios.';

  @override
  String get employeeNicknameRequiredError => 'El apodo es obligatorio.';

  @override
  String get employeeGenderRequiredError => 'El género es obligatorio.';

  @override
  String get employeeBirthdayRequiredError =>
      'La fecha de nacimiento es obligatoria.';

  @override
  String get employeeStartJobDateRequiredError =>
      'La fecha de ingreso es obligatoria.';

  @override
  String get employeeEnrollNumberInvalidError =>
      'Ingresa un número entero no negativo válido.';

  @override
  String get priceListFieldLabel => 'Lista de precios';

  @override
  String get noneAssignedLabel => 'Ninguno asignado';

  @override
  String get shippingLabel => 'Envío';

  @override
  String get shippingRequiredDocumentLabel => 'El envío requiere documento';

  @override
  String get columnSalesperson => 'Vendedor';

  @override
  String get customersSearchLabel => 'Buscar por código o nombre';

  @override
  String get newCustomerTooltip => 'Nuevo cliente';

  @override
  String get noCustomersFound => 'No se encontraron clientes.';

  @override
  String customersLoadError(Object error) {
    return 'No se pudieron cargar los clientes: $error';
  }

  @override
  String get customersActiveFilter => 'Activo';

  @override
  String get customersPriceListFilterLabel => 'Lista de precios';

  @override
  String get customersSalespersonFilterLabel => 'Vendedor';

  @override
  String get newCustomerTitle => 'Nuevo cliente';

  @override
  String get editCustomerTitle => 'Editar cliente';

  @override
  String get viewCustomerTitle => 'Ver cliente';

  @override
  String get deleteCustomerButton => 'Eliminar cliente';

  @override
  String get deleteCustomerConfirmTitle => '¿Eliminar cliente?';

  @override
  String deleteCustomerConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get customerLoadFailedError => 'No se pudo cargar el cliente.';

  @override
  String get customerCreateFailedError => 'No se pudo crear el cliente.';

  @override
  String get customerUpdateFailedError => 'No se pudo actualizar el cliente.';

  @override
  String get customerDeleteFailedError => 'No se pudo eliminar el cliente.';

  @override
  String get customerCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear clientes.';

  @override
  String get customerUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar clientes.';

  @override
  String get customerDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar clientes.';

  @override
  String get customerCodeRequiredError => 'El código es obligatorio.';

  @override
  String get customerNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get customerPriceListRequiredError =>
      'La lista de precios es obligatoria.';

  @override
  String get taxpayerRecipientIdLabel => 'RFC';

  @override
  String get postalCodeFieldLabel => 'Código postal';

  @override
  String get regimeFieldLabel => 'Régimen fiscal';

  @override
  String get unresolvedFallbackLabel => 'Desconocido';

  @override
  String get taxpayerRecipientsSearchLabel => 'Buscar por nombre o correo';

  @override
  String get newTaxpayerRecipientTooltip => 'Nuevo receptor fiscal';

  @override
  String get noTaxpayerRecipientsFound =>
      'No se encontraron receptores fiscales.';

  @override
  String taxpayerRecipientsLoadError(Object error) {
    return 'No se pudieron cargar los receptores fiscales: $error';
  }

  @override
  String get newTaxpayerRecipientTitle => 'Nuevo receptor fiscal';

  @override
  String get editTaxpayerRecipientTitle => 'Editar receptor fiscal';

  @override
  String get viewTaxpayerRecipientTitle => 'Ver receptor fiscal';

  @override
  String get deleteTaxpayerRecipientButton => 'Eliminar receptor fiscal';

  @override
  String get deleteTaxpayerRecipientConfirmTitle =>
      '¿Eliminar receptor fiscal?';

  @override
  String deleteTaxpayerRecipientConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get taxpayerRecipientLoadFailedError =>
      'No se pudo cargar el receptor fiscal.';

  @override
  String get taxpayerRecipientCreateFailedError =>
      'No se pudo crear el receptor fiscal.';

  @override
  String get taxpayerRecipientUpdateFailedError =>
      'No se pudo actualizar el receptor fiscal.';

  @override
  String get taxpayerRecipientDeleteFailedError =>
      'No se pudo eliminar el receptor fiscal.';

  @override
  String get taxpayerRecipientCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear receptores fiscales.';

  @override
  String get taxpayerRecipientUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar receptores fiscales.';

  @override
  String get taxpayerRecipientDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar receptores fiscales.';

  @override
  String get taxpayerRecipientIdRequiredError => 'El RFC es obligatorio.';

  @override
  String get taxpayerRecipientNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get taxpayerRecipientEmailRequiredError => 'El correo es obligatorio.';
}
