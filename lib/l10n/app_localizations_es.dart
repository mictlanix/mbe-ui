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
  String get productsAttributesFilterLabel => 'Atributos del producto';

  @override
  String get productsSupplierFilter => 'Proveedor';

  @override
  String get productsSupplierSearchHint => 'Buscar proveedores…';

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
  String get userEmployeeRequiredError => 'El empleado es obligatorio.';

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
  String get productionSiteChildrenNote =>
      'Los sitios de producción solo administran almacenes: no tienen puntos de venta ni cajas.';

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
  String get salesOrderContactLabel => 'Contacto';

  @override
  String get salesOrderShipToLabel => 'Datos de entrega';

  @override
  String get salesOrderRecipientLabel => 'RFC';

  @override
  String get salesOrderCommentLabel => 'Comentario';

  @override
  String get salesOrderMoreDetails => 'Más detalles';

  @override
  String get salesOrderFewerDetails => 'Menos detalles';

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
      'Solo informativo: cubre el monto inicial y los pagos en efectivo de este turno. No considera vales de gastos ni otros movimientos de efectivo de la caja.';

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
    return 'Contado $counted, esperado $expected, diferencia $difference. Estas cifras no se mostrarán de nuevo.';
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
  String get posCustomerCreditLabel => 'Crédito';

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
  String get posOpenSaleUnpaid => 'Por cobrar';

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
}
