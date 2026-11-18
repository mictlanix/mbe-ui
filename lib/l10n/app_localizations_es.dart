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
  String get errorValidationGeneric => 'Corrige los campos marcados.';

  @override
  String get errorAuthGeneric => 'Usuario o contraseña incorrectos.';

  @override
  String get errorNotFoundGeneric => 'No se encontró el elemento solicitado.';

  @override
  String get errorServerGeneric =>
      'Ocurrió un error en el servidor. Inténtalo de nuevo más tarde.';

  @override
  String get errorNetworkGeneric =>
      'No se pudo conectar con el servidor. Verifica tu conexión e inténtalo de nuevo.';

  @override
  String get errorCreditHoldGeneric =>
      'Este cliente no puede recibir crédito en este momento.';

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
  String get loginTagline => 'Toda la operación, en un solo lugar.';

  @override
  String get loginSubhead =>
      'Catálogos, precios, instalaciones y ventas de tus sucursales sincronizados en tiempo real.';

  @override
  String get changePasswordMenuTitle => 'Cambiar contraseña';

  @override
  String get appTitle => 'Mictlanix Business Essentials';

  @override
  String get homeMenuTitle => 'Inicio';

  @override
  String get homeWelcomeMessage => 'Bienvenido';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get homeSummary =>
      'Tienes listas de precios por autorizar e instalaciones con el corte de caja de ayer pendiente.';

  @override
  String get homeReviewPendingButton => 'Revisar pendientes';

  @override
  String get homeNewSaleButton => 'Nueva venta';

  @override
  String get catalogsGroupTitle => 'Catálogos';

  @override
  String get salesGroupTitle => 'Ventas';

  @override
  String get logisticsGroupTitle => 'Logística';

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
  String get settingsMenuTitle => 'Configuración';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAppearanceLabel => 'Apariencia';

  @override
  String get settingsAppearanceLight => 'Claro';

  @override
  String get settingsAppearanceDark => 'Oscuro';

  @override
  String get settingsAppearanceSystem => 'Sistema';

  @override
  String get settingsTextSizeLabel => 'Tamaño de texto';

  @override
  String get settingsTextSizeSmall => 'Pequeño';

  @override
  String get settingsTextSizeNormal => 'Normal';

  @override
  String get settingsTextSizeLarge => 'Grande';

  @override
  String get settingsTextSizeExtraLarge => 'Muy grande';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageSystem => 'Igual que el sistema';

  @override
  String get usersTitle => 'Usuarios';

  @override
  String get newUserTooltip => 'Nuevo usuario';

  @override
  String get usersSearchLabel => 'Buscar por usuario o correo';

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
  String get productsPerishableFilter => 'Perecedero';

  @override
  String get productsSeriableFilter => 'Con número de serie';

  @override
  String get productsInvoiceableFilter => 'Facturable';

  @override
  String get productsAttributesFilterLabel => 'Atributos del producto';

  @override
  String get productsSupplierFilter => 'Proveedor';

  @override
  String get productsSupplierSearchHint => 'Buscar proveedores…';

  @override
  String get productsLabelFilter => 'Etiquetas';

  @override
  String get advancedSearchButton => 'Búsqueda avanzada';

  @override
  String get advancedSearchTitle => 'Búsqueda avanzada';

  @override
  String advancedSearchAddButton(int count) {
    return 'Agregar ($count)';
  }

  @override
  String advancedSearchSelectionCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get advancedSearchClearSelection => 'Limpiar selección';

  @override
  String get advancedSearchNoSaleHint =>
      'Ábrela desde una venta para agregar productos';

  @override
  String get advancedSearchSkipped => 'No se pudieron agregar estos productos:';

  @override
  String advancedSearchAdding(int done, int total) {
    return 'Agregando $done de $total…';
  }

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
  String get retryButton => 'Reintentar';

  @override
  String get clearFiltersButton => 'Limpiar filtros';

  @override
  String get filteredEmptyTitle => 'No se encontraron coincidencias';

  @override
  String get filteredEmptyMessage => 'Intenta ajustar o borrar tus filtros.';

  @override
  String get loadErrorTitle => 'No se pudo cargar la lista';

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
  String mergeConfirmMessage(
    String canonicalName,
    String canonicalCode,
    String duplicateName,
    String duplicateCode,
  ) {
    return 'Se conserva \"$canonicalName\" ($canonicalCode).\nSe elimina \"$duplicateName\" ($duplicateCode) y su historial pasa al producto conservado. Esta acción no se puede deshacer.';
  }

  @override
  String mergeConfirmTotalLine(int total) {
    return 'Registros que se moverán: $total.';
  }

  @override
  String get mergeSuccess => 'Productos fusionados correctamente.';

  @override
  String get mergeKeptLabel => 'Se conserva';

  @override
  String get mergeDeletedLabel => 'Se elimina';

  @override
  String get mergeSwapTooltip =>
      'Invertir: intercambiar cuál se conserva y cuál se elimina';

  @override
  String get mergeComparisonTitle => 'Comparación de datos';

  @override
  String get mergeComparisonFieldHeader => 'Campo';

  @override
  String get mergeDiffBadge => 'Difiere';

  @override
  String mergeAcknowledgeLabel(String duplicateName) {
    return 'Entiendo que \"$duplicateName\" se eliminará permanentemente.';
  }

  @override
  String get mergeFieldId => 'ID interno';

  @override
  String get mergeFieldCode => 'Código';

  @override
  String get mergeFieldSku => 'SKU';

  @override
  String get mergeFieldModel => 'Modelo';

  @override
  String get mergeFieldBrand => 'Marca';

  @override
  String get mergeFieldUom => 'Unidad de medida';

  @override
  String get mergeFieldTaxRate => 'Tasa de impuesto';

  @override
  String get mergeFieldStatus => 'Estado';

  @override
  String get mergeRelatedRecordsTitle =>
      'Registros ligados al producto que se elimina';

  @override
  String get mergeRelatedDestroyedNote => 'se eliminan, no se mueven';

  @override
  String get mergeRelatedTotalLabel => 'Total';

  @override
  String get mergeCategorySalesOrderDetail => 'Líneas de venta';

  @override
  String get mergeCategoryPurchaseOrderDetail => 'Líneas de compra';

  @override
  String get mergeCategoryInventoryReceiptDetail =>
      'Líneas de entrada de inventario';

  @override
  String get mergeCategoryInventoryIssueDetail =>
      'Líneas de salida de inventario';

  @override
  String get mergeCategoryInventoryTransferDetail =>
      'Líneas de traspaso de inventario';

  @override
  String get mergeCategoryLotSerialTracking => 'Seguimiento de lotes y series';

  @override
  String get mergeCategoryProductPrice => 'Listas de precios';

  @override
  String get mergeCategoryProductLabel => 'Etiquetas';

  @override
  String get mergeCategoryFiscalDocumentDetail =>
      'Líneas de comprobantes fiscales';

  @override
  String get mergeCategoryCommissionProduct => 'Comisiones';

  @override
  String get mergeCategoryCustomerDiscount => 'Descuentos de cliente';

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
  String get employeeIdLabel => 'Empleado';

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
  String get userEmployeeRequiredError => 'El empleado es obligatorio.';

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
  String get pricingGridHint =>
      'Haz clic en un precio para editarlo · Enter guarda y baja una fila · Tab mueve a la derecha · Esc cancela';

  @override
  String get pricingGridReadOnlyHint =>
      'Solo lectura: tu perfil no tiene privilegio de actualización sobre Precios.';

  @override
  String get pricingGridColumnsFilterLabel => 'Listas de precios mostradas';

  @override
  String get pricingGridWorklistAll => 'Todos los productos';

  @override
  String pricingGridWorklistMissing(String priceListName, int count) {
    return 'Falta $priceListName ($count)';
  }

  @override
  String get pricingGridColumnActionsTooltip => 'Acciones de columna';

  @override
  String get pricingGridFillDown => 'Rellenar desde la primera fila';

  @override
  String pricingGridCopyFromCost(String costListName) {
    return 'Copiar desde $costListName';
  }

  @override
  String get pricingGridAdjustLabel => 'Ajustar cada fila mostrada en';

  @override
  String get pricingGridAdjustApply => 'Aplicar';

  @override
  String pricingGridRowsChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count precios cambiados',
      one: '1 precio cambiado',
      zero: 'Ningún precio cambió',
    );
    return '$_temp0';
  }

  @override
  String get pricingGridColumnActionFailed =>
      'No se pudo aplicar la acción. Ningún precio cambió.';

  @override
  String get pricingGridCellSaving => 'Guardando…';

  @override
  String pricingGridCellSaved(String previous) {
    return 'Guardado · antes $previous';
  }

  @override
  String get pricingGridCellSavedNew => 'Guardado · precio nuevo';

  @override
  String pricingGridSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count precios cambiados',
      one: '1 precio cambiado',
    );
    return '$_temp0';
  }

  @override
  String pricingGridSummaryRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rechazados',
      one: '1 rechazado',
    );
    return '$_temp0';
  }

  @override
  String get pricingGridUndoLast => 'Deshacer último';

  @override
  String get pricingGridRevertAll => 'Revertir todo';

  @override
  String get pricingGridDismissRejected => 'Descartar rechazados';

  @override
  String get pricingGridDiscardTitle => '¿Descartar los cambios pendientes?';

  @override
  String get pricingGridDiscardBody =>
      'Se perderá el historial para deshacer y el texto rechazado. Los precios ya guardados no cambian.';

  @override
  String get pricingGridDiscardConfirm => 'Salir de todos modos';

  @override
  String get pricingGridDiscardCancel => 'Quedarse';

  @override
  String get exchangeRatesMenuTitle => 'Tipos de Cambio';

  @override
  String get priceListsSearchLabel => 'Buscar por nombre';

  @override
  String get newPriceListTooltip => 'Nueva lista de precios';

  @override
  String get noPriceListsFound => 'No se encontraron listas de precios.';

  @override
  String get priceListNameLabel => 'Nombre';

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
  String priceListDeleteLead(String name, int id) {
    return '$name #$id se eliminará de forma permanente. Esta acción no se puede deshacer.';
  }

  @override
  String get priceListDeleteRelatedTitle =>
      'Registros asociados a esta lista de precios';

  @override
  String get priceListDeleteTotalLabel => 'Total';

  @override
  String get priceListDeleteTotalCaption =>
      'Registros que esta eliminación afecta; no todos se eliminan.';

  @override
  String get priceListDeleteFateDestroyed => 'se elimina de forma permanente';

  @override
  String get priceListDeleteFateMoved => 'se traslada al reemplazo';

  @override
  String get priceListDeleteFateBlocking =>
      'bloquea la eliminación: primero hay que resolverlo';

  @override
  String get priceListDeleteCategoryProductPrice => 'Precios de productos';

  @override
  String get priceListDeleteCategoryCustomer => 'Clientes';

  @override
  String get priceListDeleteViewCustomers => 'Ver clientes';

  @override
  String get priceListDeleteCleanNote =>
      'Ningún precio ni cliente depende de esta lista.';

  @override
  String get priceListDeleteConfirm => 'Eliminar lista';

  @override
  String priceListDeleteConfirmPrices(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar lista y $formatted precios',
      one: 'Eliminar lista y 1 precio',
    );
    return '$_temp0';
  }

  @override
  String get priceListDeletedMessage => 'Lista de precios eliminada.';

  @override
  String get priceListDeleteReplacementLabel => 'Lista de precios de reemplazo';

  @override
  String get priceListDeleteReplacementLabelOptional =>
      'Lista de precios de reemplazo (opcional)';

  @override
  String get priceListDeleteReplacementRequiredHelper =>
      'Obligatorio: todos los clientes de esta lista se trasladan aquí.';

  @override
  String get priceListDeleteReplacementOptionalHelper =>
      'Opcional: solo se usa si resulta que hay clientes asignados.';

  @override
  String priceListDeleteReplacementChosenHelper(
    int count,
    String formatted,
    String name,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted clientes se trasladan a $name.',
      one: '1 cliente se traslada a $name.',
    );
    return '$_temp0';
  }

  @override
  String priceListDeleteConfirmCustomers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar lista y trasladar $formatted clientes',
      one: 'Eliminar lista y trasladar 1 cliente',
    );
    return '$_temp0';
  }

  @override
  String priceListDeletedWithMoveMessage(
    int count,
    String formatted,
    String name,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Lista de precios eliminada. $formatted clientes trasladados a $name.',
      one: 'Lista de precios eliminada. 1 cliente trasladado a $name.',
    );
    return '$_temp0';
  }

  @override
  String get priceListDeleteAcknowledge =>
      'Entiendo que esta acción no se puede deshacer y que los precios de esta lista se eliminan junto con ella.';

  @override
  String get priceListDeleteBlockedBanner =>
      'Esta lista todavía está en uso por registros que la eliminación no puede resolver. Primero hay que resolverlos y después eliminar la lista.';

  @override
  String get priceListDeletePreviewFailedNote =>
      'No se pudo cargar lo que depende de esta lista. Aún puedes eliminarla; si hay clientes asignados, la eliminación será rechazada.';

  @override
  String get priceListDeleteClose => 'Cerrar';

  @override
  String get priceListNameRequiredError => 'El nombre es obligatorio.';

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
  String get supplierSaveConflictError =>
      'Ya existe un proveedor con ese código, o uno de los registros vinculados ya no existe. Revisa el código y los vínculos y vuelve a guardar.';

  @override
  String get supplierDeleteConflictError =>
      'No se puede eliminar el proveedor mientras tenga direcciones, contactos, cuentas bancarias o convenios. Desvincúlalos y elimina los convenios primero.';

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
  String get licensePhotoLabel => 'Foto de la licencia';

  @override
  String get licensePhotoUnavailable => 'Foto no disponible';

  @override
  String get licensePhotoInvalidTypeError =>
      'La foto debe ser un archivo JPEG o PNG.';

  @override
  String get licensePhotoTooLargeError => 'La foto debe ser de 2 MB o menos.';

  @override
  String get licensePhotoSaveFailedError =>
      'El operador se guardó, pero no se pudo guardar la foto de la licencia. Presiona Guardar para intentar de nuevo.';

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
  String get columnSalesperson => 'Vendedor';

  @override
  String get customersSearchLabel => 'Buscar por código o nombre';

  @override
  String get newCustomerTooltip => 'Nuevo cliente';

  @override
  String get noCustomersFound => 'No se encontraron clientes.';

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
  String get facilityTypeProductionSite => 'Planta';

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
  String get facilityLogoUploadButton => 'Subir logotipo';

  @override
  String get facilityLogoReplaceButton => 'Cambiar logotipo';

  @override
  String get facilityLogoRemoveButton => 'Quitar logotipo';

  @override
  String get facilityLogoInvalidTypeError =>
      'El logotipo debe ser un archivo JPEG o PNG.';

  @override
  String get facilityLogoTooLargeError =>
      'El logotipo debe ser de 2 MB o menos.';

  @override
  String get facilityLogoUploadFailedError =>
      'La instalación se guardó, pero el logotipo no se pudo subir. Intenta de nuevo.';

  @override
  String get facilityLogoRemoveFailedError =>
      'La instalación se guardó, pero el logotipo no se pudo quitar. Intenta de nuevo.';

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
  String get facilitiesExpandAll => 'Expandir todo';

  @override
  String get facilitiesCollapseAll => 'Contraer todo';

  @override
  String get noWarehousesInFacility => 'Sin almacenes registrados.';

  @override
  String get noPointsOfSaleInFacility => 'Sin puntos de venta.';

  @override
  String get noCashDrawersInFacility => 'Sin cajas registradas.';

  @override
  String get pointSaleForeignFacilityBadge => 'Otra instalación';

  @override
  String get newWarehouseInFacility => 'Almacén';

  @override
  String get newPointSaleInFacility => 'Punto de venta';

  @override
  String get newCashDrawerInFacility => 'Caja';

  @override
  String get facilityChildrenLoadFailed =>
      'No se pudieron cargar los elementos de esta instalación.';

  @override
  String facilitiesPaginationSummary(int start, int end, int total) {
    return '$start–$end de $total instalaciones';
  }

  @override
  String get previousPageTooltip => 'Página anterior';

  @override
  String get nextPageTooltip => 'Página siguiente';

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

  @override
  String get cashSessionsMenuTitle => 'Sesiones de Caja';

  @override
  String get posMenuTitle => 'Punto de Venta';

  @override
  String get salesOrdersMenuTitle => 'Pedidos';

  @override
  String get salesQuotesMenuTitle => 'Cotizaciones';

  @override
  String get salesOrdersScreenTitle => 'Pedidos';

  @override
  String get salesOrderNewAction => 'Nuevo pedido';

  @override
  String get salesOrdersColumnReference => 'Referencia';

  @override
  String get salesOrdersColumnDate => 'Fecha';

  @override
  String get salesOrdersColumnCustomer => 'Cliente';

  @override
  String get salesOrdersColumnStatus => 'Estado';

  @override
  String get salesOrdersColumnTotal => 'Total';

  @override
  String get salesOrdersColumnBalance => 'Saldo';

  @override
  String get salesOrdersSearchLabel => 'Buscar pedidos';

  @override
  String get salesOrderReferenceLabel => 'Referencia';

  @override
  String get salesOrderStatusLabel => 'Estado';

  @override
  String get salesOrderDateLabel => 'Fecha';

  @override
  String get salesOrderDueDateLabel => 'Fecha de vencimiento';

  @override
  String get salesOrderExchangeRateLabel => 'Tipo de cambio';

  @override
  String get salesOrderPaymentTermsLabel => 'Forma de pago';

  @override
  String get salesOrderPromiseDateLabel => 'Límite para envío';

  @override
  String get salesOrderCurrencyLabel => 'Moneda';

  @override
  String get salesOrderPriorityLabel => 'Prioridad';

  @override
  String get salesOrderSalespersonLabel => 'Vendedor';

  @override
  String get salesOrderRecipientLabel => 'RFC';

  @override
  String get salesOrderCommentLabel => 'Comentario';

  @override
  String get salesOrderMoreDetails => 'Más detalles';

  @override
  String get salesOrderFewerDetails => 'Menos detalles';

  @override
  String get salesQuoteConfirmAction => 'Confirmar cotización';

  @override
  String get salesQuoteStatusDraft => 'Borrador';

  @override
  String get salesQuoteStatusCompleted => 'Confirmada';

  @override
  String get salesQuoteStatusCancelled => 'Cancelada';

  @override
  String get salesQuoteReferenceLabel => 'Referencia';

  @override
  String get salesQuoteStatusLabel => 'Estado';

  @override
  String get salesQuoteDateLabel => 'Fecha';

  @override
  String get salesQuoteMoreDetails => 'Más detalles';

  @override
  String get salesQuoteFewerDetails => 'Menos detalles';

  @override
  String get salesQuoteExpiryLabel => 'Fecha de vencimiento';

  @override
  String get salesQuoteCurrencyLabel => 'Moneda';

  @override
  String get salesQuoteCommentLabel => 'Comentario';

  @override
  String get salesQuoteConvertAction => 'Convertir a pedido';

  @override
  String get salesQuoteDuplicateAction => 'Duplicar';

  @override
  String get salesQuoteNewAction => 'Nueva cotización';

  @override
  String get salesQuotesColumnReference => 'Referencia';

  @override
  String get salesQuotesColumnCustomer => 'Cliente';

  @override
  String get salesQuotesColumnDate => 'Fecha';

  @override
  String get salesQuotesColumnExpiry => 'Vencimiento';

  @override
  String get salesQuotesColumnStatus => 'Estado';

  @override
  String get salesQuotesColumnTotal => 'Total';

  @override
  String get salesQuotesSearchLabel => 'Buscar cotizaciones';

  @override
  String get salesQuotesStatusFilterLabel => 'Estado';

  @override
  String get salesQuotesCustomerFilterLabel => 'Cliente';

  @override
  String get salesQuoteExpiredBadge => 'Vencida';

  @override
  String get salesQuoteCancelAction => 'Cancelar cotización';

  @override
  String get salesQuoteCancelDialogTitle => '¿Cancelar esta cotización?';

  @override
  String get salesQuoteCancelDialogMessage =>
      'Esta acción no se puede deshacer. La cotización pasará a estado cancelada.';

  @override
  String get salesQuoteCancelDialogKeepEditing => 'Seguir editando';

  @override
  String get salesQuoteCancelDialogConfirm => 'Cancelar cotización';

  @override
  String get salesOrderPriorityLow => 'Baja';

  @override
  String get salesOrderPriorityNormal => 'Normal';

  @override
  String get salesOrderPriorityHigh => 'Alta';

  @override
  String get salesOrderPriorityCritical => 'Crítica';

  @override
  String get salesOrderNoRegisterTitle => 'No hay punto de venta configurado';

  @override
  String get salesOrderNoRegisterMessage =>
      'Tu cuenta no tiene un punto de venta asignado, así que no puedes crear pedidos nuevos. Pide a tu administrador que configure uno en tu usuario.';

  @override
  String get salesOrderNoFacilityTitle => 'No hay instalación configurada';

  @override
  String get salesOrderNoFacilityMessage =>
      'Tu cuenta no tiene una instalación asignada, así que los pedidos no se pueden listar. Pide a tu administrador que configure una en tu usuario.';

  @override
  String get salesOrderConfirmAction => 'Confirmar pedido';

  @override
  String get salesOrderNoLinesYet =>
      'Agrega al menos un producto para poder confirmar el pedido.';

  @override
  String get salesOrderChooseCustomerFirst =>
      'Elige un cliente para empezar el pedido.';

  @override
  String get salesOrderStepVenta => 'Venta';

  @override
  String get salesOrderStepEntrega => 'Entrega';

  @override
  String salesOrderStepProgress(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get salesOrderContinueToDeliveryAction => 'Continuar a entrega';

  @override
  String get salesOrderCompleteDeliveryAction => 'Completar pedido';

  @override
  String get salesOrderForeignOrderTitle =>
      'Este pedido no se puede editar aquí';

  @override
  String get salesOrderForeignOrderMessage =>
      'Se originó en el punto de venta. Ábrelo desde Ventas.';

  @override
  String get salesOrdersEmptyMessage => 'Aún no hay pedidos en este periodo.';

  @override
  String get salesOrderCancelAction => 'Cancelar pedido';

  @override
  String get salesOrderCancelDialogTitle => '¿Cancelar este pedido?';

  @override
  String get salesOrderCancelDialogMessage =>
      'Esta acción no se puede deshacer. El pedido pasará a estado cancelado.';

  @override
  String get salesOrderCancelDialogKeepEditing => 'Seguir editando';

  @override
  String get salesOrderCancelDialogConfirm => 'Cancelar pedido';

  @override
  String get salesOrderSalespersonEveryone => 'Todos';

  @override
  String get salesOrderCrossFacilityNotice =>
      'El pedido se creará en tu propia instalación, sin importar la instalación que estés viendo.';

  @override
  String get cashSessionStatusOpen => 'Abierta';

  @override
  String get cashSessionStatusStale => 'Vencida';

  @override
  String get cashSessionStatusClosed => 'Cerrada';

  @override
  String get cashSessionDrawerFieldLabel => 'Caja';

  @override
  String get cashSessionCashierFieldLabel => 'Cajero';

  @override
  String get cashSessionStartFieldLabel => 'Inicio';

  @override
  String get cashSessionEndFieldLabel => 'Fin';

  @override
  String get cashSessionOpenButtonLabel => 'Abrir sesión';

  @override
  String get cashSessionOpeningAmountFieldLabel => 'Monto inicial';

  @override
  String get cashSessionNoOpenSessionMessage =>
      'No tienes una sesión de caja abierta.';

  @override
  String get cashSessionDrawerBlockedMessage =>
      'Debe asignarse una caja a tu usuario antes de poder abrir una sesión. Contacta a tu administrador.';

  @override
  String get cashSessionDrawerBusyError =>
      'Esa caja ya tiene una sesión abierta. Elige otra caja.';

  @override
  String get cashSessionCashierBusyError =>
      'Ya tienes una sesión abierta. Cierra esa sesión antes de abrir otra.';

  @override
  String get cashSessionCloseButtonLabel => 'Cerrar sesión';

  @override
  String get cashSessionShiftSheetTitle => 'Turno';

  @override
  String get cashSessionShiftButtonTooltip => 'Turno';

  @override
  String get cashSessionPaymentsByMethodLabel =>
      'Pagos recibidos en este turno';

  @override
  String get cashSessionStaleWarningMessage =>
      'Esta sesión se abrió en un día anterior y debe cerrarse antes de continuar vendiendo.';

  @override
  String get cashSessionOpenFailedError =>
      'No se pudo abrir la sesión de caja.';

  @override
  String get cashSessionOpenPermissionDeniedError =>
      'Ya no tienes permiso para abrir una sesión de caja.';

  @override
  String get cashSessionCountedTotalLabel => 'Total contado';

  @override
  String get cashSessionExpectedCashLabel => 'Efectivo esperado';

  @override
  String get cashSessionDifferenceLabel => 'Diferencia';

  @override
  String get cashSessionDifferenceOver => 'Sobrante';

  @override
  String get cashSessionDifferenceShort => 'Faltante';

  @override
  String get cashSessionDifferenceZero => 'Exacto';

  @override
  String get cashSessionAdvisoryNote =>
      'Solo informativo: el monto inicial más las ventas en efectivo de este turno, ya sin el cambio entregado, menos gastos y devoluciones en efectivo.';

  @override
  String get cashSessionEmptyCountConfirmTitle => 'Confirmar caja vacía';

  @override
  String get cashSessionEmptyCountConfirmMessage =>
      'Todas las denominaciones están en cero. Confirma que se contó la caja y se encontró vacía antes de cerrar.';

  @override
  String get cashSessionConfirmEmptyCountButton => 'Confirmar vacía';

  @override
  String get cashSessionAlreadyClosedError => 'Esta sesión ya está cerrada.';

  @override
  String get cashSessionSupervisorRequiredMessage =>
      'Un usuario con permiso de cierre debe cerrar esta sesión.';

  @override
  String get cashSessionClosedByFieldLabel => 'Cerrada por';

  @override
  String get cashSessionQuantityInvalidError =>
      'Ingresa un número entero no negativo válido para cada denominación.';

  @override
  String get cashSessionSessionNotFoundError => 'Esta sesión ya no existe.';

  @override
  String get cashSessionCloseFailedError =>
      'No se pudo cerrar la sesión de caja.';

  @override
  String get cashSessionClosePermissionDeniedError =>
      'Ya no tienes permiso para cerrar una sesión de caja.';

  @override
  String get cashSessionCloseSuccessTitle => 'Sesión cerrada';

  @override
  String cashSessionCloseSuccessMessage(
    String counted,
    String expected,
    String difference,
  ) {
    return 'Contado $counted, esperado $expected, diferencia $difference.';
  }

  @override
  String get cashSessionViewTitle => 'Sesión de caja';

  @override
  String get cashSessionLoadFailedError =>
      'No se pudo cargar la sesión de caja.';

  @override
  String get okButton => 'Aceptar';

  @override
  String get cashSessionsListEmptyMessage =>
      'No se encontraron sesiones de caja.';

  @override
  String get cashSessionsFilterDrawerLabel => 'Caja';

  @override
  String get cashSessionsFilterCashierLabel => 'Cajero';

  @override
  String get cashSessionsFilterStatusLabel => 'Estado';

  @override
  String get cashSessionColumnDrawer => 'Caja';

  @override
  String get cashSessionColumnCashier => 'Cajero';

  @override
  String get cashSessionColumnStart => 'Inicio';

  @override
  String get cashSessionColumnEnd => 'Fin';

  @override
  String get cashSessionColumnStatus => 'Estado';

  @override
  String get cashSessionOtherSessionsWarningMessage =>
      'Podrías tener otras sesiones abiertas que requieren atención. Revisa el historial más abajo.';

  @override
  String get posGateNoSessionTitle => 'No hay una sesión de caja abierta';

  @override
  String get posGateNoSessionBody =>
      'Debes abrir una sesión de caja antes de iniciar una venta.';

  @override
  String get posGateOpenSessionAction => 'Ir a sesiones de caja';

  @override
  String get posStaleSessionBanner => 'La sesión de caja está vencida.';

  @override
  String get posStepVenta => 'Venta';

  @override
  String get posStepCobro => 'Cobro';

  @override
  String get posStepEntrega => 'Entrega';

  @override
  String get posSaleCompletedTitle => 'Venta completada';

  @override
  String posSaleReference(String reference) {
    return 'Folio #$reference';
  }

  @override
  String get posNewSaleAction => 'Nueva venta';

  @override
  String get posCustomerLabel => 'Cliente';

  @override
  String get posPaymentTermsImmediate => 'Contado';

  @override
  String get posPaymentTermsCredit => 'Crédito';

  @override
  String get posFulfillmentCounter => 'Tienda';

  @override
  String get posFulfillmentDelivery => 'Domicilio';

  @override
  String get posFulfillmentMixed => 'Mixta';

  @override
  String get posProductSearchLabel => 'Buscar o escanear producto';

  @override
  String get posProductSearchNoResults => 'Sin resultados';

  @override
  String get posRemoveLineTooltip => 'Eliminar línea';

  @override
  String get posLineQuantityLabel => 'Cant.';

  @override
  String posLineQuantityWithUnitLabel(String unit) {
    return 'Cant. ($unit)';
  }

  @override
  String get posLinePriceLabel => 'Precio';

  @override
  String get posLineDiscountLabel => 'Desc. %';

  @override
  String get posLineTaxLabel => 'Imp. %';

  @override
  String get posLineWarehouseLabel => 'Almacén';

  @override
  String get posLineNoStock => 'Sin existencia en este almacén';

  @override
  String posLineShortfall(String available) {
    return 'Solo hay $available disponibles';
  }

  @override
  String get posLineAdjustToAvailable => 'Ajustar a disponible';

  @override
  String get posLineWarehouseStockUnknown => 'Existencia sin verificar';

  @override
  String posLineWarehouseStockShort(String available) {
    return 'Solo quedan $available';
  }

  @override
  String get posLineWarehouseStockNone => 'Sin existencia';

  @override
  String posTotalsCounts(int lines, String units, num unitsValue) {
    String _temp0 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines líneas',
      one: '$lines línea',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unitsValue,
      locale: localeName,
      other: 'uds.',
      one: 'ud.',
    );
    return '$_temp0 · $units $_temp1';
  }

  @override
  String get posTotalsArticlesLabel => 'Artículos';

  @override
  String get posTotalsSubtotalLabel => 'Subtotal';

  @override
  String get posTotalsDiscountLabel => 'Descuentos';

  @override
  String get posTotalsTaxLabel => 'IVA';

  @override
  String get posTotalsTotalLabel => 'Total';

  @override
  String get posSaleReadOnlyBanner =>
      'La venta ya fue confirmada; los datos son de solo lectura.';

  @override
  String get posSalesSearchLabel => 'Buscar ventas';

  @override
  String get posSalesStatusFilterLabel => 'Estado';

  @override
  String get posSalesStatusFilterAll => 'Todos los estados';

  @override
  String get posSalesNewSaleAction => 'Nueva venta';

  @override
  String get posSalesColumnReference => 'Folio';

  @override
  String get posSalesColumnDate => 'Fecha';

  @override
  String get posSalesColumnCustomer => 'Cliente';

  @override
  String get posSalesColumnStatus => 'Estado';

  @override
  String get posSalesColumnTotal => 'Total';

  @override
  String get posSalesColumnBalance => 'Saldo';

  @override
  String get posSalesEmptyToday => 'Sin ventas en esta caja hoy';

  @override
  String get posSalesNoRegister => 'Esta cuenta no tiene una caja asignada.';

  @override
  String get posSalesNewSaleBlockedNoSession =>
      'Debes abrir una sesión de caja antes de iniciar una venta.';

  @override
  String get dateRangeFilterToday => 'Hoy';

  @override
  String dateRangeFilterRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get dateRangeFilterClear => 'Volver a hoy';

  @override
  String get posSaleStatusDraft => 'En captura';

  @override
  String get posSaleStatusCompleted => 'Por cobrar';

  @override
  String get posSaleStatusPaid => 'Pagada';

  @override
  String get posSaleStatusCancelled => 'Cancelada';

  @override
  String get posSaleUnreachableTitle => 'Esta venta no se puede abrir';

  @override
  String get posSaleUnreachableUnknown => 'No se encontró esta venta.';

  @override
  String get posSaleUnreachableCancelled =>
      'Esta venta fue cancelada y ya no se puede abrir.';

  @override
  String get posSaleUnreachableOtherRegister =>
      'Esta venta pertenece a otra caja.';

  @override
  String get posSaleBackToListAction => 'Volver a ventas';

  @override
  String get posNoLinesHint => 'Sin líneas — busca o escanea un producto';

  @override
  String get posAmountLabel => 'Monto';

  @override
  String get posQuickAmountRemaining => 'Restante';

  @override
  String get posQuickAmountHalf => 'Mitad';

  @override
  String get posPaymentTotal => 'Total';

  @override
  String get posPaymentPaid => 'Pagado';

  @override
  String get posPaymentBalance => 'Restante';

  @override
  String get posPaymentReferenceLabel => 'Referencia';

  @override
  String get posPaymentChangeLabel => 'Cambio';

  @override
  String get posPaymentGateHint => 'Se habilita cuando el saldo queda en cero';

  @override
  String get posPaymentMethodRequiresReference => 'Requiere referencia';

  @override
  String get posPaymentMethodNoReference => 'Sin referencia';

  @override
  String get posPaymentMethodSectionLabel => 'Método de pago';

  @override
  String get posApplyPayment => 'Aplicar pago';

  @override
  String get posContinue => 'Continuar';

  @override
  String get posAppliedPaymentsTitle => 'Pagos aplicados';

  @override
  String get posNoAppliedPayments => 'Sin pagos aplicados';

  @override
  String get posAppliedPaymentsLoadError =>
      'No se pudieron cargar los pagos aplicados';

  @override
  String posPaymentReferenceValue(String reference) {
    return 'Ref. $reference';
  }

  @override
  String get posPaymentPendingValidation => 'Pendiente de validación';

  @override
  String get posPaymentCancelled => 'Cancelado';

  @override
  String get posReverseAction => 'Revertir';

  @override
  String get posReversePaymentTitle => 'Revertir pago';

  @override
  String get posReversalReasonLabel => 'Motivo';

  @override
  String get posCustomerNameLabel => 'Cliente';

  @override
  String get posCustomerPriceListLabel => 'Lista de precios';

  @override
  String get posCustomerSearchAction => 'Buscar';

  @override
  String get posCustomerCreateAction => 'Nuevo';

  @override
  String get posCustomerSearchCancelAction => 'Cancelar búsqueda';

  @override
  String get posCustomerNoCreditHint => 'Sin línea de crédito';

  @override
  String get newContactDialogTitle => 'Nuevo contacto';

  @override
  String get contactNameLabel => 'Nombre';

  @override
  String get contactMobileLabel => 'Celular';

  @override
  String get contactPhoneLabel => 'Teléfono';

  @override
  String get contactJobTitleLabel => 'Puesto';

  @override
  String get contactEmailLabel => 'Correo';

  @override
  String get contactMethodRequired => 'Ingresa un celular o un teléfono.';

  @override
  String get posDeliveryAddressTitle => 'Dirección de entrega';

  @override
  String get posDeliveryContactTitle => 'Contacto';

  @override
  String get posNoAddressesOnFile =>
      'Este cliente no tiene direcciones registradas.';

  @override
  String get posNoContactsOnFile =>
      'Este cliente no tiene contactos registrados.';

  @override
  String get posNewAddressAction => 'Nueva dirección';

  @override
  String get posNewContactAction => 'Nuevo contacto';

  @override
  String get posDeliveryNotPermitted =>
      'Este cliente no está autorizado para recibir entregas.';

  @override
  String get posGenericCustomerResetToPickup =>
      'Este cliente no puede recibir entregas — la venta se cambió a recolección en mostrador.';

  @override
  String get posCounterPickupRemainder => 'Se recoge en tienda';

  @override
  String get posDeliveryAddressPending => 'Dirección pendiente';

  @override
  String posDestinationCounts(int lines, String units) {
    return '$lines líneas · $units uds.';
  }

  @override
  String get posRemoveDestination => 'Eliminar destino';

  @override
  String get posRemoveDestinationReason =>
      'Eliminado por el cajero durante la captura';

  @override
  String get posDistributionTitle => 'Distribución';

  @override
  String posDistributionOrdered(String quantity) {
    return 'Pedido: $quantity';
  }

  @override
  String posDistributionAssigned(String quantity) {
    return 'Asignado: $quantity';
  }

  @override
  String posDistributionAtCounter(String quantity) {
    return 'En tienda: $quantity';
  }

  @override
  String posDistributionClaimable(String quantity) {
    return 'Disponible: $quantity';
  }

  @override
  String get posDistributionOverClaimed => 'Más de lo disponible';

  @override
  String get posDistributionClaimAll => 'Tomar todo lo disponible';

  @override
  String posDestinationBadge(int ordinal) {
    return 'D$ordinal';
  }

  @override
  String get posDeliveryDestinationsTitle => 'Destinos de entrega';

  @override
  String posDistributionRailSubtitle(int lines, int destinations) {
    return '$lines líneas · $destinations destinos';
  }

  @override
  String posDeliveryAssignedUnits(String assigned, String total) {
    return '$assigned / $total unidades asignadas';
  }

  @override
  String get posDestinationLinesTitle => 'Cantidad a entregar en este destino';

  @override
  String get posAddDestinationSheetTitle => 'Datos de entrega';

  @override
  String get posEditDestinationSheetTitle => 'Editar destino';

  @override
  String get posUnconfirmedChangesTitle => 'Cambios sin confirmar';

  @override
  String get posUnconfirmedChangesBody =>
      'Hay valores escritos que no se han confirmado. ¿Qué deseas hacer?';

  @override
  String get posUnconfirmedChangesKeep => 'Conservar';

  @override
  String get posUnconfirmedChangesDiscard => 'Descartar';

  @override
  String get posUnconfirmedChangesKeepEditing => 'Seguir editando';

  @override
  String get posCounterPickupLinesTitle => 'Cantidad que se queda en tienda';

  @override
  String posDestinationCounterChip(String units) {
    return 'Tienda $units';
  }

  @override
  String posDeliveryAssignmentRefused(String reason) {
    return 'No se pudo asignar: $reason';
  }

  @override
  String get posAddDestinationNothingLeft => 'No queda nada por asignar';

  @override
  String get posDeliverRestAtCounter => 'Entregar el resto en tienda';

  @override
  String get posDeliveryDateLabel => 'Fecha de entrega';

  @override
  String get posDeliveryInstructions => 'Instrucciones de entrega';

  @override
  String get posAddDestination => 'Agregar destino';

  @override
  String get posNoDestinationsYet => 'Sin destinos — agrega el primero.';

  @override
  String posDeliveryOutstanding(String lines) {
    return 'Falta asignar: $lines';
  }

  @override
  String get posFinishSale => 'Finalizar venta';

  @override
  String get posCustomerBalanceLabel => 'Saldo';

  @override
  String get posNoOpenSales => 'Sin otras ventas abiertas';

  @override
  String posOpenSalesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abiertas',
      one: '1 abierta',
    );
    return '$_temp0';
  }

  @override
  String get posOpenSaleDraft => 'En captura';

  @override
  String get posOpenSaleUndelivered => 'Por entregar';

  @override
  String get posCreateCustomerAction => 'Crear cliente';

  @override
  String posStepProgress(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get posLineDecreaseQuantity => 'Disminuir cantidad';

  @override
  String get posLineIncreaseQuantity => 'Aumentar cantidad';

  @override
  String get numberPadBackspace => 'Borrar';

  @override
  String get dismissErrorTooltip => 'Descartar';

  @override
  String posOpenSaleId(int id) {
    return 'Id $id';
  }

  @override
  String posOpenSaleSerial(int serial) {
    return 'Folio $serial';
  }

  @override
  String get taxpayerRecipientFieldLabel => 'Receptor fiscal (RFC)';

  @override
  String get userProfilesMenuTitle => 'Perfiles de usuario';

  @override
  String get newUserProfileTooltip => 'Nuevo perfil';

  @override
  String get userProfilesSearchLabel => 'Buscar por nombre';

  @override
  String get noUserProfilesYetMessage =>
      'Aún no hay perfiles de usuario — crea el primero.';

  @override
  String get columnProfileName => 'Nombre';

  @override
  String get columnProfile => 'Perfil';

  @override
  String get columnProfileDescription => 'Descripción';

  @override
  String get newUserProfileTitle => 'Nuevo perfil';

  @override
  String get editUserProfileTitle => 'Editar perfil';

  @override
  String get viewUserProfileTitle => 'Ver perfil';

  @override
  String get userProfileNameFieldLabel => 'Nombre';

  @override
  String get userProfileDescriptionFieldLabel => 'Descripción';

  @override
  String get userProfileNameRequiredError => 'El nombre es obligatorio.';

  @override
  String get userProfileLoadFailedError => 'No se pudo cargar el perfil.';

  @override
  String get userProfileSaveFailedError => 'No se pudo guardar el perfil.';

  @override
  String get userProfileDeleteFailedError => 'No se pudo eliminar el perfil.';

  @override
  String get deleteUserProfileTooltip => 'Eliminar perfil';

  @override
  String get deleteUserProfileConfirmTitle => '¿Eliminar perfil?';

  @override
  String deleteUserProfileConfirmMessage(String name) {
    return '¿Seguro que deseas eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get userProfilePickerLabel => 'Perfil';

  @override
  String get applyProfileButtonLabel => 'Aplicar perfil';

  @override
  String get applyProfileDialogTitle => 'Aplicar perfil';

  @override
  String get applyProfileReplaceWarning =>
      'Esto reemplaza todos los permisos que esta cuenta tiene actualmente.';

  @override
  String get applyProfileSessionWarning =>
      'Las sesiones activas de la cuenta terminarán y deberá iniciar sesión de nuevo.';

  @override
  String get applyProfileSelfWarning =>
      'Esta es tu propia cuenta — tu propia sesión también terminará.';

  @override
  String get applyProfileConfirmLabel => 'Aplicar';

  @override
  String get applyProfileSuccessMessage => 'Perfil aplicado.';

  @override
  String get userFormApplyFailedError => 'No se pudo aplicar el perfil.';

  @override
  String userProvisionedFromLabel(String profileName) {
    return 'Aprovisionado desde $profileName';
  }

  @override
  String get recordSheetDiscardTitle => '¿Descartar cambios sin guardar?';

  @override
  String get recordSheetDiscardBody =>
      'Los cambios en este registro no se han guardado.';

  @override
  String get recordSheetDiscardConfirm => 'Descartar';

  @override
  String get recordSheetDiscardCancel => 'Seguir editando';

  @override
  String get documentPrintAction => 'Imprimir';

  @override
  String get documentDownloadAction => 'Descargar';

  @override
  String get documentLoadingMessage => 'Cargando documento…';

  @override
  String get documentLoadFailedError => 'No se pudo cargar el documento.';

  @override
  String get documentCloseTooltip => 'Cerrar';

  @override
  String get documentZoomOutTooltip => 'Alejar';

  @override
  String get documentZoomInTooltip => 'Acercar';

  @override
  String get documentZoomFitTooltip => 'Ajustar al ancho';

  @override
  String documentPageIndicator(String current, String total) {
    return 'Página $current / $total';
  }

  @override
  String documentTicketTitle(String reference) {
    return 'Ticket · Folio #$reference';
  }

  @override
  String documentSalesOrderTitle(String reference) {
    return 'Pedido · $reference';
  }

  @override
  String documentCashCutTitle(String reference) {
    return 'Corte de caja · $reference';
  }

  @override
  String documentSalesQuoteTitle(String reference) {
    return 'Cotización · $reference';
  }

  @override
  String get posSalePrintTicketAction => 'Imprimir ticket';

  @override
  String get posSalePrintTicketError => 'No se pudo imprimir el ticket.';

  @override
  String get cashSessionViewCutAction => 'Ver corte';

  @override
  String get posSaleViewTicketTooltip => 'Ver ticket';

  @override
  String get salesOrderViewDocumentAction => 'Ver pedido';

  @override
  String get salesQuoteViewDocumentAction => 'Ver cotización';

  @override
  String get salesQuoteEmailAction => 'Enviar por correo';

  @override
  String get salesQuoteMoreActionsTooltip => 'Más acciones';

  @override
  String salesQuoteEmailDialogTitle(String reference) {
    return 'Enviar cotización $reference';
  }

  @override
  String get salesQuoteEmailRecipientsLabel => 'Destinatarios';

  @override
  String get salesQuoteEmailOtherAddressLabel => 'Otro correo';

  @override
  String get salesQuoteEmailAddAction => 'Agregar';

  @override
  String get salesQuoteEmailSendAction => 'Enviar';

  @override
  String get salesQuoteEmailSendingLabel => 'Enviando…';

  @override
  String get salesQuoteEmailLimitHint => 'Hasta 10 destinatarios.';

  @override
  String salesQuoteEmailCounter(int count) {
    return '$count de 10 destinatarios.';
  }

  @override
  String get salesQuoteEmailLimitReached =>
      '10 de 10 destinatarios. No se pueden agregar más.';

  @override
  String get salesQuoteEmailInvalidAddress => 'No es un correo válido.';

  @override
  String get salesQuoteEmailNoKnownAddresses =>
      'Este cliente no tiene correos registrados.';

  @override
  String get salesQuoteEmailSuggestionsLoading =>
      'Cargando correos del cliente…';

  @override
  String get salesQuoteEmailSuggestionsFailed =>
      'No se pudieron cargar los correos del cliente.';

  @override
  String get salesQuoteEmailNotSendable =>
      'La cotización ya no se puede enviar.';

  @override
  String get salesQuoteEmailMailRefused =>
      'El servidor de correo rechazó el envío. Intenta de nuevo o descarga la cotización.';

  @override
  String get salesQuoteEmailMailUnavailable =>
      'El envío de correo no está disponible. Descarga la cotización para enviarla.';

  @override
  String salesQuoteEmailSentMessage(String recipients) {
    return 'Cotización enviada a $recipients';
  }

  @override
  String get customerAddressesSection => 'Direcciones';

  @override
  String get customerContactsSection => 'Contactos';

  @override
  String get customerTaxpayersSection => 'Receptores fiscales';

  @override
  String get customerAddressesEmpty => 'Sin direcciones vinculadas.';

  @override
  String get customerContactsEmpty => 'Sin contactos vinculados.';

  @override
  String get customerTaxpayersEmpty => 'Sin receptores fiscales vinculados.';

  @override
  String get customerAddressLinkLabel => 'Vincular una dirección existente';

  @override
  String get customerContactLinkLabel => 'Vincular un contacto existente';

  @override
  String get customerTaxpayerLinkLabel =>
      'Vincular un receptor fiscal existente';

  @override
  String get linkedRecordUnlinkTooltip => 'Desvincular';

  @override
  String get linkedRecordNewAction => 'Nuevo';

  @override
  String customerGenericTaxpayerNote(String rfc) {
    return 'Este es el cliente de mostrador: su único receptor fiscal es $rfc (público en general) y no se le puede vincular nada más.';
  }

  @override
  String get posSessionExpiredRedirect =>
      'Tu sesión de caja está vencida. Ciérrala para continuar vendiendo.';

  @override
  String get posSessionExpiredPaymentsBlocked =>
      'La sesión de caja está vencida. Ciérrala para cobrar.';

  @override
  String get posSessionCloseAction => 'Cerrar sesión';

  @override
  String posCaptureShortLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas sin existencia suficiente',
      one: '1 partida sin existencia suficiente',
    );
    return '$_temp0';
  }

  @override
  String get posWarehousePickerTitle => 'Almacén';

  @override
  String get posWarehousePickerNotTracked =>
      'Este producto no controla existencia, así que cualquier almacén es válido.';

  @override
  String get posPaymentAmountRequired => 'Captura un monto mayor a cero.';

  @override
  String get posPaymentOverpayNonCash =>
      'Solo el efectivo puede exceder el saldo.';

  @override
  String get posPaymentSessionInvalid =>
      'La sesión de caja ya no es válida. Ciérrala y abre una nueva para cobrar.';

  @override
  String get posPaymentChangeDue => 'Cambio a entregar';

  @override
  String get posPaymentDismissChange => 'Entendido';

  @override
  String get posPaymentReferenceTitle => 'Referencia del pago';

  @override
  String get posPaymentReferenceConfirm => 'Aplicar pago';

  @override
  String posCaptureUnknownStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas con existencia sin verificar',
      one: '1 partida con existencia sin verificar',
    );
    return '$_temp0';
  }

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get confirmNewPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get passwordMismatchError => 'Las contraseñas no coinciden';

  @override
  String get posSaleDetailTitle => 'Ver venta';

  @override
  String get posSaleDetailDateLabel => 'Fecha';

  @override
  String get posSaleDetailRegisterLabel => 'Caja';

  @override
  String get posSaleDetailPaymentsForbidden =>
      'No tienes permiso para ver los pagos de esta venta.';

  @override
  String get posPaymentDateLabel => 'Fecha de pago';

  @override
  String get posWarehousePickerOtherFacilities => 'Otras sucursales';

  @override
  String get posWarehousePickerOtherNone =>
      'No hay existencia en otras sucursales.';

  @override
  String passwordRuleMinLength(int count) {
    return 'Al menos $count caracteres';
  }

  @override
  String get passwordRuleUpper => 'Una letra mayúscula';

  @override
  String get passwordRuleLower => 'Una letra minúscula';

  @override
  String get passwordRuleDigit => 'Un número';

  @override
  String get passwordRuleSymbol => 'Un símbolo';

  @override
  String get passwordRulesUnavailable =>
      'No se pudieron cargar las reglas de contraseña. El servidor validará tu contraseña.';

  @override
  String get passwordRequiredTitle => 'Cambia tu contraseña';

  @override
  String get passwordRequiredExplanation =>
      'Un administrador definió tu contraseña. Elige una nueva para continuar.';

  @override
  String get supplierAddressesSection => 'Direcciones';

  @override
  String get supplierAddressesEmpty => 'Este proveedor no tiene direcciones.';

  @override
  String get supplierContactsSection => 'Contactos';

  @override
  String get supplierContactsEmpty => 'Este proveedor no tiene contactos.';

  @override
  String get supplierBankAccountsSection => 'Cuentas bancarias';

  @override
  String get supplierBankAccountsEmpty =>
      'Este proveedor no tiene cuentas bancarias.';

  @override
  String get supplierAgreementsSection => 'Convenios';

  @override
  String get supplierAgreementsEmpty => 'Este proveedor no tiene convenios.';

  @override
  String get supplierAgreementsAfterSaveNote =>
      'Podrás agregar convenios después de guardar el proveedor.';

  @override
  String get supplierAgreementColumnStart => 'Inicio';

  @override
  String get supplierAgreementColumnEnd => 'Fin';

  @override
  String get supplierAgreementColumnNotes => 'Notas';

  @override
  String get supplierAddressLinkLabel => 'Vincular dirección existente';

  @override
  String get supplierContactLinkLabel => 'Vincular contacto existente';

  @override
  String get supplierBankAccountLinkLabel =>
      'Vincular cuenta bancaria existente';

  @override
  String get newBankAccountDialogTitle => 'Nueva cuenta bancaria';

  @override
  String get bankAccountBankNameLabel => 'Banco';

  @override
  String get bankAccountNumberLabel => 'Número de cuenta';

  @override
  String get bankAccountReferenceLabel => 'Referencia';

  @override
  String get bankAccountRoutingLabel => 'CLABE / ruteo';

  @override
  String bankAccountFieldTooLongError(int max) {
    return 'Debe tener como máximo $max caracteres.';
  }

  @override
  String get bankAccountCreateFailedError =>
      'No se pudo crear la cuenta bancaria.';

  @override
  String get addAgreementButton => 'Agregar convenio';

  @override
  String get newAgreementDialogTitle => 'Nuevo convenio';

  @override
  String get editAgreementDialogTitle => 'Editar convenio';

  @override
  String get supplierAgreementEndBeforeStartError =>
      'La fecha de fin no puede ser anterior a la de inicio.';

  @override
  String agreementCommentTooLongError(int max) {
    return 'Las notas deben tener como máximo $max caracteres.';
  }

  @override
  String get deleteAgreementButton => 'Eliminar';

  @override
  String get deleteAgreementConfirmTitle => '¿Eliminar convenio?';

  @override
  String deleteAgreementConfirmMessage(String start, String end) {
    return 'Se eliminará el convenio del $start al $end. Esta acción no se puede deshacer.';
  }

  @override
  String get agreementSaveFailedError => 'No se pudo guardar el convenio.';

  @override
  String get agreementDeleteFailedError => 'No se pudo eliminar el convenio.';

  @override
  String get customerDiscountsSection => 'Descuentos';

  @override
  String get customerDiscountsEmpty => 'Sin descuentos por producto.';

  @override
  String get customerDiscountsAfterSaveNote =>
      'Los descuentos se pueden agregar después de guardar el cliente.';

  @override
  String get customerDiscountColumnCode => 'Código';

  @override
  String get customerDiscountColumnProduct => 'Producto';

  @override
  String get customerDiscountColumnDiscount => 'Descuento';

  @override
  String get newCustomerDiscountDialogTitle => 'Nuevo descuento';

  @override
  String get customerDiscountProductLabel => 'Producto';

  @override
  String get customerDiscountPercentLabel => 'Descuento (%)';

  @override
  String get customerDiscountPercentRequiredError => 'Ingresa un porcentaje.';

  @override
  String get customerDiscountPercentInvalidError =>
      'Ingresa un número, p. ej. 12.5.';

  @override
  String get customerDiscountPercentOutOfRangeError =>
      'Debe estar entre 0 y 100.';

  @override
  String get customerDiscountPercentTooPreciseError => 'Máximo 6 decimales.';

  @override
  String get customerDiscountDuplicateError =>
      'Este cliente ya tiene un descuento para ese producto.';

  @override
  String get customerDiscountProductMissingError => 'El producto ya no existe.';

  @override
  String get customerDiscountSaveFailedError =>
      'No se pudo guardar el descuento.';

  @override
  String get editCustomerDiscountDialogTitle => 'Editar descuento';

  @override
  String get customerDiscountMissingError => 'Este descuento ya no existe.';

  @override
  String get customerDiscountDeleteFailedError =>
      'No se pudo eliminar el descuento.';

  @override
  String get deleteCustomerDiscountButton => 'Eliminar';

  @override
  String get deleteCustomerDiscountConfirmTitle => 'Eliminar descuento';

  @override
  String deleteCustomerDiscountConfirmMessage(String code, String name) {
    return '¿Eliminar el descuento sobre $code — $name? Las partidas ya capturadas conservan su descuento.';
  }

  @override
  String get customerDiscountChangeProductTooltip => 'Cambiar producto';

  @override
  String get paymentsMenuTitle => 'Pagos';

  @override
  String get paymentTypeNa => 'N/A';

  @override
  String get paymentTypeImmediate => 'Contado';

  @override
  String get paymentTypeCreditPayment => 'Pago de crédito';

  @override
  String get paymentTypePaymentInAdvance => 'Pago anticipado';

  @override
  String get paymentTypeCreditNote => 'Nota de crédito';

  @override
  String get paymentTypeExpense => 'Gasto';

  @override
  String get paymentVerified => 'Verificado';

  @override
  String get paymentUnverified => 'Sin verificar';

  @override
  String get paymentApplicationReversed => 'Revertida';

  @override
  String get paymentsColumnFolio => 'Folio';

  @override
  String get paymentsColumnDate => 'Fecha';

  @override
  String get paymentsColumnCustomer => 'Cliente';

  @override
  String get paymentsColumnAmount => 'Importe';

  @override
  String get paymentsColumnMethod => 'Forma de pago';

  @override
  String get paymentsColumnReference => 'Referencia';

  @override
  String get paymentsColumnType => 'Tipo';

  @override
  String get paymentsColumnUnapplied => 'Sin aplicar';

  @override
  String get paymentsColumnVerified => 'Verificado';

  @override
  String get paymentsFilterCustomer => 'Cliente';

  @override
  String get paymentsFilterDate => 'Fecha';

  @override
  String get paymentsFilterMethod => 'Forma de pago';

  @override
  String get paymentsFilterMethodAll => 'Todas';

  @override
  String get paymentsFilterVerified => 'Verificación';

  @override
  String get paymentsVerifiedAny => 'Todos';

  @override
  String get paymentsVerifiedYes => 'Verificados';

  @override
  String get paymentsVerifiedNo => 'Sin verificar';

  @override
  String get paymentsFilterCashSession => 'Sesión de caja';

  @override
  String get paymentsListEmpty => 'Todavía no hay pagos.';

  @override
  String get dateRangeFilterAny => 'Cualquier fecha';

  @override
  String get paymentViewTitle => 'Ver pago';

  @override
  String paymentHeaderTitle(int id) {
    return 'Pago $id';
  }

  @override
  String get paymentSummaryAmount => 'Importe';

  @override
  String get paymentSummaryApplied => 'Aplicado';

  @override
  String get paymentSummaryUnapplied => 'Sin aplicar';

  @override
  String get paymentFieldPaymentOption => 'Opción de pago';

  @override
  String get paymentFieldFacility => 'Sucursal';

  @override
  String get paymentFieldCashSession => 'Sesión de caja';

  @override
  String get paymentFieldVerifier => 'Verificado por';

  @override
  String get paymentFieldLastRejection => 'Último rechazo';

  @override
  String get paymentRejected => 'Rechazado';

  @override
  String get paymentVerificationFilterRejected => 'Rechazos';

  @override
  String get paymentVerificationRejectedAny => 'Todos';

  @override
  String get paymentVerificationRejectedYes => 'Rechazados';

  @override
  String get paymentVerificationRejectedNo => 'Nunca rechazados';

  @override
  String get paymentApplicationsTitle => 'Aplicaciones';

  @override
  String get paymentApplicationsEmpty =>
      'Este pago no se ha aplicado a ningún pedido.';

  @override
  String get paymentApplicationsColumnOrder => 'Pedido';

  @override
  String get paymentApplicationsColumnApplied => 'Aplicado';

  @override
  String get paymentApplicationsColumnChange => 'Cambio';

  @override
  String get paymentApplicationsColumnApplier => 'Aplicó';

  @override
  String get paymentApplicationsColumnDate => 'Fecha';

  @override
  String get paymentApplicationsColumnStatus => 'Estado';

  @override
  String paymentNotFound(int id) {
    return 'El pago $id no existe.';
  }

  @override
  String get paymentBackToList => 'Volver a Pagos';

  @override
  String get paymentsScopeFacility => 'Esta sucursal';

  @override
  String get paymentsScopeAll => 'Todas las sucursales';

  @override
  String get paymentsSearchReferenceHint => 'Buscar referencia…';

  @override
  String get paymentsColumnFacility => 'Sucursal';

  @override
  String get paymentsSearchCustomerHint => 'Buscar cliente…';

  @override
  String get paymentsListForbidden => 'No tienes permiso para ver estos pagos.';

  @override
  String get paymentViewTicketTooltip => 'Ver ticket';

  @override
  String get paymentViewTicketAction => 'Ver ticket';

  @override
  String documentPaymentTicketTitle(int id) {
    return 'Ticket de pago · #$id';
  }

  @override
  String documentRefundReceiptTitle(int id) {
    return 'Comprobante de devolución · #$id';
  }

  @override
  String get creditNotesMenuTitle => 'Notas de crédito';

  @override
  String get creditNotesColumnDate => 'Fecha';

  @override
  String get creditNotesColumnCustomer => 'Cliente';

  @override
  String get creditNotesColumnOrigin => 'Origen';

  @override
  String get creditNotesColumnIssued => 'Emitido';

  @override
  String get creditNotesColumnRemaining => 'Saldo';

  @override
  String creditNotesOrigin(int refund, int order) {
    return 'Devolución #$refund · Pedido #$order';
  }

  @override
  String get creditNotesOpenOnlyFilter => 'Solo utilizables';

  @override
  String get creditNotesCustomerFilter => 'Cliente';

  @override
  String get creditNotesEmpty => 'No hay notas de crédito.';

  @override
  String get creditNotesForbidden => 'No tienes acceso a las notas de crédito.';

  @override
  String get paymentCreditNoteTile => 'Nota de crédito';

  @override
  String paymentCreditNoteBalance(String amount) {
    return 'Saldo $amount';
  }

  @override
  String get paymentCreditNoteRedeemTile => 'Canjear nota de crédito';

  @override
  String get paymentCreditNoteRedeemHint => 'Escanea el ticket';

  @override
  String paymentCreditPartlyApplied(String amount) {
    return 'Se aplicaron $amount de crédito; el resto no se pudo aplicar.';
  }

  @override
  String appliedPaymentCreditNoteNumber(int number) {
    return 'Nº $number';
  }

  @override
  String get creditNoteTicketTitle => 'Canjear nota de crédito';

  @override
  String get creditNoteTicketInput => 'Número de ticket';

  @override
  String get creditNoteTicketHelp =>
      'Escanea el código de barras del ticket o escríbelo.';

  @override
  String get creditNoteTicketSearching => 'Buscando…';

  @override
  String get creditNoteTicketConfirm => 'Aplicar';

  @override
  String creditNoteTicketHeading(int number, String date) {
    return 'Nota de crédito Nº $number · $date';
  }

  @override
  String creditNoteTicketAvailable(String amount) {
    return 'Saldo disponible $amount';
  }

  @override
  String creditNoteTicketWillApply(String amount) {
    return 'Se aplicará $amount';
  }

  @override
  String get creditNoteNotFound =>
      'No hay una nota de crédito con ese número en esta sucursal.';

  @override
  String get creditNoteUsedUp => 'Esta nota de crédito ya se usó por completo.';

  @override
  String get creditNoteAlreadyOnSale =>
      'Esta nota de crédito ya está aplicada a esta venta.';

  @override
  String creditNoteOtherCustomer(String name) {
    return 'Esta nota de crédito es de $name. Haz la venta a su nombre para usarla.';
  }

  @override
  String get refundsMenuTitle => 'Devoluciones';

  @override
  String get refundsColumnNumber => 'Folio';

  @override
  String get refundsColumnDate => 'Fecha';

  @override
  String get refundsColumnCustomer => 'Cliente';

  @override
  String get refundsColumnOrder => 'Pedido';

  @override
  String get refundsColumnStatus => 'Estado';

  @override
  String get refundsColumnTotal => 'Total';

  @override
  String get refundsFilterStatus => 'Estado';

  @override
  String get refundsFilterOrder => 'Pedido';

  @override
  String get refundsSearchHint => 'Folio, pedido o cliente…';

  @override
  String get refundsFilterMine => 'Solo mis devoluciones';

  @override
  String get refundsFilterAll => 'Todas';

  @override
  String get refundsFilterOpen => 'Abiertas';

  @override
  String get refundsFilterConfirmed => 'Confirmadas';

  @override
  String get refundsFilterCancelled => 'Canceladas';

  @override
  String get refundStatusDraft => 'Abierta';

  @override
  String get refundStatusCompleted => 'Confirmada';

  @override
  String get refundStatusCancelled => 'Cancelada';

  @override
  String get refundsNew => 'Nueva devolución';

  @override
  String get refundsNewShort => 'Nueva';

  @override
  String get refundsEmpty => 'No hay devoluciones.';

  @override
  String get refundsForbidden => 'No tienes permiso para ver devoluciones.';

  @override
  String get refundsLoadError => 'No se pudieron cargar las devoluciones.';

  @override
  String get refundNewOrderLabel => 'Número de pedido';

  @override
  String get refundNewContinue => 'Continuar';

  @override
  String refundRefusalOrderNotFound(int n) {
    return 'No existe el pedido $n.';
  }

  @override
  String refundRefusalNotCompleted(int n) {
    return 'El pedido $n no está confirmado.';
  }

  @override
  String refundRefusalNotPaid(int n) {
    return 'El pedido $n no está pagado. Cancélalo en lugar de hacer una devolución.';
  }

  @override
  String refundRefusalNothingToReturn(int n) {
    return 'El pedido $n no tiene nada por devolver.';
  }

  @override
  String get refundAction => 'Devolver';

  @override
  String get refundDetailTitle => 'Devolución';

  @override
  String refundDetailTitleWithNumber(int n) {
    return 'Devolución $n';
  }

  @override
  String get refundFieldNumber => 'Folio';

  @override
  String get refundFieldDate => 'Fecha';

  @override
  String get refundFieldCustomer => 'Cliente';

  @override
  String get refundFieldOrder => 'Pedido';

  @override
  String get refundFieldStatus => 'Estado';

  @override
  String get refundDraftNumber => 'Borrador';

  @override
  String get refundNoValue => '—';

  @override
  String get refundColumnProduct => 'Producto';

  @override
  String get refundColumnPrice => 'Precio';

  @override
  String get refundColumnDiscount => 'Desc.';

  @override
  String get refundColumnTax => 'IVA';

  @override
  String get refundColumnRefundable => 'Por devolver';

  @override
  String get refundColumnRefundableShort => 'Por dev.';

  @override
  String get refundColumnReturn => 'Devolver';

  @override
  String get refundColumnReturned => 'Devuelto';

  @override
  String get refundColumnWarehouse => 'Almacén';

  @override
  String get refundColumnTotal => 'Total';

  @override
  String get refundSubtotal => 'Subtotal';

  @override
  String get refundTax => 'IVA';

  @override
  String get refundTotal => 'Total';

  @override
  String refundNotFound(int id) {
    return 'No existe la devolución $id.';
  }

  @override
  String get refundConfirmAction => 'Confirmar devolución';

  @override
  String get refundCancelAction => 'Cancelar devolución';

  @override
  String get refundCancelPrompt =>
      'La devolución se cancelará y no podrá editarse.';

  @override
  String refundConfirmDialogTotal(String total) {
    return 'Se devolverán $total al cliente.';
  }

  @override
  String get refundPayoutCash => 'Efectivo de la caja';

  @override
  String get refundPayoutCreditNote => 'Nota de crédito';

  @override
  String get refundConfirmBack => 'Volver';

  @override
  String get refundConfirmSubmit => 'Confirmar';

  @override
  String get refundSessionBanner =>
      'Abre una sesión de caja para confirmar la devolución.';

  @override
  String get refundSessionOpenAction => 'Ir a sesiones de caja';

  @override
  String get refundSessionStaleAction => 'Cerrar sesión anterior';

  @override
  String get refundPayoutLineLabel => 'Forma de devolución';

  @override
  String get refundPayoutLineCash => 'Pagada en efectivo';

  @override
  String refundPayoutLineCreditNote(int n) {
    return 'Nota de crédito Nº $n';
  }

  @override
  String get refundPayoutLineUnknown => 'Forma de pago no disponible';

  @override
  String get refundAdjustedBanner =>
      'Algunas cantidades se ajustaron porque otra devolución se confirmó antes.';

  @override
  String get refundNeedsConfirmerHint =>
      'Otra persona con permiso de confirmar debe terminar esta devolución.';

  @override
  String apiResourceCashDrawer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cajas',
      one: 'caja',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCashDrawer => 'feminine';

  @override
  String apiResourceCashSession(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sesiones de caja',
      one: 'sesión de caja',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCashSession => 'feminine';

  @override
  String apiResourceCreditNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'notas de crédito',
      one: 'nota de crédito',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCreditNote => 'feminine';

  @override
  String apiResourceCustomer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'clientes',
      one: 'cliente',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomer => 'masculine';

  @override
  String apiResourceCustomerDiscount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'descuentos de cliente',
      one: 'descuento de cliente',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerDiscount => 'masculine';

  @override
  String apiResourceCustomerPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pagos',
      one: 'pago',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerPayment => 'masculine';

  @override
  String apiResourceCustomerRefund(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'devoluciones',
      one: 'devolución',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerRefund => 'feminine';

  @override
  String apiResourceDeliveryItinerary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rutas de entrega',
      one: 'ruta de entrega',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderDeliveryItinerary => 'feminine';

  @override
  String apiResourceDeliveryOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'órdenes de entrega',
      one: 'orden de entrega',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderDeliveryOrder => 'feminine';

  @override
  String apiResourceDeliveryOrderLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partidas de entrega',
      one: 'partida de entrega',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderDeliveryOrderLine => 'feminine';

  @override
  String apiResourceEmployee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'empleados',
      one: 'empleado',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderEmployee => 'masculine';

  @override
  String apiResourceExchangeRate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tipos de cambio',
      one: 'tipo de cambio',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderExchangeRate => 'masculine';

  @override
  String apiResourceExpense(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'gastos',
      one: 'gasto',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderExpense => 'masculine';

  @override
  String apiResourceExpenseVoucher(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vales de gasto',
      one: 'vale de gasto',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderExpenseVoucher => 'masculine';

  @override
  String apiResourceFacility(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sucursales',
      one: 'sucursal',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderFacility => 'feminine';

  @override
  String apiResourceFiscalDocument(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'facturas',
      one: 'factura',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderFiscalDocument => 'feminine';

  @override
  String apiResourceInventoryIssue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'salidas de almacén',
      one: 'salida de almacén',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderInventoryIssue => 'feminine';

  @override
  String apiResourceInventoryReceipt(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entradas de almacén',
      one: 'entrada de almacén',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderInventoryReceipt => 'feminine';

  @override
  String apiResourceInventoryTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'traspasos',
      one: 'traspaso',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderInventoryTransfer => 'masculine';

  @override
  String apiResourceLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'etiquetas',
      one: 'etiqueta',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderLabel => 'feminine';

  @override
  String apiResourcePaymentMethodOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'formas de pago',
      one: 'forma de pago',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderPaymentMethodOption => 'feminine';

  @override
  String apiResourcePointOfSale(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'puntos de venta',
      one: 'punto de venta',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderPointOfSale => 'masculine';

  @override
  String apiResourcePriceList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'listas de precios',
      one: 'lista de precios',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderPriceList => 'feminine';

  @override
  String apiResourceProduct(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'productos',
      one: 'producto',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderProduct => 'masculine';

  @override
  String apiResourceProductPrice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'precios',
      one: 'precio',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderProductPrice => 'masculine';

  @override
  String apiResourcePurchaseOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'órdenes de compra',
      one: 'orden de compra',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderPurchaseOrder => 'feminine';

  @override
  String apiResourceSalesOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pedidos',
      one: 'pedido',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSalesOrder => 'masculine';

  @override
  String apiResourceSalesOrderLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partidas del pedido',
      one: 'partida del pedido',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSalesOrderLine => 'feminine';

  @override
  String apiResourceSalesOrderPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pagos de pedido',
      one: 'pago de pedido',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSalesOrderPayment => 'masculine';

  @override
  String apiResourceSalesQuote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cotizaciones',
      one: 'cotización',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSalesQuote => 'feminine';

  @override
  String apiResourceSalesQuoteLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partidas de la cotización',
      one: 'partida de la cotización',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSalesQuoteLine => 'feminine';

  @override
  String apiResourceStockMovement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'movimientos de inventario',
      one: 'movimiento de inventario',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderStockMovement => 'masculine';

  @override
  String apiResourceSupplier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'proveedores',
      one: 'proveedor',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplier => 'masculine';

  @override
  String apiResourceSupplierPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pagos a proveedor',
      one: 'pago a proveedor',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplierPayment => 'masculine';

  @override
  String apiResourceTaxpayerCertificate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'certificados',
      one: 'certificado',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderTaxpayerCertificate => 'masculine';

  @override
  String apiResourceTaxpayerIssuer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'emisores',
      one: 'emisor',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderTaxpayerIssuer => 'masculine';

  @override
  String apiResourceTaxpayerRecipient(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receptores',
      one: 'receptor',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderTaxpayerRecipient => 'masculine';

  @override
  String apiResourceUser(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'usuarios',
      one: 'usuario',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderUser => 'masculine';

  @override
  String apiResourceUserProfile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'perfiles',
      one: 'perfil',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderUserProfile => 'masculine';

  @override
  String apiResourceVehicle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vehículos',
      one: 'vehículo',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderVehicle => 'masculine';

  @override
  String apiResourceVehicleOperator(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'operadores de vehículo',
      one: 'operador de vehículo',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderVehicleOperator => 'masculine';

  @override
  String apiResourceWarehouse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'almacenes',
      one: 'almacén',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderWarehouse => 'masculine';

  @override
  String apiResourceGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'registros',
      one: 'registro',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderGeneric => 'masculine';

  @override
  String get apiErrorAuthAdministratorRequired =>
      'Solo un administrador puede hacer esto.';

  @override
  String get apiErrorAuthForbidden => 'No tienes permiso para esta acción.';

  @override
  String get apiErrorAuthIncorrectCurrentPassword =>
      'La contraseña actual es incorrecta.';

  @override
  String get apiErrorAuthInvalidCredentials =>
      'Usuario o contraseña incorrectos.';

  @override
  String get apiErrorAuthNotAuthenticated =>
      'Tu sesión expiró. Vuelve a iniciar sesión.';

  @override
  String get apiErrorAuthPasswordChangeRequired =>
      'Debes cambiar tu contraseña antes de continuar.';

  @override
  String get apiErrorAuthRecoveryTokenInvalid =>
      'Este enlace de recuperación no es válido o ya expiró. Solicita uno nuevo.';

  @override
  String get apiErrorRequestMalformed =>
      'La app envió una solicitud que el servidor no pudo leer. Inténtalo de nuevo.';

  @override
  String get apiErrorRequestMethodNotAllowed =>
      'El servidor no permite esta operación aquí.';

  @override
  String get apiErrorRequestRouteNotFound =>
      'El servidor no ofrece esta función. Puede que la app necesite actualizarse.';

  @override
  String get apiErrorResourceConflict =>
      'El cambio entra en conflicto con datos existentes. Recarga e inténtalo de nuevo.';

  @override
  String get apiErrorServerError =>
      'Ocurrió un error en el servidor. Inténtalo de nuevo más tarde.';

  @override
  String get apiErrorStateTransitionInvalid =>
      'Este registro no puede pasar de su estado actual al solicitado.';

  @override
  String apiErrorResourceNotFound(String gender, String resource) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine': 'No se encontró la $resource. Puede que se haya eliminado.',
      'other': 'No se encontró el $resource. Puede que se haya eliminado.',
    });
    return '$_temp0';
  }

  @override
  String apiErrorResourceAlreadyExists(String gender, String resource) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine': 'Ese valor ya está en uso en otra $resource.',
      'other': 'Ese valor ya está en uso en otro $resource.',
    });
    return '$_temp0';
  }

  @override
  String apiErrorResourceStillReferenced(String list) {
    return 'Este registro no se puede eliminar porque todavía está en uso: $list.';
  }

  @override
  String get apiErrorResourceStillReferencedGeneric =>
      'Este registro todavía está en uso y no se puede eliminar.';

  @override
  String apiReferenceMore(int more) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: 'y $more más',
      one: 'y 1 más',
    );
    return '$_temp0';
  }

  @override
  String get apiErrorCashSessionAlreadyClosed =>
      'Esta sesión de caja ya está cerrada.';

  @override
  String get apiErrorCashSessionClosed =>
      'La sesión de caja se cerró mientras trabajabas. Recarga para continuar.';

  @override
  String get apiErrorCashSessionDrawerBusy =>
      'Esa caja ya tiene una sesión abierta.';

  @override
  String get apiErrorCashSessionNotClosed =>
      'La sesión de caja sigue abierta. Ciérrala primero.';

  @override
  String get apiErrorCashSessionNotOpen =>
      'Necesitas una sesión de caja abierta para esto.';

  @override
  String get apiErrorCashSessionUserBusy =>
      'Ya tienes una sesión abierta. Ciérrala antes de abrir otra.';

  @override
  String get apiErrorCsdCertificateNotRsa =>
      'El certificado no usa una llave RSA. No es un CSD válido.';

  @override
  String get apiErrorCsdCertificateUnreadable =>
      'No se pudo leer el archivo de certificado (.cer).';

  @override
  String get apiErrorCsdKeyMismatch =>
      'La llave (.key) no corresponde al certificado (.cer).';

  @override
  String get apiErrorCsdKeyNotEncrypted =>
      'La llave no tiene contraseña, así que no es una llave de CSD del SAT.';

  @override
  String get apiErrorCsdKeyNotRsa =>
      'El archivo de llave no contiene una llave RSA.';

  @override
  String get apiErrorCsdKeyUnreadable =>
      'No se pudo abrir la llave. Revisa la contraseña y el archivo .key.';

  @override
  String apiErrorCustomerCreditHold(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos a crédito vencidos. Liquídalos',
      one: '1 pedido a crédito vencido. Liquídalo',
    );
    return 'Este cliente tiene $_temp0 antes de crear un nuevo pedido a crédito.';
  }

  @override
  String apiErrorCustomerCreditLimitExceeded(String outstanding, String limit) {
    return 'Con este pedido el saldo del cliente llegaría a $outstanding, arriba de su límite de crédito de $limit.';
  }

  @override
  String apiErrorCustomerCreditLimitReached(String outstanding, String limit) {
    return 'El cliente debe $outstanding y ya alcanzó su límite de crédito de $limit. Debe pagar antes de volver a comprar.';
  }

  @override
  String get apiErrorCustomerDefaultNotDeletable =>
      'El cliente público en general no se puede eliminar.';

  @override
  String get apiErrorCustomerNoCreditLimit =>
      'Este cliente no tiene límite de crédito, así que no puede comprar a crédito.';

  @override
  String get apiErrorCustomerWalkInNoCredit =>
      'El cliente público en general no puede comprar a crédito.';

  @override
  String get apiErrorCustomerDiscountProductNotFound =>
      'El producto de este descuento ya no existe.';

  @override
  String get apiErrorDeliveryOrderLineAlreadyPresent =>
      'Esa partida ya está en esta orden de entrega.';

  @override
  String get apiErrorDeliveryOrderLineNotDeliverable =>
      'Esa partida no se puede entregar en esta orden: es de otra venta o ya se entregó.';

  @override
  String get apiErrorDeliveryOrderLineRepeated =>
      'La misma partida se agregó dos veces.';

  @override
  String get apiErrorDeliveryOrderMixedNotAllowed =>
      'Una orden de entrega no puede combinar envío y recolección.';

  @override
  String get apiErrorDeliveryOrderNotEditable =>
      'Esta orden de entrega ya no es borrador y no se puede modificar.';

  @override
  String apiErrorDeliveryOrderQuantityExceedsRemaining(
    String requested,
    String remaining,
  ) {
    return 'Pediste $requested, pero en esa partida solo quedan $remaining por entregar.';
  }

  @override
  String get apiErrorDeliveryOrderReasonRequired =>
      'Escribe un motivo para este cambio.';

  @override
  String get apiErrorDeliveryOrderSalesOrderFullyDelivered =>
      'Esta venta ya no tiene nada por entregar.';

  @override
  String get apiErrorDeliveryOrderSalesOrderNotDeliverable =>
      'Esta venta no se puede entregar: no está completada o se canceló.';

  @override
  String get apiErrorDeliveryOrderSalesOrderUnpaid =>
      'La venta debe estar pagada o ser a crédito antes de poder entregarse.';

  @override
  String get apiErrorDocumentNotEditable =>
      'Este documento está completado o cancelado y ya no se puede editar.';

  @override
  String get apiErrorEmailNotConfigured =>
      'El correo no está configurado en el servidor.';

  @override
  String get apiErrorEmailSendFailed =>
      'No se pudo enviar el correo. Inténtalo de nuevo más tarde.';

  @override
  String get apiErrorFacilityNoDispatchWarehouse =>
      'Esta sucursal no tiene un almacén desde el cual despachar.';

  @override
  String apiErrorFacilityOtherFacility(String gender, String resource) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine':
          'Esta $resource pertenece a otra sucursal, y no tienes acceso a otras sucursales.',
      'other':
          'Este $resource pertenece a otra sucursal, y no tienes acceso a otras sucursales.',
    });
    return '$_temp0';
  }

  @override
  String get apiErrorFacilityRequired =>
      'Elige una sucursal. Tu usuario no tiene una asignada.';

  @override
  String apiErrorImageTooLarge(String max) {
    return 'La imagen es demasiado grande. El máximo es $max.';
  }

  @override
  String get apiErrorImageUnsupportedFormat =>
      'El archivo no es una imagen que el servidor pueda leer. Prueba con otro archivo.';

  @override
  String get apiErrorIncidenceReasonRequired => 'Escribe un motivo.';

  @override
  String get apiErrorLockBusy =>
      'Alguien más está actualizando esto en este momento. Inténtalo de nuevo en un momento.';

  @override
  String get apiErrorPaymentNoTicket =>
      'Este tipo de pago no tiene ticket para imprimir.';

  @override
  String apiErrorPaymentExceedsOrderBalance(String amount, String balance) {
    return 'El monto $amount supera el saldo del pedido, $balance.';
  }

  @override
  String apiErrorPaymentExceedsUnapplied(String amount, String unapplied) {
    return 'El monto $amount supera lo que queda por aplicar del pago, $unapplied.';
  }

  @override
  String get apiErrorPaymentOrderSettled => 'El pedido ya está pagado.';

  @override
  String get apiErrorPaymentOrderCancelled =>
      'El pedido está cancelado y no se le puede aplicar un pago.';

  @override
  String get apiErrorPaymentOrderNotCompleted =>
      'El pedido no está confirmado; confírmalo antes de aplicarle un pago.';

  @override
  String apiErrorPaymentCurrencyMismatch(
    String paymentCurrency,
    String orderCurrency,
  ) {
    return 'El pago es en $paymentCurrency y el pedido en $orderCurrency.';
  }

  @override
  String get apiErrorPaymentCustomerMismatch => 'El pago es de otro cliente.';

  @override
  String get apiErrorPaymentApplicationReversed =>
      'Esta aplicación ya estaba revertida.';

  @override
  String get apiErrorPaymentAlreadyApplied =>
      'Este pago ya está aplicado a este pedido. Revierte esa aplicación antes de aplicarlo otra vez.';

  @override
  String get apiErrorPointOfSaleWarehouseFacilityMismatch =>
      'El almacén debe pertenecer a la misma sucursal que el punto de venta.';

  @override
  String get apiErrorPriceListCostNotAssignable =>
      'La lista de costos no se puede asignar a un cliente ni usar como reemplazo.';

  @override
  String get apiErrorPriceListCostNotDeletable =>
      'La lista de costos no se puede eliminar.';

  @override
  String get apiErrorPriceListCostReadOnly =>
      'Los precios de la lista de costos no se pueden editar aquí.';

  @override
  String get apiErrorPriceListReplaceWithItself =>
      'Una lista de precios no se puede reemplazar por sí misma.';

  @override
  String get apiErrorProductLookupCriteriaRequired =>
      'Escribe algo para buscar.';

  @override
  String apiErrorProductLookupTooMany(String max) {
    return 'Demasiados productos a la vez. El máximo es $max.';
  }

  @override
  String get apiErrorProductMergeWithItself =>
      'Un producto no se puede fusionar consigo mismo.';

  @override
  String get apiErrorProductPriceDuplicateEntry =>
      'El mismo precio se capturó dos veces.';

  @override
  String apiErrorProductPriceReferencesNotFound(
    String gender,
    String resource,
  ) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine':
          'Algunas de las $resource de este cambio ya no existen. Recarga e inténtalo de nuevo.',
      'other':
          'Algunos de los $resource de este cambio ya no existen. Recarga e inténtalo de nuevo.',
    });
    return '$_temp0';
  }

  @override
  String get apiErrorQuoteAlreadyCancelled =>
      'Esta cotización ya está cancelada.';

  @override
  String get apiErrorQuoteCancelled =>
      'Esta cotización se canceló y no se puede convertir.';

  @override
  String get apiErrorQuoteExpired => 'Esta cotización ya venció.';

  @override
  String get apiErrorQuoteNotConfirmed => 'Primero confirma la cotización.';

  @override
  String get apiErrorRefundAlreadyCancelled =>
      'Esta devolución ya está cancelada.';

  @override
  String get apiErrorRefundCompletedCannotCancel =>
      'Una devolución completada es definitiva y no se puede cancelar.';

  @override
  String apiErrorRefundLineInvoiced(String product, String invoice) {
    return '$product está en la factura $invoice. Cancela o ajusta esa factura antes de devolverlo.';
  }

  @override
  String apiErrorRefundLineInvoicedNoFolio(String product) {
    return '$product está en una factura vigente. Cancela o ajusta esa factura antes de devolverlo.';
  }

  @override
  String get apiErrorRefundNoReturnableLines =>
      'Captura una cantidad a devolver en al menos una partida.';

  @override
  String get apiErrorRefundNotConfirmed =>
      'Solo una devolución confirmada tiene comprobante para imprimir.';

  @override
  String get apiErrorRefundNothingRefundable =>
      'No queda nada por devolver en este pedido.';

  @override
  String get apiErrorRefundOrderNotCompleted =>
      'Este pedido no está completado, así que no se puede devolver.';

  @override
  String get apiErrorRefundOrderNotPaid =>
      'Este pedido no está pagado. Cancélalo en lugar de devolverlo.';

  @override
  String get apiErrorSalesOrderAlreadyCancelled =>
      'Este pedido ya está cancelado.';

  @override
  String apiErrorSalesOrderBelowMinQuantity(String min) {
    return 'Un producto está por debajo de su pedido mínimo de $min.';
  }

  @override
  String get apiErrorSalesOrderHasPaymentApplications =>
      'Este pedido tiene pagos aplicados. Revírtelos primero.';

  @override
  String get apiErrorSalesOrderInsufficientStock =>
      'Algunas partidas no tienen existencia suficiente';

  @override
  String get apiErrorSalesOrderMissingDeliveryDetails =>
      'Faltan datos de entrega';

  @override
  String get apiErrorSalesOrderNoLines =>
      'Agrega al menos una partida antes de confirmar.';

  @override
  String get apiErrorSalesOrderPaidCannotCancel =>
      'Un pedido pagado no se puede cancelar. Haz una devolución.';

  @override
  String get apiErrorSalesOrderZeroPricedLines =>
      'Algunas partidas no tienen precio';

  @override
  String apiErrorSupplierAgreementEndBeforeStart(String end, String start) {
    return 'La fecha de fin ($end) es anterior a la de inicio ($start).';
  }

  @override
  String apiErrorTaxpayerCertificateHolderMismatch(
    String certificateTaxpayer,
    String taxpayer,
  ) {
    return 'El certificado es de $certificateTaxpayer, no de $taxpayer.';
  }

  @override
  String apiErrorTaxpayerIssuerUnknown(String taxpayer) {
    return 'El emisor $taxpayer no está registrado.';
  }

  @override
  String get apiErrorUserNoCashDrawer =>
      'Tu usuario no tiene una caja asignada.';

  @override
  String get apiErrorUserNoFacility =>
      'Tu usuario no tiene una sucursal asignada.';

  @override
  String get apiErrorUserNoPointOfSale =>
      'Tu usuario no tiene un punto de venta asignado.';

  @override
  String get apiErrorUserProfileNotActive =>
      'Este perfil está inactivo y no se puede aplicar.';

  @override
  String get apiErrorWarehouseInTransitLocation =>
      'Aquí no se puede usar un almacén en tránsito.';

  @override
  String get apiErrorWarehouseInTransitManaged =>
      'Los almacenes en tránsito los administra el sistema y no se pueden editar.';

  @override
  String get apiErrorWarehouseRequired =>
      'Elige un almacén. Tu punto de venta no tiene uno.';

  @override
  String get apiValidationContactNameBlank => 'El nombre no puede estar vacío.';

  @override
  String get apiValidationEmailAddressInvalid =>
      'Ese no es un correo electrónico válido.';

  @override
  String get apiValidationProductBarcodeInvalid =>
      'El código de barras debe estar vacío o tener exactamente 13 dígitos (EAN-13).';

  @override
  String get apiValidationProductCodeHasWhitespace =>
      'El código no puede contener espacios.';

  @override
  String get apiValidationProfileDuplicateSystemObject =>
      'Un permiso aparece dos veces en este perfil.';

  @override
  String get apiValidationProfileUnknownSystemObject =>
      'El perfil tiene un permiso que el servidor no reconoce.';

  @override
  String get apiValidationSupplierAgreementEndBeforeStart =>
      'La fecha de fin no puede ser anterior a la de inicio.';

  @override
  String get apiValidationUserIdNotAlphanumeric =>
      'El nombre de usuario solo puede tener letras y números.';

  @override
  String apiResourceCustomerAddress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'direcciones',
      one: 'dirección',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerAddress => 'feminine';

  @override
  String apiResourceCustomerContact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'contactos',
      one: 'contacto',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerContact => 'masculine';

  @override
  String apiResourceCustomerTaxpayer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receptores fiscales',
      one: 'receptor fiscal',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerTaxpayer => 'masculine';

  @override
  String apiResourceSupplierAddress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'direcciones',
      one: 'dirección',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplierAddress => 'feminine';

  @override
  String apiResourceSupplierAgreement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'convenios',
      one: 'convenio',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplierAgreement => 'masculine';

  @override
  String apiResourceSupplierBankAccount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cuentas bancarias',
      one: 'cuenta bancaria',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplierBankAccount => 'feminine';

  @override
  String apiResourceSupplierContact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'contactos',
      one: 'contacto',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplierContact => 'masculine';

  @override
  String get paymentReverseTitle => 'Revertir aplicación';

  @override
  String paymentReverseSubject(String amount, String order) {
    return '$amount aplicados al pedido #$order.';
  }

  @override
  String get paymentReverseReasonLabel => 'Motivo';

  @override
  String get paymentReverseRefundWarning =>
      'Este pedido tiene devoluciones. Revertir el pago no deshace la devolución.';

  @override
  String get paymentReverseConfirm => 'Revertir';

  @override
  String get paymentReverseDone => 'Aplicación revertida';

  @override
  String get paymentApplyAction => 'Aplicar a pedido';

  @override
  String paymentApplyTitle(String payment) {
    return 'Aplicar pago #$payment';
  }

  @override
  String paymentApplyUnapplied(String amount) {
    return 'Sin aplicar: $amount';
  }

  @override
  String get paymentApplySearchHint => 'Pedido o folio…';

  @override
  String get paymentApplyColumnFolio => 'Folio';

  @override
  String get paymentApplyColumnTotal => 'Total';

  @override
  String get paymentApplyColumnBalance => 'Saldo';

  @override
  String get paymentApplyAmountLabel => 'Monto a aplicar';

  @override
  String paymentApplyAmountMax(String amount) {
    return 'Máximo $amount';
  }

  @override
  String paymentApplyAmountTooHigh(String amount) {
    return 'No puede ser más de $amount.';
  }

  @override
  String get paymentApplyAmountInvalid => 'Escribe un monto mayor que cero.';

  @override
  String paymentApplyEmpty(String currency) {
    return 'Este cliente no tiene pedidos por pagar en $currency.';
  }

  @override
  String get paymentApplyConfirm => 'Aplicar';

  @override
  String paymentApplyDone(String order) {
    return 'Pago aplicado a #$order';
  }

  @override
  String get paymentRecordAction => 'Registrar pago';

  @override
  String get paymentRecordActionShort => 'Pago';

  @override
  String get paymentRecordCurrencyLabel => 'Moneda';

  @override
  String get paymentRecordSave => 'Registrar';

  @override
  String get paymentRecordSaving => 'Registrando…';

  @override
  String get paymentRecordErrorCustomer => 'Elige un cliente.';

  @override
  String get paymentRecordErrorWalkIn =>
      'Elige un cliente con nombre: el público en general no puede tener anticipos ni abonos.';

  @override
  String get paymentRecordErrorMethod => 'Elige un método de pago.';

  @override
  String get paymentRecordErrorReference =>
      'Este método necesita una referencia.';

  @override
  String get paymentRecordErrorAmount => 'Escribe un monto mayor que cero.';

  @override
  String get paymentRecordErrorCashSession =>
      'Para registrar efectivo necesitas una caja abierta hoy.';

  @override
  String get paymentRecordGoToSessions => 'Ir a cajas';

  @override
  String get paymentRecordUnknownResult =>
      'No sabemos si el pago se registró: se perdió la conexión. Búscalo en Pagos antes de reintentar.';

  @override
  String get salesOrderPaymentsButton => 'Pagos';

  @override
  String salesOrderPaymentsTitle(String order) {
    return 'Pagos del pedido #$order';
  }

  @override
  String get salesOrderPaymentOpenTooltip => 'Abrir pago';

  @override
  String get paymentApplyNoMatches => 'Ningún pedido coincide con la búsqueda.';

  @override
  String get paymentVerificationMenuTitle => 'Verificación de pagos';

  @override
  String get paymentVerificationEmpty =>
      'No hay pagos sin verificar con estos filtros.';

  @override
  String get paymentVerificationMethodAll => 'Todos';

  @override
  String get paymentVerificationFacilityAll => 'Todas';

  @override
  String get paymentVerifyAction => 'Verificar';

  @override
  String get paymentRejectAction => 'Rechazar';

  @override
  String get paymentVerifyTitle => 'Verificar pago';

  @override
  String get paymentRejectTitle => 'Rechazar pago';

  @override
  String get paymentVerifyIrreversible =>
      'Confirma que el dinero está en el banco. No se puede deshacer.';

  @override
  String get paymentRejectReasonLabel => 'Motivo';

  @override
  String get paymentRejectNote =>
      'El pago seguirá sin verificar; el rechazo queda registrado con tu nombre y la fecha.';

  @override
  String paymentVerifiedSnack(String id) {
    return 'Pago $id verificado.';
  }

  @override
  String paymentRejectedSnack(String id) {
    return 'Rechazo registrado. El pago $id sigue sin verificar y seguirá en la lista de verificación.';
  }

  @override
  String get paymentVerifyUnknown =>
      'No sabemos si se verificó: se perdió la conexión. La lista se actualizó.';

  @override
  String get paymentRejectUnknown =>
      'No sabemos si se registró el rechazo: se perdió la conexión. La lista se actualizó.';

  @override
  String get apiErrorPaymentAlreadyVerified =>
      'Otra persona ya verificó este pago.';

  @override
  String get navDeliveryOrders => 'Órdenes de entrega';

  @override
  String deliveryOrderTitle(String serial) {
    return 'Orden de entrega $serial';
  }

  @override
  String get deliveryOrderTitleDraft => 'Orden de entrega · Borrador';

  @override
  String get deliveryOrderDraftFolio => 'Borrador';

  @override
  String get deliveryOrdersEmpty =>
      'No hay órdenes de entrega con estos filtros.';

  @override
  String get deliveryOrdersSearchHint => 'Folio';

  @override
  String get deliveryOrdersNoFacilityTitle => 'No hay instalación configurada';

  @override
  String get deliveryOrdersNoFacilityMessage =>
      'Tu cuenta no tiene una instalación asignada, así que las órdenes de entrega no se pueden listar. Pide a tu administrador que configure una en tu usuario.';

  @override
  String get deliveryOrderBackToList => 'Volver a órdenes de entrega';

  @override
  String get deliveryOrderStatusDraft => 'Borrador';

  @override
  String get deliveryOrderStatusPendingApproval => 'Pendiente de aprobación';

  @override
  String get deliveryOrderStatusApproved => 'Aprobada';

  @override
  String get deliveryOrderStatusReadyForPickup => 'Lista para recoger';

  @override
  String get deliveryOrderStatusPickedUp => 'Recogida';

  @override
  String get deliveryOrderStatusInPreparation => 'En preparación';

  @override
  String get deliveryOrderStatusInTransit => 'En tránsito';

  @override
  String get deliveryOrderStatusDelivered => 'Entregada';

  @override
  String get deliveryOrderStatusPartiallyDelivered => 'Entregada parcialmente';

  @override
  String get deliveryOrderStatusFailed => 'Fallida';

  @override
  String get deliveryOrderStatusCancelled => 'Cancelada';

  @override
  String get deliveryOrderTypeDelivery => 'Entrega';

  @override
  String get deliveryOrderTypePickup => 'Recoge en tienda';

  @override
  String get deliveryOrderColumnSerial => 'Folio';

  @override
  String get deliveryOrderColumnCustomer => 'Cliente';

  @override
  String get deliveryOrderColumnType => 'Tipo';

  @override
  String get deliveryOrderColumnScheduled => 'Programada';

  @override
  String get deliveryOrderColumnDestination => 'Destino';

  @override
  String get deliveryOrderColumnSalesOrders => 'Pedidos';

  @override
  String get deliveryOrderColumnStatus => 'Estado';

  @override
  String get deliveryOrderFactFacility => 'Sucursal';

  @override
  String get deliveryOrderFactPriority => 'Prioridad';

  @override
  String get deliveryOrderFactContact => 'Contacto';

  @override
  String get deliveryOrderFactComment => 'Comentario';

  @override
  String get deliveryOrderFactParent => 'De la orden';

  @override
  String get deliveryOrderFactChild => 'Orden derivada';

  @override
  String get deliveryOrderLineColumnCode => 'Código';

  @override
  String get deliveryOrderLineColumnProduct => 'Producto';

  @override
  String get deliveryOrderLineColumnWarehouse => 'Almacén';

  @override
  String get deliveryOrderLineColumnSalesOrder => 'Pedido';

  @override
  String get deliveryOrderLineColumnOrdered => 'Ordenada';

  @override
  String get deliveryOrderLineColumnCommitted => 'Comprometida';

  @override
  String get deliveryOrderLineColumnDelivered => 'Entregada';

  @override
  String get deliveryOrderLineColumnReturned => 'Devuelta';

  @override
  String get deliveryOrderLineColumnOpen => 'Abierta';

  @override
  String get deliveryOrderLinesTitle => 'Líneas';

  @override
  String get deliveryOrderHistoryTitle => 'Historial';

  @override
  String get deliveryOrderProofTitle => 'Comprobante de entrega';

  @override
  String get deliveryOrderProofReceiver => 'Recibió';

  @override
  String get deliveryOrderProofIdShown => 'Identificación mostrada';

  @override
  String get deliveryOrderProofCapturedAt => 'Capturado';

  @override
  String get deliveryOrderProofCapturedBy => 'Capturó';

  @override
  String get deliveryOrderProofLoadFailed => 'No se pudo cargar el comprobante';

  @override
  String get deliveryOrderProofEnlargeTooltip => 'Ampliar foto';

  @override
  String get deliveryOrderEventsEmpty => 'Sin movimientos todavía.';

  @override
  String deliveryOrderRejectionBanner(String reason) {
    return 'Motivo de rechazo: $reason';
  }

  @override
  String get deliveryOrderFilterStatus => 'Estado';

  @override
  String get deliveryOrderFilterType => 'Tipo';

  @override
  String get deliveryOrderFilterScheduled => 'Fecha programada';

  @override
  String get deliveryOrderFilterCustomer => 'Cliente';

  @override
  String get deliveryOrderFilterSalesOrder => 'Pedido';

  @override
  String get deliveryOrderFilterFacility => 'Sucursal';

  @override
  String get deliveryOrderFilterActiveStatuses => 'Activas';

  @override
  String get deliveryOrderFilterAllStatuses => 'Todas';

  @override
  String get deliveryOrderFilterAllTypes => 'Todos';

  @override
  String get deliveryOrderFilterMyFacility => 'Mi sucursal';

  @override
  String get deliveryOrderFilterSalesOrderHint => 'Número de pedido';

  @override
  String get deliveryOrderEditHeader => 'Editar encabezado';

  @override
  String get deliveryOrderAddLine => 'Agregar línea';

  @override
  String get deliveryOrderConfirmAction => 'Confirmar';

  @override
  String get deliveryOrderCancelAction => 'Cancelar orden';

  @override
  String get deliveryOrderRequeueAction => 'Reprogramar';

  @override
  String get deliveryOrderReadyAction => 'Lista para recoger';

  @override
  String get deliveryOrderPickupAction => 'Entregar al cliente';

  @override
  String get deliveryOrderBackButton => 'Volver';

  @override
  String get deliveryOrderLineEditTooltip => 'Cambiar cantidad';

  @override
  String get deliveryOrderLineRemoveTooltip => 'Quitar línea';

  @override
  String get deliveryOrderConfirmTitle => '¿Confirmar orden de entrega?';

  @override
  String deliveryOrderConfirmSummary(String customer, String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# líneas',
      one: '# línea',
    );
    return '$customer · Programada $date · $_temp0';
  }

  @override
  String get deliveryOrderConfirmIrreversible =>
      'Una vez confirmada, ya no podrá editarse.';

  @override
  String get deliveryOrderConfirmNeedsLines =>
      'Agrega al menos una línea para poder confirmar.';

  @override
  String deliveryOrderRequeueTitle(String serial) {
    return '¿Reprogramar orden $serial?';
  }

  @override
  String deliveryOrderRequeueBody(String customer) {
    return '$customer. La orden volverá a En preparación y sus cantidades quedarán abiertas otra vez.';
  }

  @override
  String deliveryOrderReadyTitle(String serial) {
    return '¿Marcar orden $serial lista para recoger?';
  }

  @override
  String deliveryOrderReadyBody(String customer) {
    return '$customer. El cliente podrá pasar a recoger el pedido.';
  }

  @override
  String deliveryOrderCancelTitle(String serial) {
    return 'Cancelar orden $serial';
  }

  @override
  String deliveryOrderCancelSummary(String customer, String date) {
    return '$customer · Programada $date';
  }

  @override
  String get deliveryOrderCancelReasonLabel => 'Motivo';

  @override
  String get deliveryOrderAddLineStep1Title => 'Agregar línea · 1 de 2';

  @override
  String deliveryOrderAddLineStep2Title(String serial) {
    return 'Agregar línea · 2 de 2 · Venta $serial';
  }

  @override
  String deliveryOrderAddLineStep1Intro(String customer, String facility) {
    return 'Ventas completadas de $customer en $facility';
  }

  @override
  String get deliveryOrderAddLineSearchHint => 'Folio de venta';

  @override
  String get deliveryOrderAddLineSaleColumnSerial => 'Folio';

  @override
  String get deliveryOrderAddLineSaleColumnDate => 'Fecha';

  @override
  String get deliveryOrderAddLineSaleColumnTotal => 'Total';

  @override
  String get deliveryOrderAddLineLoadMore => 'Cargar más';

  @override
  String get deliveryOrderAddLineColumnRemaining => 'Pendiente';

  @override
  String get deliveryOrderAddLineColumnQuantity => 'Cantidad';

  @override
  String get deliveryOrderAddLineAnotherSale => 'Otra venta';

  @override
  String get deliveryOrderAddLineSubmit => 'Agregar';

  @override
  String get deliveryOrderAddLineEmptySales =>
      'Este cliente no tiene ventas con pendiente por entregar en esta sucursal.';

  @override
  String get deliveryOrderAddLineEmptyLines =>
      'Esta venta ya no tiene pendiente por entregar.';

  @override
  String deliveryOrderAddLineQuantityInvalid(String remaining) {
    return 'Escribe una cantidad mayor que 0 y no mayor que $remaining.';
  }

  @override
  String get deliveryOrderLineQuantityTitle => 'Cambiar cantidad';

  @override
  String deliveryOrderLineQuantityOrdered(String quantity) {
    return 'Ordenada en la venta: $quantity';
  }

  @override
  String get deliveryOrderLineQuantityLabel => 'Cantidad';

  @override
  String get deliveryOrderLineQuantityInvalid =>
      'Escribe una cantidad mayor que 0.';

  @override
  String deliveryOrderLineRemoveTitle(String product) {
    return '¿Quitar $product de la orden?';
  }

  @override
  String get deliveryOrderLineRemoveBody =>
      'La cantidad volverá a estar disponible para entregar.';

  @override
  String get deliveryOrderLineRemoveAction => 'Quitar';

  @override
  String deliveryOrderPickupTitle(String serial) {
    return 'Entregar al cliente · Orden $serial';
  }

  @override
  String get deliveryOrderPickupNameLabel => 'Nombre de quien recibe';

  @override
  String get deliveryOrderPickupIdLabel => 'Identificación mostrada';

  @override
  String get deliveryOrderPickupPhotoLabel => 'Foto';

  @override
  String get deliveryOrderPickupChooseFile => 'Elegir archivo';

  @override
  String get deliveryOrderPickupClearFile => 'Quitar archivo';

  @override
  String get deliveryOrderPickupSubmit => 'Entregar';

  @override
  String get deliveryOrderHeaderTitle => 'Editar encabezado';

  @override
  String get deliveryOrderHeaderScheduledLabel => 'Fecha programada';

  @override
  String get deliveryOrderHeaderPriorityLabel => 'Prioridad';

  @override
  String get deliveryOrderHeaderDestinationLabel => 'Destino';

  @override
  String get deliveryOrderHeaderContactLabel => 'Contacto';

  @override
  String get deliveryOrderHeaderCommentLabel => 'Comentario';

  @override
  String get deliveryOrderHeaderPriorityInvalid =>
      'Escribe un número entero de 0 o más.';

  @override
  String deliveryOrderHeaderPickupDestination(String facility) {
    return 'Sucursal $facility';
  }

  @override
  String deliveryOrderSnackConfirmed(String serial) {
    return 'Orden $serial confirmada';
  }

  @override
  String deliveryOrderSnackCancelled(String serial) {
    return 'Orden $serial cancelada';
  }

  @override
  String deliveryOrderSnackRequeued(String serial) {
    return 'Orden $serial reprogramada';
  }

  @override
  String deliveryOrderSnackReady(String serial) {
    return 'Orden $serial lista para recoger';
  }

  @override
  String deliveryOrderSnackPickedUp(String serial) {
    return 'Orden $serial entregada al cliente';
  }

  @override
  String deliveryOrderSnackHeaderSaved(String serial) {
    return 'Encabezado de la orden $serial guardado';
  }

  @override
  String deliveryOrderSnackLineAdded(String serial) {
    return 'Línea agregada a la orden $serial';
  }

  @override
  String deliveryOrderSnackLineUpdated(String serial) {
    return 'Cantidad actualizada en la orden $serial';
  }

  @override
  String deliveryOrderSnackLineRemoved(String serial) {
    return 'Línea quitada de la orden $serial';
  }

  @override
  String get deliveryOrderActionUnknown =>
      'No sabemos si se completó: se perdió la conexión. La orden se actualizó.';

  @override
  String apiErrorDeliveryOrderInsufficientNotice(
    String minHours,
    String earliest,
  ) {
    return 'Se requieren al menos $minHours h de anticipación. Fecha más próxima: $earliest.';
  }

  @override
  String get apiErrorDeliveryOrderNoLines =>
      'La orden de entrega no tiene líneas.';

  @override
  String get apiErrorDeliveryOrderNotFailed =>
      'Solo una orden fallida se puede reprogramar.';

  @override
  String get apiErrorDeliveryOrderOnItinerary =>
      'Esta orden está en una ruta de entrega abierta. Quítala de la ruta antes de cancelarla.';

  @override
  String get apiErrorDeliveryOrderProofIncomplete =>
      'Faltan datos del comprobante: indica quién recibe y la identificación que mostró.';

  @override
  String get navDeliveryOrderApproval => 'Aprobación de entregas';

  @override
  String get deliveryOrderApprovalColumnPriority => 'Prio.';

  @override
  String get deliveryOrderApprovalEmpty =>
      'No hay órdenes de entrega pendientes de aprobación.';

  @override
  String get deliveryOrderApprovalNoFacilityTitle => 'Sin sucursal configurada';

  @override
  String get deliveryOrderApprovalNoFacilityMessage =>
      'Tu usuario no tiene sucursal asignada. La aprobación de entregas muestra las órdenes de tu sucursal. Pide a tu administrador que configure una en tu usuario.';

  @override
  String get deliveryOrderApprovalForbidden =>
      'No tienes acceso a la aprobación de entregas.';

  @override
  String get deliveryOrderApproveAction => 'Aprobar';

  @override
  String get deliveryOrderRejectAction => 'Rechazar';

  @override
  String deliveryOrderApproveTitle(String serial) {
    return '¿Aprobar orden de entrega $serial?';
  }

  @override
  String get deliveryOrderApproveNextDelivery =>
      'Pasará a En preparación y aparecerá para el almacén.';

  @override
  String get deliveryOrderApproveNextPickup =>
      'Pasará a Aprobada; después se marca lista para recoger.';

  @override
  String deliveryOrderRejectTitle(String serial) {
    return 'Rechazar orden de entrega $serial';
  }

  @override
  String deliveryOrderRejectSummary(String customer, String date) {
    return '$customer · Programada $date';
  }

  @override
  String get deliveryOrderRejectReasonLabel => 'Motivo';

  @override
  String get deliveryOrderRejectNote =>
      'La orden regresa a borrador para que su autor la corrija y la vuelva a confirmar. El motivo queda en la orden.';

  @override
  String deliveryOrderSnackApproved(String serial, String status) {
    return 'Orden $serial aprobada: $status';
  }

  @override
  String deliveryOrderSnackRejected(String serial) {
    return 'Orden $serial rechazada. Regresó a borrador con el motivo.';
  }

  @override
  String get apiErrorDeliveryOrderNotPendingApproval =>
      'Esta orden ya no está pendiente de aprobación.';

  @override
  String get navForDelivery => 'Por entregar';

  @override
  String get forDeliveryPeriodLabel => 'Periodo';

  @override
  String get forDeliveryPeriodEarlier => 'Anteriores';

  @override
  String get forDeliveryPeriodYesterday => 'Ayer';

  @override
  String get forDeliveryPeriodToday => 'Hoy';

  @override
  String get forDeliveryPeriodTomorrow => 'Mañana';

  @override
  String get forDeliveryPeriodDayAfter => 'Pasado mañana';

  @override
  String get forDeliveryPeriodLater => 'Posteriores';

  @override
  String forDeliveryPeriodOptionDated(String label, String date, int total) {
    return '$label · $date ($total)';
  }

  @override
  String forDeliveryPeriodOptionUndated(String label, int total) {
    return '$label ($total)';
  }

  @override
  String get forDeliveryNoDate => 'Sin fecha';

  @override
  String get forDeliveryEmpty =>
      'No hay entregas pendientes para este periodo.';

  @override
  String get forDeliveryColumnPriority => 'Prio.';

  @override
  String get forDeliveryColumnProduct => 'Producto';

  @override
  String get forDeliveryColumnWarehouse => 'Almacén';

  @override
  String get forDeliveryColumnOpenQuantity => 'Pendiente';

  @override
  String get deliveryOrderViewTicket => 'Ver ticket';

  @override
  String get deliveryOrderViewLetter => 'Ver formato carta';

  @override
  String get deliveryTicketScopeTitle => '¿Qué líneas imprimir?';

  @override
  String get deliveryTicketScopeAll => 'Todos los almacenes';

  @override
  String documentDeliveryTicketTitle(String folio) {
    return 'Ticket de entrega · $folio';
  }

  @override
  String documentDeliveryTicketWarehouseTitle(String folio, String warehouse) {
    return 'Ticket de entrega · $folio · $warehouse';
  }

  @override
  String documentDeliveryOrderLetterTitle(String folio) {
    return 'Orden de entrega · $folio (carta)';
  }

  @override
  String get apiErrorDeliveryOrderNotApproved =>
      'La orden de entrega aún no está aprobada; no se puede imprimir.';

  @override
  String get apiErrorDeliveryOrderUnknownWarehouse =>
      'El almacén elegido no existe.';

  @override
  String get apiErrorDeliveryOrderNoLinesFromWarehouse =>
      'Ninguna línea de esta orden sale del almacén elegido.';

  @override
  String get taxpayerBatchesSectionTitle => 'Series';

  @override
  String taxpayerBatchesSectionTitleWithCount(int count) {
    return 'Series ($count)';
  }

  @override
  String get taxpayerBatchesEmpty =>
      'Este emisor no tiene series. Sin una serie del tipo correspondiente no puede emitir ese documento.';

  @override
  String get taxpayerBatchColumnSeries => 'Serie';

  @override
  String get taxpayerBatchColumnType => 'Tipo';

  @override
  String get taxpayerBatchColumnTemplate => 'Plantilla';

  @override
  String get taxpayerBatchColumnInUse => 'En uso';

  @override
  String get taxpayerBatchDialogCreateTitle => 'Nueva serie';

  @override
  String get taxpayerBatchDialogViewTitle => 'Ver serie';

  @override
  String get taxpayerBatchDialogEditTitle => 'Editar serie';

  @override
  String get taxpayerBatchSeriesLabel => 'Serie';

  @override
  String get taxpayerBatchTypeLabel => 'Tipo de documento';

  @override
  String get taxpayerBatchTemplateNameLabel => 'Nombre de plantilla';

  @override
  String get taxpayerBatchLogoLabel => 'Logo (nombre de archivo)';

  @override
  String get taxpayerBatchHeaderHeightLabel => 'Alto de encabezado (mm)';

  @override
  String get taxpayerBatchFooterHeightLabel => 'Alto de pie (mm)';

  @override
  String get taxpayerBatchInUseNote =>
      'Ya hay documentos emitidos con esta serie; solo puede cambiar la plantilla.';

  @override
  String get taxpayerBatchAccountsTitle => 'Cuentas bancarias';

  @override
  String get taxpayerBatchAccountBank => 'Banco';

  @override
  String get taxpayerBatchAccountNumber => 'Cuenta';

  @override
  String get taxpayerBatchAccountClabe => 'CLABE';

  @override
  String get taxpayerBatchAccountCurrency => 'Moneda';

  @override
  String get taxpayerBatchAddAccount => 'Agregar cuenta';

  @override
  String get taxpayerBatchMoveAccountUp => 'Subir';

  @override
  String get taxpayerBatchMoveAccountDown => 'Bajar';

  @override
  String get taxpayerBatchRemoveAccount => 'Quitar cuenta';

  @override
  String get taxpayerBatchNoAccounts => 'Sin cuentas bancarias';

  @override
  String get taxpayerBatchCloseButton => 'Cerrar';

  @override
  String get taxpayerBatchDeleteTitle => '¿Eliminar la serie?';

  @override
  String taxpayerBatchDeleteMessage(String series, String type) {
    return 'Se eliminará la serie $series ($type).';
  }

  @override
  String get taxpayerBatchSeriesRequiredError => 'Escribe la serie.';

  @override
  String get taxpayerBatchSeriesTooLongError =>
      'La serie puede tener hasta 10 caracteres.';

  @override
  String get taxpayerBatchTypeRequiredError => 'Elige el tipo de documento.';

  @override
  String get taxpayerBatchTemplateNameRequiredError =>
      'Escribe el nombre de la plantilla.';

  @override
  String get taxpayerBatchTemplateNameTooLongError =>
      'El nombre de la plantilla puede tener hasta 50 caracteres.';

  @override
  String get taxpayerBatchHeightInvalidError =>
      'Escribe un número entero, 0 o más.';

  @override
  String get fiscalDocumentKindInvoice => 'Factura';

  @override
  String get fiscalDocumentKindFeeReceipt => 'Recibo de honorarios';

  @override
  String get fiscalDocumentKindRentReceipt => 'Recibo de arrendamiento';

  @override
  String get fiscalDocumentKindDebitNote => 'Nota de cargo';

  @override
  String get fiscalDocumentKindCreditNote => 'Nota de crédito';

  @override
  String get fiscalDocumentKindPaymentReceipt => 'Recibo de pago';

  @override
  String get fiscalDocumentKindAdvancePaymentsApplied =>
      'Aplicación de anticipos';

  @override
  String fiscalDocumentKindUnknown(int code) {
    return 'Tipo desconocido ($code)';
  }

  @override
  String get apiErrorTaxpayerBatchInUseUpdate =>
      'La serie ya se usa en documentos emitidos; solo puede cambiar su plantilla.';

  @override
  String get apiErrorTaxpayerBatchInUseDelete =>
      'La serie ya se usa en documentos emitidos y no se puede eliminar.';

  @override
  String get apiValidationTaxpayerBatchSeriesBlank =>
      'La serie no puede quedar en blanco.';

  @override
  String apiResourceTaxpayerBatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'series',
      one: 'serie',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderTaxpayerBatch => 'feminine';

  @override
  String get taxpayerBatchSaveFailed => 'No se pudo guardar la serie.';

  @override
  String get taxpayerBatchDeleteFailed => 'No se pudo eliminar la serie.';

  @override
  String get navInvoicingGroup => 'Facturación';

  @override
  String get navFiscalDocuments => 'Facturas';

  @override
  String fiscalDocumentTitle(String folio) {
    return 'Factura $folio';
  }

  @override
  String fiscalDocumentTitleKind(String kind, String folio) {
    return '$kind $folio';
  }

  @override
  String fiscalDocumentTitleDraft(int id) {
    return 'Borrador #$id';
  }

  @override
  String get fiscalDocumentDraftFolio => 'Borrador';

  @override
  String get fiscalDocumentsEmpty => 'Aún no hay facturas.';

  @override
  String get fiscalDocumentsSearchHint =>
      'Folio, UUID, RFC o nombre del receptor';

  @override
  String get fiscalDocumentBackToList => 'Volver a facturas';

  @override
  String get fiscalDocumentNotFound => 'No encontramos este documento.';

  @override
  String get fiscalDocumentLoadFailed => 'No se pudo cargar el documento.';

  @override
  String get fiscalDocumentStatusDraft => 'Borrador';

  @override
  String get fiscalDocumentStatusSealed => 'Sellado';

  @override
  String get fiscalDocumentStatusIssued => 'Timbrado';

  @override
  String get fiscalDocumentStatusCancelled => 'Cancelado';

  @override
  String get fiscalDocumentColFolio => 'Folio';

  @override
  String get fiscalDocumentColType => 'Tipo';

  @override
  String get fiscalDocumentColIssuer => 'Emisor';

  @override
  String get fiscalDocumentColRecipient => 'Receptor';

  @override
  String get fiscalDocumentColIssued => 'Fecha de emisión';

  @override
  String get fiscalDocumentColStatus => 'Estado';

  @override
  String get fiscalDocumentColTotal => 'Total';

  @override
  String get fiscalDocumentFacetStatus => 'Estado';

  @override
  String get fiscalDocumentFacetType => 'Tipo';

  @override
  String get fiscalDocumentFacetIssuer => 'Emisor';

  @override
  String get fiscalDocumentFacetIssued => 'Fecha de emisión';

  @override
  String get fiscalDocumentFacetAll => 'Todos';

  @override
  String get fiscalDocumentDateFacetHelper =>
      'Los borradores no tienen fecha de emisión y no aparecen al filtrar por fecha.';

  @override
  String get fiscalDocumentBannerSealed =>
      'Sellada, pendiente de timbrar. El timbrado aún no está disponible en este sistema.';

  @override
  String get fiscalDocumentBannerReadOnlyKind =>
      'Este tipo de documento solo se puede consultar.';

  @override
  String fiscalDocumentBannerCancelled(String date) {
    return 'Cancelada el $date.';
  }

  @override
  String get fiscalDocumentNoCustomerNote =>
      'Este borrador no tiene cliente: no se puede cambiar el receptor ni agregar pedidos.';

  @override
  String get fiscalDocumentFactIssuer => 'Emisor';

  @override
  String get fiscalDocumentFactRecipient => 'Receptor';

  @override
  String get fiscalDocumentFactCustomer => 'Cliente';

  @override
  String get fiscalDocumentFactFacility => 'Sucursal';

  @override
  String get fiscalDocumentFactSeriesFolio => 'Serie y folio';

  @override
  String get fiscalDocumentFactIssued => 'Fecha de emisión';

  @override
  String get fiscalDocumentFactPaymentTerms => 'Método de pago';

  @override
  String get fiscalDocumentFactPaymentForm => 'Forma de pago';

  @override
  String get fiscalDocumentFactUsage => 'Uso del CFDI';

  @override
  String get fiscalDocumentFactCurrency => 'Moneda';

  @override
  String get fiscalDocumentFactReference => 'Referencia';

  @override
  String get fiscalDocumentFactComment => 'Notas';

  @override
  String get fiscalDocumentFactUuid => 'UUID';

  @override
  String get fiscalDocumentFactStamped => 'Fecha de timbrado';

  @override
  String get fiscalDocumentFactRegime => 'Régimen';

  @override
  String get fiscalDocumentFactPostalCode => 'C.P.';

  @override
  String get fiscalDocumentFactIssuedOnConfirm => 'al confirmar';

  @override
  String get fiscalDocumentTermsPue => 'Pago en una sola exhibición (PUE)';

  @override
  String get fiscalDocumentTermsPpd => 'Pago en parcialidades o diferido (PPD)';

  @override
  String get fiscalDocumentLinesTitle => 'Partidas';

  @override
  String get fiscalDocumentLineQuantity => 'Cantidad';

  @override
  String get fiscalDocumentLineUnit => 'Unidad';

  @override
  String get fiscalDocumentLineSatKey => 'Clave SAT';

  @override
  String get fiscalDocumentLineDescription => 'Descripción';

  @override
  String get fiscalDocumentLinePrice => 'Precio unitario';

  @override
  String get fiscalDocumentLineDiscount => 'Descuento';

  @override
  String get fiscalDocumentLineTax => 'IVA';

  @override
  String get fiscalDocumentLineAmount => 'Importe';

  @override
  String fiscalDocumentLineInternalCode(String code) {
    return 'Clave interna: $code';
  }

  @override
  String get fiscalDocumentLineFromOrder => 'Pedido';

  @override
  String get fiscalDocumentLinesEmpty => 'La factura no tiene partidas.';

  @override
  String get fiscalDocumentTaxIva16 => '16 %';

  @override
  String get fiscalDocumentTaxZero => '0 %';

  @override
  String get fiscalDocumentTaxExempt => 'Exento';

  @override
  String fiscalDocumentTaxOther(String rate) {
    return '$rate';
  }

  @override
  String get fiscalDocumentRelationsTitle => 'Documentos relacionados';

  @override
  String get fiscalDocumentTotalSubtotal => 'Subtotal';

  @override
  String get fiscalDocumentTotalDiscount => 'Descuento';

  @override
  String get fiscalDocumentTotalTax => 'IVA';

  @override
  String get fiscalDocumentTotalTotal => 'Total';

  @override
  String get fiscalDocumentTotalEstimated => 'Total (estimado)';

  @override
  String get fiscalDocumentRelationSubstitution =>
      '04 · Sustitución de CFDI cancelado';

  @override
  String get fiscalDocumentRelationAdvance => '07 · Aplicación de anticipo';

  @override
  String get fiscalDocumentRelationCreditNote => '01 · Nota de crédito';

  @override
  String get fiscalDocumentNewAction => 'Nueva factura';

  @override
  String get fiscalDocumentEditHeader => 'Editar encabezado';

  @override
  String get fiscalDocumentAddOrder => 'Agregar pedido';

  @override
  String get fiscalDocumentAddProduct => 'Agregar producto';

  @override
  String get fiscalDocumentAddRelation => 'Agregar relación';

  @override
  String get fiscalDocumentConfirmAction => 'Confirmar';

  @override
  String get fiscalDocumentReopenAction => 'Reabrir';

  @override
  String get fiscalDocumentViewPdf => 'Ver PDF';

  @override
  String get fiscalDocumentDownloadXml => 'Descargar XML';

  @override
  String get fiscalDocumentNewTitle => 'Nueva factura';

  @override
  String get fiscalDocumentNewCustomer => 'Cliente';

  @override
  String get fiscalDocumentNewRecipient => 'RFC del receptor';

  @override
  String get fiscalDocumentNewNoTaxpayers =>
      'Este cliente no tiene RFC registrado.';

  @override
  String get fiscalDocumentNewCreate => 'Crear';

  @override
  String get fiscalDocumentHeaderTitle => 'Editar encabezado';

  @override
  String get fiscalDocumentHeaderRecipient => 'Receptor (RFC)';

  @override
  String get fiscalDocumentHeaderSeries => 'Serie';

  @override
  String get fiscalDocumentHeaderUsage => 'Uso del CFDI';

  @override
  String get fiscalDocumentHeaderTerms => 'Método de pago';

  @override
  String get fiscalDocumentHeaderForm => 'Forma de pago';

  @override
  String get fiscalDocumentHeaderIssued => 'Fecha de emisión';

  @override
  String get fiscalDocumentHeaderFacility => 'Sucursal';

  @override
  String get fiscalDocumentHeaderReference => 'Referencia';

  @override
  String get fiscalDocumentHeaderComment => 'Notas';

  @override
  String get fiscalDocumentHeaderSeriesLocked =>
      'La serie no cambia una vez asignado el folio.';

  @override
  String get fiscalDocumentHeaderFormPpd => '99 — Por definir';

  @override
  String get fiscalDocumentHeaderIssuedHelper =>
      'Vacía: se usa la fecha al confirmar. Si la escribes, debe estar dentro de las últimas 72 horas.';

  @override
  String get fiscalDocumentHeaderIssuedOutOfRange =>
      'La fecha debe estar en las últimas 72 horas y no ser futura.';

  @override
  String get fiscalDocumentHeaderSaved => 'Encabezado actualizado.';

  @override
  String get fiscalDocumentLineDialogTitle => 'Editar partida';

  @override
  String get fiscalDocumentLineFieldQuantity => 'Cantidad';

  @override
  String get fiscalDocumentLineFieldPrice => 'Precio unitario';

  @override
  String get fiscalDocumentLineFieldDiscount => 'Descuento %';

  @override
  String get fiscalDocumentLineFieldTax => 'IVA';

  @override
  String get fiscalDocumentLineFieldCode => 'Clave interna';

  @override
  String get fiscalDocumentLineFieldName => 'Descripción';

  @override
  String get fiscalDocumentLineFieldComment => 'Comentario';

  @override
  String get fiscalDocumentLineNameHelper =>
      'Si la dejas en blanco, se restablece al nombre del producto.';

  @override
  String get fiscalDocumentLineQuantityInvalid =>
      'Escribe una cantidad mayor que 0.';

  @override
  String get fiscalDocumentLinePriceInvalid => 'Escribe un precio de 0 o más.';

  @override
  String get fiscalDocumentLineDiscountInvalid =>
      'Escribe un descuento entre 0 y 100.';

  @override
  String get fiscalDocumentLineCodeTooLong =>
      'La clave interna puede tener hasta 35 caracteres.';

  @override
  String get fiscalDocumentRemoveLineTitle => 'Quitar partida';

  @override
  String get fiscalDocumentRemoveLineBody =>
      '¿Quitar esta partida de la factura?';

  @override
  String get fiscalDocumentRemoveAction => 'Quitar';

  @override
  String get fiscalDocumentAddOrderTitle => 'Agregar pedido';

  @override
  String get fiscalDocumentAddOrderSearch => 'Buscar pedido';

  @override
  String get fiscalDocumentAddOrderEmpty =>
      'El cliente no tiene pedidos completados.';

  @override
  String fiscalDocumentOrderAdded(String folio) {
    return 'Se agregaron las partidas del pedido $folio.';
  }

  @override
  String get fiscalDocumentAddProductTitle => 'Agregar producto';

  @override
  String get fiscalDocumentAddProductPicker => 'Producto';

  @override
  String get fiscalDocumentProductAdded => 'Producto agregado.';

  @override
  String get fiscalDocumentAddRelationTitle => 'Agregar relación';

  @override
  String get fiscalDocumentRelationType => 'Tipo de relación';

  @override
  String get fiscalDocumentRelationDocument => 'Documento';

  @override
  String get fiscalDocumentRelationSearch => 'Buscar documento';

  @override
  String get fiscalDocumentRelationEmpty =>
      'No hay documentos que se puedan relacionar.';

  @override
  String get fiscalDocumentRelationAdded => 'Relación agregada.';

  @override
  String get fiscalDocumentRemoveRelationTitle => 'Quitar relación';

  @override
  String get fiscalDocumentRemoveRelationBody =>
      '¿Quitar este documento relacionado?';

  @override
  String get fiscalDocumentConfirmTitle => 'Confirmar factura';

  @override
  String fiscalDocumentConfirmBody(String series) {
    return 'Se asignará el siguiente folio de la serie $series y se sellará la factura. Después solo podrá reabrirse mientras no esté timbrada.';
  }

  @override
  String fiscalDocumentConfirmed(String folio) {
    return 'Factura $folio sellada.';
  }

  @override
  String get fiscalDocumentReopenTitle => 'Reabrir factura';

  @override
  String fiscalDocumentReopenBody(String folio) {
    return 'La factura vuelve a borrador y conserva el folio $folio. El sello se descarta.';
  }

  @override
  String fiscalDocumentReopened(String folio) {
    return 'Factura $folio reabierta.';
  }

  @override
  String get fiscalDocumentXmlSaved => 'XML guardado.';

  @override
  String get fiscalDocumentUnknownResult =>
      'No sabemos si se completó: se perdió la conexión. El documento se actualizó.';

  @override
  String get apiErrorFiscalDocumentNotIssued =>
      'Este documento aún no se timbra, así que no tiene PDF ni XML.';

  @override
  String apiErrorFiscalDocumentVersionNotPrintable(String version) {
    return 'Este documento es de la versión $version del CFDI y no se puede imprimir.';
  }

  @override
  String get apiErrorFiscalDocumentNotStamped =>
      'Este documento no está timbrado, así que no se puede generar su PDF.';

  @override
  String get apiErrorFiscalDocumentXmlUnavailable =>
      'El XML de este documento no está disponible.';

  @override
  String get apiErrorFiscalDocumentIssuerHasNoSeries =>
      'El emisor no tiene una serie para este tipo de documento. Créala en el emisor e inténtalo de nuevo.';

  @override
  String apiErrorFiscalDocumentSeriesNotOfType(String batch) {
    return 'La serie $batch no es de este tipo de documento.';
  }

  @override
  String get apiErrorFiscalDocumentRecipientNotLinked =>
      'Ese RFC no está registrado en el cliente.';

  @override
  String get apiErrorFiscalDocumentFieldNotForType =>
      'Hay campos que no aplican a este tipo de documento.';

  @override
  String get apiErrorFiscalDocumentUnknownFacility =>
      'La sucursal elegida no existe.';

  @override
  String get apiErrorFiscalDocumentSeriesLocked =>
      'La serie no se puede cambiar porque la factura ya tiene folio.';

  @override
  String apiErrorFiscalDocumentUnknownUsage(String usage) {
    return 'El uso del CFDI $usage no existe.';
  }

  @override
  String get apiErrorFiscalDocumentIssueDateOutOfRange =>
      'La fecha de emisión debe estar en las últimas 72 horas y no ser futura.';

  @override
  String get apiErrorFiscalDocumentNotDraft =>
      'Esta factura ya no es borrador y no se puede modificar.';

  @override
  String get apiErrorFiscalDocumentNotSealed =>
      'Solo se puede reabrir una factura sellada que aún no esté timbrada.';

  @override
  String get apiErrorFiscalDocumentTypeNotSupported =>
      'Este tipo de documento no se puede modificar aquí.';

  @override
  String get apiErrorFiscalDocumentOrderNotInvoiceable =>
      'Ese pedido no se puede facturar: debe estar completado y no cancelado.';

  @override
  String get apiErrorFiscalDocumentNoInvoiceableLines =>
      'Ese pedido ya no tiene partidas por facturar.';

  @override
  String get apiErrorFiscalDocumentProductUnpriced =>
      'El producto no está en la lista de precios del cliente.';

  @override
  String apiErrorFiscalDocumentQuantityExceedsInvoiceable(String remaining) {
    return 'Solo quedan $remaining por facturar de esta partida del pedido.';
  }

  @override
  String apiErrorFiscalDocumentQuantityExceedsInvoiceableLine(
    String line,
    String remaining,
  ) {
    return 'Partida $line: solo quedan $remaining por facturar de esta partida del pedido.';
  }

  @override
  String get apiErrorFiscalDocumentRelationNotAllowed =>
      'Ese documento no se puede relacionar con esta factura: debe tener el mismo emisor y receptor y el estado que pide el tipo de relación.';

  @override
  String get apiErrorFiscalDocumentAlreadyRelated =>
      'Ese documento ya está relacionado con esta factura.';

  @override
  String get apiErrorFiscalDocumentRelationTypesMixed =>
      'Una factura solo puede tener relaciones de un mismo tipo.';

  @override
  String get apiErrorFiscalDocumentNoLines => 'La factura no tiene partidas.';

  @override
  String apiErrorFiscalDocumentLineMissingSatKey(String line) {
    return 'Partida $line: falta la clave SAT del producto o la unidad.';
  }

  @override
  String apiErrorFiscalDocumentLineQuantityNotPositive(String line) {
    return 'Partida $line: la cantidad debe ser mayor que 0.';
  }

  @override
  String get apiErrorFiscalDocumentRecipientIncomplete =>
      'Faltan datos fiscales del receptor (nombre, régimen o código postal).';

  @override
  String get apiErrorFiscalDocumentNoValidCertificate =>
      'El emisor no tiene un certificado vigente para sellar.';

  @override
  String apiErrorFiscalDocumentSeriesMissing(String batch) {
    return 'La serie $batch ya no existe.';
  }

  @override
  String get apiErrorFiscalDocumentCertificateCannotSign =>
      'El certificado del emisor no puede firmar este documento.';

  @override
  String get apiValidationFiscalDocumentTaxRateInvalid =>
      'La tasa de IVA debe ser 16 %, 0 % o exento.';

  @override
  String get apiValidationFiscalDocumentPaymentFormUnknown =>
      'La forma de pago no es válida.';

  @override
  String apiResourceFiscalDocumentLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partidas de factura',
      one: 'partida de factura',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderFiscalDocumentLine => 'feminine';

  @override
  String apiResourceFiscalDocumentRelation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'documentos relacionados',
      one: 'documento relacionado',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderFiscalDocumentRelation => 'masculine';

  @override
  String fiscalDocumentAddOrderIntro(String customer) {
    return 'Pedidos completados de $customer. Elige el que quieres facturar.';
  }

  @override
  String get fiscalDocumentAddOrderColFolio => 'Pedido';

  @override
  String get fiscalDocumentAddOrderColDate => 'Fecha';

  @override
  String get fiscalDocumentAddOrderColTotal => 'Total';

  @override
  String get fiscalDocumentAddOrderLoadMore => 'Ver más';

  @override
  String get fiscalDocumentHeaderIssuedOnConfirm => 'Al confirmar';

  @override
  String get fiscalDocumentHeaderPickIssued => 'Elegir fecha y hora';

  @override
  String get fiscalDocumentHeaderReferenceTooLong =>
      'La referencia puede tener hasta 25 caracteres.';

  @override
  String get fiscalDocumentHeaderCommentTooLong =>
      'Las notas pueden tener hasta 1000 caracteres.';

  @override
  String get fiscalDocumentHeaderTermsPue => 'PUE';

  @override
  String get fiscalDocumentHeaderTermsPpd => 'PPD';

  @override
  String get fiscalDocumentLineEditTooltip => 'Editar partida';

  @override
  String get fiscalDocumentLineRemoveTooltip => 'Quitar partida';

  @override
  String get fiscalDocumentRelationRemoveTooltip => 'Quitar relación';

  @override
  String get navInventoryGroup => 'Inventario';

  @override
  String get navInventoryReceipts => 'Entradas de almacén';

  @override
  String inventoryReceiptTitle(String folio) {
    return 'Entrada $folio';
  }

  @override
  String inventoryReceiptTitleDraft(String id) {
    return 'Entrada · Borrador #$id';
  }

  @override
  String inventoryDocumentDraftFolio(String id) {
    return 'Borrador #$id';
  }

  @override
  String get inventoryDocumentStatusDraft => 'Borrador';

  @override
  String get inventoryDocumentStatusCompleted => 'Confirmada';

  @override
  String get inventoryDocumentStatusCancelled => 'Cancelada';

  @override
  String get inventoryReceiptColFolio => 'Folio';

  @override
  String get inventoryReceiptColWarehouse => 'Almacén';

  @override
  String get inventoryReceiptColFacility => 'Sucursal';

  @override
  String get inventoryReceiptColPurchaseOrder => 'Orden de compra';

  @override
  String get inventoryReceiptColStatus => 'Estado';

  @override
  String get inventoryReceiptColCreator => 'Creado por';

  @override
  String get inventoryReceiptColDate => 'Fecha';

  @override
  String get inventoryReceiptFacetStatus => 'Estado';

  @override
  String get inventoryReceiptFacetWarehouse => 'Almacén';

  @override
  String get inventoryReceiptFacetAll => 'Todos';

  @override
  String get inventoryReceiptEmpty => 'No hay entradas de almacén';

  @override
  String get inventoryReceiptFilteredEmpty =>
      'Ninguna entrada coincide con los filtros.';

  @override
  String get inventoryReceiptFactStatus => 'Estado';

  @override
  String get inventoryReceiptFactFolio => 'Folio';

  @override
  String get inventoryReceiptFactWarehouse => 'Almacén';

  @override
  String get inventoryReceiptFactFacility => 'Sucursal';

  @override
  String get inventoryReceiptFactPurchaseOrder => 'Orden de compra';

  @override
  String get inventoryReceiptFactComment => 'Notas';

  @override
  String get inventoryReceiptFactCreatedBy => 'Creado por';

  @override
  String get inventoryReceiptFactModifiedBy => 'Modificado por';

  @override
  String get inventoryReceiptLinesTitle => 'Partidas';

  @override
  String get inventoryReceiptLineColCode => 'Código';

  @override
  String get inventoryReceiptLineColProduct => 'Producto';

  @override
  String get inventoryReceiptLineColQuantity => 'Cantidad recibida';

  @override
  String get inventoryReceiptLineColOrdered => 'Ordenado';

  @override
  String get inventoryReceiptLineColElsewhere => 'Recibido en otras entradas';

  @override
  String get inventoryReceiptLinesEmpty => 'Agrega los productos recibidos.';

  @override
  String get inventoryDocumentNoFacility =>
      'Tu usuario no tiene una sucursal asignada.';

  @override
  String get inventoryReceiptNewAction => 'Nueva entrada';

  @override
  String get inventoryReceiptEditHeader => 'Editar encabezado';

  @override
  String get inventoryReceiptAddProduct => 'Agregar producto';

  @override
  String get inventoryReceiptConfirm => 'Confirmar';

  @override
  String get inventoryReceiptCancel => 'Cancelar';

  @override
  String get inventoryReceiptComplementary => 'Entrada complementaria';

  @override
  String get inventoryReceiptLineEditTooltip => 'Editar cantidad';

  @override
  String get inventoryReceiptLineRemoveTooltip => 'Quitar partida';

  @override
  String get inventoryReceiptNewTitle => 'Nueva entrada';

  @override
  String get inventoryReceiptNewSubmit => 'Crear';

  @override
  String get inventoryReceiptEditHeaderTitle => 'Editar encabezado';

  @override
  String get inventoryReceiptFieldWarehouse => 'Almacén';

  @override
  String get inventoryReceiptFieldComment => 'Notas';

  @override
  String get inventoryReceiptFieldProduct => 'Producto';

  @override
  String get inventoryReceiptFieldQuantity => 'Cantidad';

  @override
  String get inventoryReceiptWarehouseFixed => 'Fijo: orden de compra';

  @override
  String get inventoryReceiptAddProductTitle => 'Agregar producto';

  @override
  String get inventoryReceiptAddProductSubmit => 'Agregar';

  @override
  String get inventoryReceiptLineQuantityTitle => 'Cantidad de la partida';

  @override
  String inventoryReceiptRemoveTitle(String product) {
    return '¿Quitar $product de la entrada?';
  }

  @override
  String get inventoryReceiptRemoveBody =>
      'Se elimina la partida del borrador.';

  @override
  String get inventoryReceiptRemoveAction => 'Quitar';

  @override
  String get inventoryReceiptConfirmTitle => 'Confirmar entrada';

  @override
  String get inventoryReceiptConfirmBody =>
      'Confirmar la entrada asigna un folio y agrega las existencias al almacén. Después ya no se puede editar.';

  @override
  String get inventoryReceiptConfirmAction => 'Confirmar';

  @override
  String get inventoryReceiptBack => 'Volver';

  @override
  String get inventoryReceiptCancelTitle => 'Cancelar entrada';

  @override
  String get inventoryReceiptCancelDraftBody =>
      'Cancelar el borrador no agrega existencias al almacén.';

  @override
  String get inventoryReceiptCancelCompletedBody =>
      'Cancelar la entrada retira del almacén las existencias que agregó.';

  @override
  String get inventoryReceiptCancelAction => 'Cancelar entrada';

  @override
  String inventoryReceiptOverReceipt(
    String code,
    String excess,
    String received,
    String ordered,
  ) {
    return 'Se recibió de más $code: $excess (recibido $received de $ordered ordenado)';
  }

  @override
  String get inventoryReceiptCostNotice =>
      'Se actualizaron los costos con excepciones.';

  @override
  String get inventoryReceiptCostNoticeClose => 'Cerrar';

  @override
  String inventoryReceiptCostZeroPrice(String code) {
    return '$code tiene precio 0; su costo no cambió.';
  }

  @override
  String inventoryReceiptCostNotRestored(String code, String receipt) {
    return 'No se restauró el costo de $code: lo cambió después la entrada $receipt.';
  }

  @override
  String inventoryReceiptRefusalProduct(String code) {
    return 'Producto: $code';
  }

  @override
  String get inventoryReceiptQuantityInvalid =>
      'Escribe una cantidad mayor que 0.';

  @override
  String get inventoryReceiptBackToList => 'Volver a entradas de almacén';

  @override
  String get navInventoryIssues => 'Salidas de almacén';

  @override
  String inventoryIssueTitle(String folio) {
    return 'Salida $folio';
  }

  @override
  String inventoryIssueTitleDraft(String id) {
    return 'Salida · Borrador #$id';
  }

  @override
  String get inventoryIssueColFolio => 'Folio';

  @override
  String get inventoryIssueColWarehouse => 'Almacén';

  @override
  String get inventoryIssueColFacility => 'Sucursal';

  @override
  String get inventoryIssueColStatus => 'Estado';

  @override
  String get inventoryIssueColCreator => 'Creado por';

  @override
  String get inventoryIssueColDate => 'Fecha';

  @override
  String get inventoryIssueFacetStatus => 'Estado';

  @override
  String get inventoryIssueFacetWarehouse => 'Almacén';

  @override
  String get inventoryIssueFacetAll => 'Todos';

  @override
  String get inventoryIssueEmpty => 'No hay salidas de almacén';

  @override
  String get inventoryIssueFilteredEmpty =>
      'Ninguna salida coincide con los filtros.';

  @override
  String get inventoryIssueFactStatus => 'Estado';

  @override
  String get inventoryIssueFactFolio => 'Folio';

  @override
  String get inventoryIssueFactWarehouse => 'Almacén';

  @override
  String get inventoryIssueFactFacility => 'Sucursal';

  @override
  String inventoryIssueFactSupplierReturn(String id) {
    return 'Devolución a proveedor #$id';
  }

  @override
  String get inventoryIssueFactComment => 'Motivo / notas';

  @override
  String get inventoryIssueFactCreatedBy => 'Creado por';

  @override
  String get inventoryIssueFactModifiedBy => 'Modificado por';

  @override
  String get inventoryIssueLinesTitle => 'Partidas';

  @override
  String get inventoryIssueLineColCode => 'Código';

  @override
  String get inventoryIssueLineColProduct => 'Producto';

  @override
  String get inventoryIssueLineColQuantity => 'Cantidad';

  @override
  String get inventoryIssueLinesEmpty =>
      'Agrega los productos que salen del almacén.';

  @override
  String get inventoryIssueNewAction => 'Nueva salida';

  @override
  String get inventoryIssueEditHeader => 'Editar encabezado';

  @override
  String get inventoryIssueAddProduct => 'Agregar producto';

  @override
  String get inventoryIssueConfirm => 'Confirmar';

  @override
  String get inventoryIssueCancel => 'Cancelar';

  @override
  String get inventoryIssueLineEditTooltip => 'Editar cantidad';

  @override
  String get inventoryIssueLineRemoveTooltip => 'Quitar partida';

  @override
  String get inventoryIssueNewTitle => 'Nueva salida';

  @override
  String get inventoryIssueNewSubmit => 'Crear';

  @override
  String get inventoryIssueEditHeaderTitle => 'Editar encabezado';

  @override
  String get inventoryIssueFieldWarehouse => 'Almacén';

  @override
  String get inventoryIssueFieldComment => 'Motivo / notas';

  @override
  String get inventoryIssueFieldCommentHint =>
      'p. ej. merma, daño, consumo interno';

  @override
  String get inventoryIssueFieldProduct => 'Producto';

  @override
  String get inventoryIssueFieldQuantity => 'Cantidad';

  @override
  String get inventoryIssueAddProductTitle => 'Agregar producto';

  @override
  String get inventoryIssueAddProductSubmit => 'Agregar';

  @override
  String get inventoryIssueLineQuantityTitle => 'Cantidad de la partida';

  @override
  String inventoryIssueRemoveTitle(String product) {
    return '¿Quitar $product de la salida?';
  }

  @override
  String get inventoryIssueRemoveBody => 'Se elimina la partida del borrador.';

  @override
  String get inventoryIssueRemoveAction => 'Quitar';

  @override
  String get inventoryIssueConfirmTitle => 'Confirmar salida';

  @override
  String inventoryIssueConfirmBody(String warehouse) {
    return 'Confirmar asigna un folio y retira las existencias de $warehouse. Después ya no se puede editar.';
  }

  @override
  String get inventoryIssueConfirmAction => 'Confirmar';

  @override
  String get inventoryIssueCancelTitle => 'Cancelar salida';

  @override
  String get inventoryIssueCancelDraftBody => 'Cancelar el borrador';

  @override
  String inventoryIssueCancelCompletedBody(String folio, String warehouse) {
    return 'Cancelar la salida $folio regresa a $warehouse las existencias que retiró.';
  }

  @override
  String get inventoryIssueCancelAction => 'Cancelar salida';

  @override
  String inventoryIssueRefusalProductWarehouse(String code, String warehouse) {
    return 'Producto: $code · Almacén: $warehouse';
  }

  @override
  String get inventoryIssueQuantityInvalid =>
      'Escribe una cantidad mayor que 0.';

  @override
  String get inventoryIssueBackToList => 'Volver a salidas de almacén';

  @override
  String get inventoryIssueBack => 'Volver';

  @override
  String get apiErrorInventoryReceiptWarehouseFixed =>
      'El almacén de una entrada de orden de compra no se puede cambiar.';

  @override
  String get apiErrorInventoryReceiptComplementaryNoPurchaseOrder =>
      'La entrada no está ligada a una orden de compra.';

  @override
  String get apiErrorInventoryReceiptComplementaryPurchaseOrderCancelled =>
      'La orden de compra está cancelada.';

  @override
  String get apiErrorInventoryReceiptComplementaryPurchaseOrderNotCompleted =>
      'La orden de compra aún no está completada.';

  @override
  String get apiErrorInventoryReceiptComplementaryPurchaseOrderFullyReceived =>
      'La orden de compra ya se recibió completa en este almacén.';

  @override
  String get apiErrorInventoryReceiptComplementaryUnavailable =>
      'No se puede crear una entrada complementaria para esta entrada.';

  @override
  String apiErrorInventoryDocumentInsufficientStock(
    String requested,
    String available,
  ) {
    return 'No hay existencias suficientes: se requieren $requested y hay $available disponibles.';
  }

  @override
  String apiErrorInventoryDocumentNoLines(String gender, String resource) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine': 'La $resource no tiene partidas.',
      'other': 'El $resource no tiene partidas.',
    });
    return '$_temp0';
  }

  @override
  String apiErrorInventoryDocumentLineWithoutQuantity(String product) {
    return 'La partida $product no tiene cantidad.';
  }

  @override
  String apiErrorInventoryDocumentAlreadyCancelled(
    String gender,
    String resource,
  ) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine': 'La $resource ya está cancelada.',
      'other': 'El $resource ya está cancelado.',
    });
    return '$_temp0';
  }

  @override
  String apiErrorProductNotStockable(String product) {
    return 'El producto $product no maneja existencias.';
  }

  @override
  String get apiErrorFacilityNoInTransitLocation =>
      'La sucursal no tiene almacén de tránsito configurado.';

  @override
  String get apiErrorStatusFilterUnsupported =>
      'El filtro de estado no es válido.';

  @override
  String get apiErrorInventoryTransferSameWarehouse =>
      'El almacén de origen y el de destino deben ser distintos.';

  @override
  String get apiErrorInventoryTransferNotInTransit =>
      'El traspaso no está en tránsito.';

  @override
  String apiErrorInventoryTransferOverReceived(
    String product_code,
    String received,
    String outstanding,
  ) {
    return '$product_code: se intentan recibir $received y solo hay $outstanding pendientes.';
  }

  @override
  String get apiErrorInventoryTransferLineRepeated =>
      'Una partida se recibe más de una vez.';

  @override
  String get apiErrorSalesOrderNotConfirmed =>
      'El pedido no está confirmado o está cancelado.';

  @override
  String get apiValidationInventoryTransferDuplicateLine =>
      'Una partida se recibe más de una vez.';

  @override
  String get navInventoryTransfers => 'Traspasos';

  @override
  String inventoryTransferTitle(String folio) {
    return 'Traspaso $folio';
  }

  @override
  String inventoryTransferTitleDraft(String id) {
    return 'Traspaso · Borrador #$id';
  }

  @override
  String get inventoryTransferStatusDraft => 'Borrador';

  @override
  String get inventoryTransferStatusInTransit => 'En tránsito';

  @override
  String get inventoryTransferStatusReceived => 'Recibido';

  @override
  String get inventoryTransferStatusCancelled => 'Cancelado';

  @override
  String get inventoryTransferColFolio => 'Folio';

  @override
  String get inventoryTransferColSource => 'Origen';

  @override
  String get inventoryTransferColDestination => 'Destino';

  @override
  String get inventoryTransferColFacility => 'Sucursal';

  @override
  String get inventoryTransferColStatus => 'Estado';

  @override
  String get inventoryTransferColCreator => 'Creado por';

  @override
  String get inventoryTransferColDate => 'Fecha';

  @override
  String get inventoryTransferFacetStatus => 'Estado';

  @override
  String get inventoryTransferFacetWarehouse => 'Almacén (origen o destino)';

  @override
  String get inventoryTransferFacetAll => 'Todos';

  @override
  String get inventoryTransferEmpty => 'No hay traspasos';

  @override
  String get inventoryTransferFilteredEmpty =>
      'Ningún traspaso coincide con los filtros.';

  @override
  String get inventoryTransferInTransitAction => 'En tránsito';

  @override
  String get inventoryTransferNewAction => 'Nuevo traspaso';

  @override
  String get inventoryTransferFactStatus => 'Estado';

  @override
  String get inventoryTransferFactFolio => 'Folio';

  @override
  String get inventoryTransferFactSource => 'Origen';

  @override
  String get inventoryTransferFactDestination => 'Destino';

  @override
  String get inventoryTransferFactFacility => 'Sucursal';

  @override
  String get inventoryTransferFactNotes => 'Notas';

  @override
  String get inventoryTransferFactCreatedBy => 'Creado por';

  @override
  String get inventoryTransferFactModifiedBy => 'Modificado por';

  @override
  String get inventoryTransferLinesTitle => 'Partidas';

  @override
  String get inventoryTransferLineColCode => 'Código';

  @override
  String get inventoryTransferLineColProduct => 'Producto';

  @override
  String get inventoryTransferLineColQuantity => 'Cantidad';

  @override
  String get inventoryTransferLineColSent => 'Enviado';

  @override
  String get inventoryTransferLineColReceived => 'Recibido';

  @override
  String get inventoryTransferLineColOutstanding => 'Pendiente';

  @override
  String get inventoryTransferLinesEmpty =>
      'Agrega los productos que se van a traspasar.';

  @override
  String get inventoryTransferEditHeader => 'Editar encabezado';

  @override
  String get inventoryTransferAddProduct => 'Agregar producto';

  @override
  String get inventoryTransferAddFromOrder => 'Agregar desde pedido';

  @override
  String get inventoryTransferDispatch => 'Despachar';

  @override
  String get inventoryTransferReceive => 'Recibir';

  @override
  String get inventoryTransferClose => 'Cerrar pendiente';

  @override
  String get inventoryTransferCancel => 'Cancelar';

  @override
  String get inventoryTransferLineEditTooltip => 'Editar cantidad';

  @override
  String get inventoryTransferLineRemoveTooltip => 'Quitar partida';

  @override
  String get inventoryTransferNewTitle => 'Nuevo traspaso';

  @override
  String get inventoryTransferNewSubmit => 'Crear';

  @override
  String get inventoryTransferEditHeaderTitle => 'Editar encabezado';

  @override
  String get inventoryTransferFieldSource => 'Origen';

  @override
  String get inventoryTransferFieldDestination => 'Destino';

  @override
  String get inventoryTransferFieldNotes => 'Notas';

  @override
  String get inventoryTransferFieldProduct => 'Producto';

  @override
  String get inventoryTransferFieldQuantity => 'Cantidad';

  @override
  String get inventoryTransferAddProductTitle => 'Agregar producto';

  @override
  String get inventoryTransferAddProductSubmit => 'Agregar';

  @override
  String get inventoryTransferLineQuantityTitle => 'Cantidad de la partida';

  @override
  String get inventoryTransferQuantityInvalid =>
      'Escribe una cantidad mayor que 0.';

  @override
  String inventoryTransferRemoveTitle(String product) {
    return '¿Quitar $product del traspaso?';
  }

  @override
  String get inventoryTransferRemoveBody =>
      'La partida se elimina del borrador.';

  @override
  String get inventoryTransferRemoveAction => 'Quitar';

  @override
  String get inventoryTransferDispatchTitle => 'Despachar traspaso';

  @override
  String inventoryTransferDispatchBody(String source, String destination) {
    return 'Despachar asigna un folio y retira las existencias de $source. Quedan en tránsito hasta que $destination las reciba. Después ya no se puede editar.';
  }

  @override
  String get inventoryTransferDispatchAction => 'Despachar';

  @override
  String get inventoryTransferCloseTitle => 'Cerrar pendiente';

  @override
  String inventoryTransferCloseBody(int count, String source) {
    return 'Lo pendiente ($count partidas) regresa a $source y el traspaso queda como Recibido. Si se perdió, regístralo después con una salida de almacén.';
  }

  @override
  String get inventoryTransferCloseAction => 'Cerrar pendiente';

  @override
  String get inventoryTransferCancelTitle => 'Cancelar traspaso';

  @override
  String get inventoryTransferCancelDraftBody => 'Cancelar el borrador';

  @override
  String inventoryTransferCancelDispatchedBody(String folio, String source) {
    return 'Cancelar el traspaso $folio regresa a $source lo que está en tránsito.';
  }

  @override
  String inventoryTransferCancelDispatchedReceivedBody(
    String folio,
    String source,
    String destination,
  ) {
    return 'Cancelar el traspaso $folio regresa a $source lo que está en tránsito y lo que $destination ya recibió.';
  }

  @override
  String get inventoryTransferCancelAction => 'Cancelar traspaso';

  @override
  String get inventoryTransferBack => 'Volver';

  @override
  String inventoryTransferRefusalProductWarehouse(
    String code,
    String warehouse,
  ) {
    return 'Producto: $code · Almacén: $warehouse';
  }

  @override
  String get inventoryTransferBackToList => 'Volver a traspasos';

  @override
  String inventoryTransferReceiveTitle(String folio) {
    return 'Recibir traspaso $folio';
  }

  @override
  String get inventoryTransferReceiveHint =>
      'Deja en 0 lo que no llegó. Lo pendiente se puede recibir después.';

  @override
  String get inventoryTransferReceiveColReceive => 'Recibir';

  @override
  String inventoryTransferReceiveMax(String outstanding) {
    return 'Máximo $outstanding';
  }

  @override
  String get inventoryTransferReceiveSubmit => 'Recibir';

  @override
  String get inventoryTransferReceiveInvalid =>
      'Escribe una cantidad de 0 o más.';

  @override
  String get inventoryTransferFromOrderTitle => 'Agregar desde pedido';

  @override
  String get inventoryTransferFromOrderField => 'Pedido';

  @override
  String inventoryTransferFromOrderOption(
    String folio,
    String customer,
    String date,
  ) {
    return '$folio · $customer · $date';
  }

  @override
  String get inventoryTransferFromOrderSubmit => 'Agregar';

  @override
  String inventoryTransferFromOrderAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se agregaron $count productos al traspaso.',
      one: 'Se agregó 1 producto al traspaso.',
    );
    return '$_temp0 Los que ya estaban no se modificaron.';
  }

  @override
  String get inventoryTransferFromOrderNone =>
      'Los productos del pedido ya estaban en el traspaso.';

  @override
  String get inventoryTransferInTransitTitle => 'En tránsito';

  @override
  String inventoryTransferInTransitTitleFacility(String facility) {
    return 'En tránsito · $facility';
  }

  @override
  String get inventoryTransferInTransitFacilityField => 'Sucursal';

  @override
  String get inventoryTransferInTransitMyFacility => 'Mi sucursal';

  @override
  String get inventoryTransferInTransitSelectFacility =>
      'Selecciona una sucursal.';

  @override
  String get inventoryTransferInTransitByProduct => 'Por producto';

  @override
  String get inventoryTransferInTransitByTransfer => 'Por traspaso';

  @override
  String get inventoryTransferInTransitEmpty => 'No hay mercancía en tránsito.';

  @override
  String get apiErrorInventoryCountBatchInvalid =>
      'Algunos productos de la lista no se pueden registrar. Revisa los renglones marcados.';

  @override
  String get apiErrorInventoryCountConfirmedCannotCancel =>
      'Un conteo confirmado no se puede cancelar. Corrígelo con un conteo nuevo.';

  @override
  String get apiErrorInventoryCountLineProductUnknown =>
      'El producto no existe.';

  @override
  String get apiErrorInventoryCountLineNotStockable =>
      'El producto no es inventariable.';

  @override
  String get apiErrorInventoryCountLineRepeated =>
      'El producto está repetido en la lista.';

  @override
  String get apiErrorInventoryCountLineProductReference =>
      'Indica el producto por su id o por su código, no ambos.';

  @override
  String apiResourceInventoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'conteos',
      one: 'conteo',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderInventoryCount => 'masculine';

  @override
  String get navInventoryCounts => 'Conteos físicos';

  @override
  String get inventoryCountStatusDraft => 'Borrador';

  @override
  String get inventoryCountStatusCompleted => 'Confirmado';

  @override
  String get inventoryCountStatusCancelled => 'Cancelado';

  @override
  String get inventoryCountColFolio => 'Folio';

  @override
  String get inventoryCountColWarehouse => 'Almacén';

  @override
  String get inventoryCountColFacility => 'Sucursal';

  @override
  String get inventoryCountColStatus => 'Estado';

  @override
  String get inventoryCountColCreatedBy => 'Creado por';

  @override
  String get inventoryCountColDate => 'Fecha';

  @override
  String get inventoryCountFilterStatus => 'Estado';

  @override
  String get inventoryCountFilterWarehouse => 'Almacén';

  @override
  String get inventoryCountFilterAll => 'Todos';

  @override
  String get inventoryCountListEmpty => 'No hay conteos físicos';

  @override
  String inventoryCountDraftFolio(String id) {
    return 'Borrador #$id';
  }

  @override
  String inventoryCountTitleDraft(String id) {
    return 'Conteo · Borrador #$id';
  }

  @override
  String inventoryCountTitle(String folio) {
    return 'Conteo $folio';
  }

  @override
  String get inventoryCountFactComment => 'Comentario';

  @override
  String get inventoryCountFactLines => 'Partidas';

  @override
  String get inventoryCountLineColCode => 'Código';

  @override
  String get inventoryCountLineColProduct => 'Producto';

  @override
  String get inventoryCountLineColCounted => 'Contado';

  @override
  String get inventoryCountLineColExpected => 'Esperado';

  @override
  String get inventoryCountLineColDifference => 'Diferencia';

  @override
  String get inventoryCountLinesSearchHint => 'Buscar por código o nombre';

  @override
  String get inventoryCountDraftEmpty =>
      'Registra lo que contaste. Las existencias esperadas se muestran al confirmar.';

  @override
  String get inventoryCountQuickEntryTitle => 'Captura rápida';

  @override
  String get inventoryCountQuickEntryCode => 'Código';

  @override
  String get inventoryCountQuickEntryQuantity => 'Cantidad';

  @override
  String get inventoryCountQuickEntrySubmit => 'Registrar';

  @override
  String inventoryCountQuickEntryFeedback(
    String code,
    String name,
    String newQty,
  ) {
    return '$code $name: $newQty';
  }

  @override
  String inventoryCountQuickEntryFeedbackReplaced(
    String code,
    String name,
    String oldQty,
    String newQty,
  ) {
    return '$code $name: $oldQty → $newQty (reemplazada)';
  }

  @override
  String get inventoryCountActionNew => 'Nuevo conteo';

  @override
  String get inventoryCountActionEditHeader => 'Editar encabezado';

  @override
  String get inventoryCountActionPaste => 'Pegar lista';

  @override
  String get inventoryCountActionAddProduct => 'Agregar producto';

  @override
  String get inventoryCountActionConfirm => 'Confirmar';

  @override
  String get inventoryCountActionCancel => 'Cancelar';

  @override
  String get inventoryCountDialogNewTitle => 'Nuevo conteo';

  @override
  String get inventoryCountDialogEditTitle => 'Editar encabezado';

  @override
  String get inventoryCountDialogAddTitle => 'Agregar producto';

  @override
  String get inventoryCountDialogQuantityTitle => 'Cantidad contada';

  @override
  String get inventoryCountDialogRemoveTitle => 'Quitar partida';

  @override
  String inventoryCountDialogRemoveBody(String name) {
    return '¿Quitar $name del conteo?';
  }

  @override
  String get inventoryCountDialogPasteTitle => 'Pegar lista';

  @override
  String get inventoryCountDialogConfirmTitle => 'Confirmar conteo';

  @override
  String get inventoryCountDialogCancelTitle => 'Cancelar borrador';

  @override
  String get inventoryCountFieldWarehouse => 'Almacén';

  @override
  String get inventoryCountFieldComment => 'Comentario';

  @override
  String get inventoryCountFieldProduct => 'Producto';

  @override
  String get inventoryCountFieldCounted => 'Contado';

  @override
  String get inventoryCountDialogCreate => 'Crear';

  @override
  String get inventoryCountDialogSave => 'Guardar';

  @override
  String get inventoryCountDialogRecord => 'Registrar';

  @override
  String get inventoryCountDialogBack => 'Volver';

  @override
  String get inventoryCountDialogClose => 'Cerrar';

  @override
  String get inventoryCountDialogCancelDraft => 'Cancelar borrador';

  @override
  String inventoryCountReplaceNote(String qty) {
    return 'Ya contado: $qty. Se reemplazará.';
  }

  @override
  String inventoryCountConfirmBody(String warehouse) {
    return 'Al confirmar, las existencias de $warehouse quedan igual a lo contado y se asigna un folio. Un conteo confirmado no se puede cancelar: se corrige con un conteo nuevo.';
  }

  @override
  String get inventoryCountConfirmIncludeUncounted =>
      'Contar en 0 los productos con existencia que no están en este conteo';

  @override
  String inventoryCountCancelBody(String id) {
    return 'Cancelar el borrador #$id. No se modifica ninguna existencia.';
  }

  @override
  String get inventoryCountPasteInstructions =>
      'Pega dos columnas desde tu hoja de cálculo: código y cantidad.';

  @override
  String inventoryCountPasteSummary(String n, String m) {
    return '$n filas leídas · $m con problemas';
  }

  @override
  String inventoryCountPasteProblemRow(int row, String reason) {
    return 'Fila $row: $reason';
  }

  @override
  String get inventoryCountPasteProblemFieldCount =>
      'hay que separar el código y la cantidad';

  @override
  String get inventoryCountPasteProblemMissingCode => 'falta el código';

  @override
  String get inventoryCountPasteProblemNotANumber =>
      'la cantidad no es un número';

  @override
  String get inventoryCountPasteProblemNegative => 'la cantidad es negativa';

  @override
  String get inventoryCountPasteProblemTooManyDecimals =>
      'la cantidad tiene más de 4 decimales';

  @override
  String get inventoryCountPasteProblemRepeatedCode =>
      'el código está repetido';

  @override
  String get inventoryCountPasteSend => 'Enviar';

  @override
  String get inventoryCountPasteSending => 'Enviando…';

  @override
  String inventoryCountPasteProgress(String sent, String total) {
    return '$sent de $total';
  }

  @override
  String inventoryCountPasteBatch(int k, int n) {
    return 'Lote $k de $n';
  }

  @override
  String inventoryCountPasteStopped(String applied, String total) {
    return 'Se detuvo el envío. Se aplicaron $applied de $total filas.';
  }

  @override
  String inventoryCountPasteRejectedHeading(int k) {
    return 'Códigos rechazados en el lote $k:';
  }

  @override
  String inventoryCountPasteRejectedLine(String code, String reason, int row) {
    return '$code  $reason (fila $row)';
  }

  @override
  String get inventoryCountPasteSafeNote =>
      'Corrige tu lista y pégala de nuevo: las cantidades se reemplazan, no se suman.';

  @override
  String get inventoryCountWarningsTitle => 'Conteo confirmado con avisos';

  @override
  String get inventoryCountWarningsNegativeHeading =>
      'Contado por debajo de lo apartado:';

  @override
  String get inventoryCountWarningsCorrectedHeading =>
      'Corregido también por otro conteo de este almacén:';

  @override
  String inventoryCountWarningsNegativeLine(
    String code,
    String counted,
    String reserved,
    String available,
  ) {
    return '$code  contado $counted · apartado $reserved · disponible $available';
  }

  @override
  String inventoryCountWarningsCorrectedLine(String code, String serial) {
    return '$code  conteo $serial';
  }

  @override
  String get inventoryCountWarningsDismiss => 'Cerrar avisos';

  @override
  String get inventoryCountQuantityInvalid =>
      'Escribe una cantidad de 0 o más, con hasta 4 decimales.';

  @override
  String get inventoryCountLineEditTooltip => 'Editar cantidad';

  @override
  String get inventoryCountLineRemoveTooltip => 'Quitar partida';

  @override
  String get inventoryCountRemoveAction => 'Quitar';

  @override
  String get inventoryCountBackToList => 'Volver a conteos físicos';

  @override
  String get inventoryCountFactModifiedBy => 'Modificado por';

  @override
  String get apiErrorKardexRangeReversed =>
      'La fecha final no puede ser anterior a la inicial.';

  @override
  String apiErrorKardexRangeTooLong(String maxDays) {
    return 'El rango no puede pasar de $maxDays días.';
  }

  @override
  String get navInventoryStock => 'Existencias';

  @override
  String get navInventoryKardex => 'Kardex';

  @override
  String get inventoryStockColumnCode => 'Código';

  @override
  String get inventoryStockColumnProduct => 'Producto';

  @override
  String get inventoryStockColumnOnHand => 'Existencia';

  @override
  String get inventoryStockColumnReserved => 'Apartado';

  @override
  String get inventoryStockColumnAvailable => 'Disponible';

  @override
  String get inventoryStockColumnIncoming => 'Por recibir';

  @override
  String get inventoryStockFilterWarehouse => 'Almacén';

  @override
  String get inventoryStockFilterIncludeZero => 'Mostrar sin existencia';

  @override
  String get inventoryStockSelectionWarehouse => 'Almacén';

  @override
  String get inventoryStockPickWarehousePrompt =>
      'Elige un almacén para ver sus existencias.';

  @override
  String get inventoryStockPickWarehouseButton => 'Elegir almacén';

  @override
  String get inventoryStockEmpty => 'Este almacén no tiene existencias.';

  @override
  String get inventoryStockFilteredEmpty =>
      'Ningún producto coincide con la búsqueda.';

  @override
  String get inventoryStockSearchLabel => 'Buscar por código o nombre';

  @override
  String inventoryStockProductTitle(String code, String name) {
    return 'Existencias · $code $name';
  }

  @override
  String get inventoryStockColumnWarehouse => 'Almacén';

  @override
  String get inventoryStockColumnFacility => 'Sucursal';

  @override
  String get inventoryStockTotalOnHand => 'Existencia';

  @override
  String get inventoryStockTotalReserved => 'Apartado';

  @override
  String get inventoryStockTotalAvailable => 'Disponible';

  @override
  String get inventoryStockTotalIncoming => 'Por recibir';

  @override
  String get inventoryStockViewKardex => 'Ver kardex';

  @override
  String get inventoryStockInTransitHeading => 'En tránsito';

  @override
  String get inventoryStockProductEmpty =>
      'Este producto no tiene existencias en ningún almacén.';

  @override
  String get inventoryKardexFilterProduct => 'Producto';

  @override
  String get inventoryKardexFilterWarehouse => 'Almacén';

  @override
  String get inventoryKardexFilterRange => 'Rango';

  @override
  String get inventoryKardexSelectionProduct => 'Producto';

  @override
  String get inventoryKardexSelectionWarehouse => 'Almacén';

  @override
  String get inventoryKardexSelectionRange => 'Rango';

  @override
  String get inventoryKardexSummaryOpening => 'Saldo inicial';

  @override
  String get inventoryKardexSummaryIn => 'Entradas';

  @override
  String get inventoryKardexSummaryOut => 'Salidas';

  @override
  String get inventoryKardexSummaryClosing => 'Saldo final';

  @override
  String get inventoryKardexColumnDate => 'Fecha';

  @override
  String get inventoryKardexColumnSource => 'Origen';

  @override
  String get inventoryKardexColumnDocument => 'Documento';

  @override
  String get inventoryKardexColumnIn => 'Entrada';

  @override
  String get inventoryKardexColumnOut => 'Salida';

  @override
  String get inventoryKardexColumnBalance => 'Saldo';

  @override
  String get inventoryKardexIncompletePrompt =>
      'Elige un producto y un almacén para ver su kardex.';

  @override
  String get inventoryKardexIncompleteButton => 'Elegir';

  @override
  String get inventoryKardexRangeReversed =>
      'La fecha final no puede ser anterior a la inicial.';

  @override
  String inventoryKardexRangeTooLong(String max) {
    return 'El rango no puede pasar de $max días.';
  }

  @override
  String get inventoryKardexEmpty => 'Sin movimientos en este rango.';

  @override
  String get inventoryKardexSourceSalesOrder => 'Pedido';

  @override
  String get inventoryKardexSourceSalesReturn => 'Devolución';

  @override
  String get inventoryKardexSourceWarehouseIssue => 'Salida de almacén';

  @override
  String get inventoryKardexSourceWarehouseReceipt => 'Entrada de almacén';

  @override
  String get inventoryKardexSourceTransfer => 'Traspaso';

  @override
  String get inventoryKardexSourcePurchaseOrder => 'Orden de compra';

  @override
  String get inventoryKardexSourceLegacyAdjustment =>
      'Ajuste (sistema anterior)';

  @override
  String get inventoryKardexSourceDeliveryItinerary => 'Itinerario de reparto';

  @override
  String get inventoryKardexSourceCount => 'Conteo físico';

  @override
  String get inventoryKardexSourceCounterDelivery => 'Entrega en mostrador';

  @override
  String get inventoryKardexSourceFallback => 'Movimiento';

  @override
  String get catalogViewStockButton => 'Ver existencias';
}
