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
  String get statusActive => 'Activo';

  @override
  String get statusInactive => 'Inactivo';

  @override
  String get statusArchived => 'Archivado';

  @override
  String get statusFilterLabel => 'Estado';

  @override
  String get statusFilterAll => 'Todos';

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

  @override
  String get facilityTypeStore => 'Tienda';

  @override
  String get facilityTypeProductionSite => 'Sitio de producción';

  @override
  String get columnFacility => 'Instalación';

  @override
  String get columnWarehouse => 'Almacén';

  @override
  String get columnComment => 'Comentario';

  @override
  String get columnType => 'Tipo';

  @override
  String get columnTaxpayer => 'Contribuyente';

  @override
  String get columnAddress => 'Dirección';

  @override
  String get columnLocation => 'Código postal';

  @override
  String get facilityFieldLabel => 'Instalación';

  @override
  String get warehouseFieldLabel => 'Almacén';

  @override
  String get unknownFacilityLabel => 'Instalación desconocida';

  @override
  String get unknownWarehouseLabel => 'Almacén desconocido';

  @override
  String get warehousesMenuTitle => 'Almacenes';

  @override
  String get warehousesSearchLabel => 'Buscar por código o nombre';

  @override
  String get newWarehouseTooltip => 'Nuevo almacén';

  @override
  String warehousesLoadError(Object error) {
    return 'No se pudieron cargar los almacenes: $error';
  }

  @override
  String get noWarehousesFound => 'No se encontraron almacenes.';

  @override
  String get viewWarehouseTitle => 'Ver Almacén';

  @override
  String get editWarehouseTitle => 'Editar Almacén';

  @override
  String get newWarehouseTitle => 'Nuevo Almacén';

  @override
  String get deleteWarehouseButton => 'Eliminar almacén';

  @override
  String get deleteWarehouseConfirmTitle => '¿Eliminar almacén?';

  @override
  String deleteWarehouseConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get warehouseLoadFailedError => 'No se pudo cargar el almacén.';

  @override
  String get warehouseCreateFailedError => 'No se pudo crear el almacén.';

  @override
  String get warehouseUpdateFailedError => 'No se pudo actualizar el almacén.';

  @override
  String get warehouseDeleteFailedError => 'No se pudo eliminar el almacén.';

  @override
  String get warehouseCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear almacenes.';

  @override
  String get warehouseUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar almacenes.';

  @override
  String get warehouseDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar almacenes.';

  @override
  String get warehouseFacilityRequiredError => 'La instalación es obligatoria.';

  @override
  String get warehouseCodeRequiredError => 'El código es obligatorio.';

  @override
  String get warehouseNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get cashDrawersMenuTitle => 'Cajas';

  @override
  String get cashDrawersSearchLabel => 'Buscar por código o nombre';

  @override
  String get newCashDrawerTooltip => 'Nueva caja';

  @override
  String cashDrawersLoadError(Object error) {
    return 'No se pudieron cargar las cajas: $error';
  }

  @override
  String get noCashDrawersFound => 'No se encontraron cajas.';

  @override
  String get viewCashDrawerTitle => 'Ver Caja';

  @override
  String get editCashDrawerTitle => 'Editar Caja';

  @override
  String get newCashDrawerTitle => 'Nueva Caja';

  @override
  String get deleteCashDrawerButton => 'Eliminar caja';

  @override
  String get deleteCashDrawerConfirmTitle => '¿Eliminar caja?';

  @override
  String deleteCashDrawerConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get cashDrawerLoadFailedError => 'No se pudo cargar la caja.';

  @override
  String get cashDrawerCreateFailedError => 'No se pudo crear la caja.';

  @override
  String get cashDrawerUpdateFailedError => 'No se pudo actualizar la caja.';

  @override
  String get cashDrawerDeleteFailedError => 'No se pudo eliminar la caja.';

  @override
  String get cashDrawerCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear cajas.';

  @override
  String get cashDrawerUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar cajas.';

  @override
  String get cashDrawerDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar cajas.';

  @override
  String get cashDrawerFacilityRequiredError =>
      'La instalación es obligatoria.';

  @override
  String get cashDrawerCodeRequiredError => 'El código es obligatorio.';

  @override
  String get cashDrawerNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get pointsOfSaleMenuTitle => 'Puntos de Venta';

  @override
  String get pointsOfSaleSearchLabel => 'Buscar por código o nombre';

  @override
  String get newPointSaleTooltip => 'Nuevo punto de venta';

  @override
  String pointsOfSaleLoadError(Object error) {
    return 'No se pudieron cargar los puntos de venta: $error';
  }

  @override
  String get noPointsOfSaleFound => 'No se encontraron puntos de venta.';

  @override
  String get viewPointSaleTitle => 'Ver Punto de Venta';

  @override
  String get editPointSaleTitle => 'Editar Punto de Venta';

  @override
  String get newPointSaleTitle => 'Nuevo Punto de Venta';

  @override
  String get deletePointSaleButton => 'Eliminar punto de venta';

  @override
  String get deletePointSaleConfirmTitle => '¿Eliminar punto de venta?';

  @override
  String deletePointSaleConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get pointSaleLoadFailedError => 'No se pudo cargar el punto de venta.';

  @override
  String get pointSaleCreateFailedError =>
      'No se pudo crear el punto de venta.';

  @override
  String get pointSaleUpdateFailedError =>
      'No se pudo actualizar el punto de venta.';

  @override
  String get pointSaleDeleteFailedError =>
      'No se pudo eliminar el punto de venta.';

  @override
  String get pointSaleCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear puntos de venta.';

  @override
  String get pointSaleUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar puntos de venta.';

  @override
  String get pointSaleDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar puntos de venta.';

  @override
  String get pointSaleFacilityRequiredError => 'La instalación es obligatoria.';

  @override
  String get pointSaleCodeRequiredError => 'El código es obligatorio.';

  @override
  String get pointSaleNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get pointSaleWarehouseRequiredError => 'El almacén es obligatorio.';

  @override
  String get facilitiesMenuTitle => 'Instalaciones';

  @override
  String get facilitiesSearchLabel => 'Buscar por código o nombre';

  @override
  String get newFacilityTooltip => 'Nueva instalación';

  @override
  String facilitiesLoadError(Object error) {
    return 'No se pudieron cargar las instalaciones: $error';
  }

  @override
  String get noFacilitiesFound => 'No se encontraron instalaciones.';

  @override
  String get viewFacilityTitle => 'Ver Instalación';

  @override
  String get editFacilityTitle => 'Editar Instalación';

  @override
  String get newFacilityTitle => 'Nueva Instalación';

  @override
  String get facilityReceiptMessageLabel => 'Mensaje del recibo';

  @override
  String get facilityDefaultBatchLabel => 'Lote predeterminado';

  @override
  String get facilityLogoLabel => 'Logotipo';

  @override
  String get deleteFacilityButton => 'Eliminar instalación';

  @override
  String get deleteFacilityConfirmTitle => '¿Eliminar instalación?';

  @override
  String deleteFacilityConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get facilityLoadFailedError => 'No se pudo cargar la instalación.';

  @override
  String get facilityCreateFailedError => 'No se pudo crear la instalación.';

  @override
  String get facilityUpdateFailedError =>
      'No se pudo actualizar la instalación.';

  @override
  String get facilityDeleteFailedError => 'No se pudo eliminar la instalación.';

  @override
  String get facilityCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear instalaciones.';

  @override
  String get facilityUpdatePermissionDeniedError =>
      'Ya no tienes permiso para editar instalaciones.';

  @override
  String get facilityDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar instalaciones.';

  @override
  String get facilityCodeRequiredError => 'El código es obligatorio.';

  @override
  String get facilityNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get facilityLocationRequiredError =>
      'El código postal es obligatorio.';

  @override
  String get facilityAddressRequiredError => 'La dirección es obligatoria.';

  @override
  String get facilityTaxpayerRequiredError =>
      'El contribuyente es obligatorio.';

  @override
  String get facilityTaxpayerInvalidError =>
      'Ingresa un RFC válido (hasta 13 caracteres).';

  @override
  String get newAddressTooltip => 'Nueva dirección';

  @override
  String get newAddressDialogTitle => 'Nueva Dirección';

  @override
  String get createAddressButton => 'Crear dirección';

  @override
  String get addressStreetLabel => 'Calle';

  @override
  String get addressExteriorNumberLabel => 'Número exterior';

  @override
  String get addressInteriorNumberLabel => 'Número interior';

  @override
  String get addressPostalCodeLabel => 'Código postal';

  @override
  String get addressNeighborhoodLabel => 'Colonia';

  @override
  String get addressLocalityLabel => 'Localidad';

  @override
  String get addressBoroughLabel => 'Municipio';

  @override
  String get addressStateLabel => 'Estado';

  @override
  String get addressCityLabel => 'Ciudad';

  @override
  String get addressCountryLabel => 'País';

  @override
  String get addressNicknameLabel => 'Alias';

  @override
  String get addressCreateFailedError => 'No se pudo crear la dirección.';

  @override
  String get addressStreetRequiredError => 'La calle es obligatoria.';

  @override
  String get addressExteriorNumberRequiredError =>
      'El número exterior es obligatorio.';

  @override
  String get addressPostalCodeRequiredError =>
      'El código postal es obligatorio.';

  @override
  String get addressNeighborhoodRequiredError => 'La colonia es obligatoria.';

  @override
  String get addressBoroughRequiredError => 'El municipio es obligatorio.';

  @override
  String get addressStateRequiredError => 'El estado es obligatorio.';

  @override
  String get addressCountryRequiredError => 'El país es obligatorio.';

  @override
  String get paymentMethodOptionsMenuTitle => 'Formas de Pago';

  @override
  String get columnPaymentMethod => 'Forma de Pago';

  @override
  String get columnNumberOfPayments => 'Pagos';

  @override
  String get paymentMethodFieldLabel => 'Forma de pago';

  @override
  String get numberOfPaymentsFieldLabel => 'Número de pagos';

  @override
  String get displayOnTicketFieldLabel => 'Mostrar en ticket';

  @override
  String get commissionFieldLabel => 'Comisión';

  @override
  String get newPaymentMethodOptionTooltip => 'Nueva forma de pago';

  @override
  String get paymentMethodOptionsSearchLabel => 'Buscar por nombre';

  @override
  String get noPaymentMethodOptionsFound => 'No se encontraron formas de pago.';

  @override
  String paymentMethodOptionsLoadError(Object error) {
    return 'Error al cargar las formas de pago: $error';
  }

  @override
  String get viewPaymentMethodOptionTitle => 'Ver Forma de Pago';

  @override
  String get editPaymentMethodOptionTitle => 'Editar Forma de Pago';

  @override
  String get newPaymentMethodOptionTitle => 'Nueva Forma de Pago';

  @override
  String get deletePaymentMethodOptionButton => 'Eliminar forma de pago';

  @override
  String get deletePaymentMethodOptionConfirmTitle =>
      '¿Eliminar forma de pago?';

  @override
  String deletePaymentMethodOptionConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get paymentMethodOptionLoadFailedError =>
      'No se pudo cargar la forma de pago.';

  @override
  String get paymentMethodOptionCreateFailedError =>
      'No se pudo crear la forma de pago.';

  @override
  String get paymentMethodOptionUpdateFailedError =>
      'No se pudo actualizar la forma de pago.';

  @override
  String get paymentMethodOptionDeleteFailedError =>
      'No se pudo eliminar la forma de pago.';

  @override
  String get paymentMethodOptionCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear formas de pago.';

  @override
  String get paymentMethodOptionUpdatePermissionDeniedError =>
      'Ya no tienes permiso para actualizar formas de pago.';

  @override
  String get paymentMethodOptionDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar formas de pago.';

  @override
  String get paymentMethodOptionFacilityRequiredError =>
      'La instalación es obligatoria.';

  @override
  String get paymentMethodOptionNameRequiredError =>
      'El nombre es obligatorio.';

  @override
  String get paymentMethodOptionPaymentMethodRequiredError =>
      'La forma de pago es obligatoria.';

  @override
  String get paymentMethodOptionNumberOfPaymentsInvalidError =>
      'El número de pagos debe ser al menos 1.';

  @override
  String get paymentMethodOptionCommissionInvalidError =>
      'La comisión debe ser un número no negativo.';

  @override
  String get paymentMethodNa => 'No aplica';

  @override
  String get paymentMethodCash => 'Efectivo';

  @override
  String get paymentMethodCheck => 'Cheque nominativo';

  @override
  String get paymentMethodEft => 'Transferencia electrónica de fondos';

  @override
  String get paymentMethodCreditCard => 'Tarjeta de crédito';

  @override
  String get paymentMethodElectronicPurse => 'Monedero electrónico';

  @override
  String get paymentMethodElectronicMoney => 'Dinero electrónico';

  @override
  String get paymentMethodFoodVouchers => 'Vales de despensa';

  @override
  String get paymentMethodGiving => 'Dación en pago';

  @override
  String get paymentMethodCreditorSatisfaction => 'A satisfacción del acreedor';

  @override
  String get paymentMethodDebitCard => 'Tarjeta de débito';

  @override
  String get paymentMethodServiceCard => 'Tarjeta de servicio';

  @override
  String get paymentMethodAdvancePayments => 'Aplicación de anticipos';

  @override
  String get paymentMethodToBeDefined => 'Por definir';

  @override
  String get paymentMethodGovernmentFunding => 'Financiamiento gubernamental';

  @override
  String get taxpayerIssuersMenuTitle => 'Razones Sociales';

  @override
  String get columnRfc => 'RFC';

  @override
  String get columnPostalCodeShort => 'C.P.';

  @override
  String get columnRegime => 'Régimen Fiscal';

  @override
  String get rfcFieldLabel => 'RFC';

  @override
  String get providerFieldLabel => 'Proveedor de certificación';

  @override
  String get newTaxpayerIssuerTooltip => 'Nueva razón social';

  @override
  String get taxpayerIssuersSearchLabel => 'Buscar por RFC o nombre';

  @override
  String get noTaxpayerIssuersFound => 'No se encontraron razones sociales.';

  @override
  String taxpayerIssuersLoadError(Object error) {
    return 'Error al cargar las razones sociales: $error';
  }

  @override
  String get viewTaxpayerIssuerTitle => 'Ver Razón Social';

  @override
  String get editTaxpayerIssuerTitle => 'Editar Razón Social';

  @override
  String get newTaxpayerIssuerTitle => 'Nueva Razón Social';

  @override
  String get deleteTaxpayerIssuerButton => 'Eliminar razón social';

  @override
  String get deleteTaxpayerIssuerConfirmTitle => '¿Eliminar razón social?';

  @override
  String deleteTaxpayerIssuerConfirmMessage(String name) {
    return 'Esto eliminará permanentemente \"$name\". Esta acción no se puede deshacer.';
  }

  @override
  String get taxpayerIssuerLoadFailedError =>
      'No se pudo cargar la razón social.';

  @override
  String get taxpayerIssuerCreateFailedError =>
      'No se pudo crear la razón social.';

  @override
  String get taxpayerIssuerUpdateFailedError =>
      'No se pudo actualizar la razón social.';

  @override
  String get taxpayerIssuerDeleteFailedError =>
      'No se pudo eliminar la razón social.';

  @override
  String get taxpayerIssuerCreatePermissionDeniedError =>
      'Ya no tienes permiso para crear razones sociales.';

  @override
  String get taxpayerIssuerUpdatePermissionDeniedError =>
      'Ya no tienes permiso para actualizar razones sociales.';

  @override
  String get taxpayerIssuerDeletePermissionDeniedError =>
      'Ya no tienes permiso para eliminar razones sociales.';

  @override
  String get taxpayerIssuerRfcRequiredError => 'El RFC es obligatorio.';

  @override
  String get taxpayerIssuerNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get taxpayerIssuerRegimeRequiredError =>
      'El régimen fiscal es obligatorio.';

  @override
  String get fiscalCertificationProviderNone => 'Ninguno';

  @override
  String get fiscalCertificationProviderDiverza => 'Diverza';

  @override
  String get fiscalCertificationProviderFiscoClic => 'FiscoClic';

  @override
  String get fiscalCertificationProviderServisim => 'Servisim';

  @override
  String get fiscalCertificationProviderProFact => 'ProFact';

  @override
  String get certificatesSectionTitle => 'Certificados';

  @override
  String get columnCertificateNumber => 'Número de Certificado';

  @override
  String get columnValidFrom => 'Desde';

  @override
  String get columnValidTo => 'Hasta';

  @override
  String get addCertificateButton => 'Agregar';

  @override
  String get noCertificatesFound => 'No hay certificados registrados.';

  @override
  String certificatesLoadError(Object error) {
    return 'Error al cargar los certificados: $error';
  }

  @override
  String get newCertificateDialogTitle => 'Registrar Certificado';

  @override
  String get certificateFileLabel => 'Archivo de certificado (.cer)';

  @override
  String get keyFileLabel => 'Archivo de llave (.key)';

  @override
  String get keyPasswordLabel => 'Contraseña de la llave';

  @override
  String get chooseFileButton => 'Elegir archivo';

  @override
  String get uploadCertificateButton => 'Registrar';

  @override
  String get certificateFileRequiredError =>
      'Selecciona un archivo de certificado (.cer).';

  @override
  String get keyFileRequiredError => 'Selecciona un archivo de llave (.key).';

  @override
  String get keyPasswordRequiredError =>
      'La contraseña de la llave es obligatoria.';

  @override
  String get certificateUploadFailedError =>
      'No se pudo registrar el certificado.';
}
