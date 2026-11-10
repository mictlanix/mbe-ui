# Contract: Message catalog

The exact scope of spec FR-009 and FR-011: 96 codes, 9 validation types and 42 record nouns. It was measured on 2026-11-09 against mbe-api `227c334` (research R1).

**How the scope was measured**:
1. Load mbe-api's FastAPI route table.
2. List the 182 routes the app calls: 178 through the generated client and 4 through raw `dio`.
3. Build a function-level call graph from each route.
4. Collect every reachable `ErrorCode`.

The per-code evidence is in [code-scope.tsv](code-scope.tsv): verdict, example routes and notes for every code, validation type and resource name. To re-measure for a later spec, repeat these steps against the then-current mbe-api.

**Conventions**:
- ARB key: `apiError` + the code in PascalCase. The `@` description starts with the wire code.
- Placeholders: formatted values are `String`. `{count}`, `{more}` and `{max}` are `int` with ICU `plural` where shown.
- Param kinds: **money** → `fmt.display.currency`; **qty** → `fmt.display.quantity`; **date** → `fmt.display.date`; **text** → as sent; **noun** → `resourceNoun`; **list** → rendered by the case.
- Ids (`customer_id`, `product_id`, `sales_order_line_id`, …) and enum params (`status`, `from`, `to`, `payment_type`) are **not shown**. The screen already gives that context, and enum labels are not localized centrally. A case never needs them, so a missing id never causes a fallback.
- Spanish follows the app's existing register (tú), and its copy is a reviewable draft (spec Assumptions).
- When a code needs a param shown and the param is missing or mistyped, the case returns `null` and the display falls back (FR-004).

## 1. Generic codes (16)

| Code | Shown params | en | es |
|---|---|---|---|
| `auth.administrator_required` | — | Only administrators can do this. | Solo un administrador puede hacer esto. |
| `auth.forbidden` | — | You don't have permission for this action. | No tienes permiso para esta acción. |
| `auth.incorrect_current_password` | — | The current password is incorrect. | La contraseña actual es incorrecta. |
| `auth.invalid_credentials` | — | Invalid username or password. | Usuario o contraseña incorrectos. |
| `auth.not_authenticated` | — | Your session has expired. Sign in again. | Tu sesión expiró. Vuelve a iniciar sesión. |
| `auth.password_change_required` | — | You must change your password before continuing. | Debes cambiar tu contraseña antes de continuar. |
| `auth.recovery_token_invalid` | — | This recovery link is invalid or has expired. Request a new one. | Este enlace de recuperación no es válido o ya expiró. Solicita uno nuevo. |
| `request.malformed` | — | The app sent a request the server couldn't read. Try again. | La app envió una solicitud que el servidor no pudo leer. Inténtalo de nuevo. |
| `request.method_not_allowed` | — | The server doesn't allow this operation here. | El servidor no permite esta operación aquí. |
| `request.route_not_found` | — | The server doesn't offer this function. The app may need an update. | El servidor no ofrece esta función. Puede que la app necesite actualizarse. |
| `resource.already_exists` | resource: noun | That value is already in use. Another {resource} has it. | Ese valor ya está en uso en otro {resource}. (feminine nouns: "otra") |
| `resource.conflict` | — | The change conflicts with existing data. Reload and try again. | El cambio entra en conflicto con datos existentes. Recarga e inténtalo de nuevo. |
| `resource.not_found` | resource: noun | Couldn't find the {resource}. It may have been deleted. | No se encontró el {resource}. Puede que se haya eliminado. (feminine nouns: "la") |
| `resource.still_referenced` | references: list (noun + count), more: count | This record is still in use by {list} and can't be deleted. | Este registro todavía está en uso por {list} y no se puede eliminar. |
| `server.error` | — | Something went wrong on the server. Try again later. | Ocurrió un error en el servidor. Inténtalo de nuevo más tarde. |
| `state.transition_invalid` | — | This record can't change from its current status to the one requested. | Este registro no puede pasar de su estado actual al solicitado. |

**`resource.still_referenced` list**:
- `{list}` is built by the case.
- Each reference renders as its count and the noun in the right plural (`12 orders`, `1 transfer`), with the count formatted by `fmt.display.count`. A kind the app has no noun for renders with the generic noun (`2 records`).
- The items are joined with ", ".
- When `more` is above zero, an `apiReferenceMore(more)` tail follows the items: en "and {more, plural, one{1 other} other{{more} others}}", es "y {more, plural, one{1 más} other{{more} más}}".
- An empty list falls back to `apiErrorResourceStillReferencedGeneric`: en "This record is still in use and can't be deleted." / es "Este registro todavía está en uso y no se puede eliminar."

**`resource.not_found` / `already_exists` without a known noun** use `resourceNoun`'s generic "registro" / "record" (R4).

**Gender**: Spanish nouns differ in gender ("el pedido", "la factura"). The templates that take `{resource}` (`not_found`, `already_exists`, `facility.other_facility`, `product_price.references_not_found`) therefore use ICU `select` on a gender returned with the noun, `apiResourceGender*`: `masculine` | `feminine`. The es templates become:
- `{gender, select, feminine{No se encontró la {resource}.} other{No se encontró el {resource}.}} Puede que se haya eliminado.`
- `{gender, select, feminine{Ese valor ya está en uso en otra {resource}.} other{Ese valor ya está en uso en otro {resource}.}}`

The English template carries the same `select` with identical branches, because every placeholder a translation uses must be declared by the template; English ignores `gender`.

## 2. Area codes (80)

| Code | Shown params | en | es |
|---|---|---|---|
| `cash_session.already_closed` | — | This cash session is already closed. | Esta sesión de caja ya está cerrada. |
| `cash_session.closed` | — | The cash session was closed while you were working. Reload to continue. | La sesión de caja se cerró mientras trabajabas. Recarga para continuar. |
| `cash_session.drawer_busy` | — | That cash drawer already has an open session. | Esa caja ya tiene una sesión abierta. |
| `cash_session.not_closed` | — | The cash session is still open. Close it first. | La sesión de caja sigue abierta. Ciérrala primero. |
| `cash_session.not_open` | — | You need an open cash session for this. | Necesitas una sesión de caja abierta para esto. |
| `cash_session.user_busy` | — | You already have an open session. Close it before opening another. | Ya tienes una sesión abierta. Ciérrala antes de abrir otra. |
| `csd.certificate_not_rsa` | — | The certificate doesn't use an RSA key. It isn't a valid CSD. | El certificado no usa una llave RSA. No es un CSD válido. |
| `csd.certificate_unreadable` | — | The certificate file (.cer) couldn't be read. | No se pudo leer el archivo de certificado (.cer). |
| `csd.key_mismatch` | — | The key (.key) doesn't match the certificate (.cer). | La llave (.key) no corresponde al certificado (.cer). |
| `csd.key_not_encrypted` | — | The key has no password, so it isn't a SAT CSD key. | La llave no tiene contraseña, así que no es una llave de CSD del SAT. |
| `csd.key_not_rsa` | — | The key file doesn't hold an RSA key. | El archivo de llave no contiene una llave RSA. |
| `csd.key_unreadable` | — | The key couldn't be opened. Check the password and the .key file. | No se pudo abrir la llave. Revisa la contraseña y el archivo .key. |
| `customer.credit_hold` | overdue_count: count | This customer has {count, plural, one{1 overdue credit order} other{{count} overdue credit orders}}. Settle them before creating a new credit order. | Este cliente tiene {count, plural, one{1 pedido a crédito vencido} other{{count} pedidos a crédito vencidos}}. Liquídalos antes de crear un nuevo pedido a crédito. |
| `customer.credit_limit_exceeded` | outstanding: money, limit: money | This order would bring the customer's balance to {outstanding}, over their credit limit of {limit}. | Con este pedido el saldo del cliente llegaría a {outstanding}, arriba de su límite de crédito de {limit}. |
| `customer.credit_limit_reached` | outstanding: money, limit: money | The customer owes {outstanding}, which reaches their credit limit of {limit}. They must pay before buying again. | El cliente debe {outstanding} y ya alcanzó su límite de crédito de {limit}. Debe pagar antes de volver a comprar. |
| `customer.default_not_deletable` | — | The general public customer can't be deleted. | El cliente público en general no se puede eliminar. |
| `customer.no_credit_limit` | — | This customer has no credit limit, so they can't buy on credit. | Este cliente no tiene límite de crédito, así que no puede comprar a crédito. |
| `customer.walk_in_no_credit` | — | The general public customer can't buy on credit. | El cliente público en general no puede comprar a crédito. |
| `customer_discount.product_not_found` | — | The product for this discount no longer exists. | El producto de este descuento ya no existe. |
| `delivery_order.line_already_present` | — | That line is already on this delivery order. | Esa partida ya está en esta orden de entrega. |
| `delivery_order.line_not_deliverable` | — | That line can't be delivered on this order: it belongs to another sale or was already delivered. | Esa partida no se puede entregar en esta orden: es de otra venta o ya se entregó. |
| `delivery_order.line_repeated` | — | The same line was added twice. | La misma partida se agregó dos veces. |
| `delivery_order.mixed_not_allowed` | — | A delivery order can't mix delivery and pickup. | Una orden de entrega no puede combinar envío y recolección. |
| `delivery_order.not_editable` | — | This delivery order is no longer a draft and can't be changed. | Esta orden de entrega ya no es borrador y no se puede modificar. |
| `delivery_order.quantity_exceeds_remaining` | remaining: qty, requested: qty | You asked for {requested}, but only {remaining} are left to deliver on that line. | Pediste {requested}, pero en esa partida solo quedan {remaining} por entregar. |
| `delivery_order.reason_required` | — | Enter a reason for this change. | Escribe un motivo para este cambio. |
| `delivery_order.sales_order_fully_delivered` | — | This sale has nothing left to deliver. | Esta venta ya no tiene nada por entregar. |
| `delivery_order.sales_order_not_deliverable` | — | This sale can't be delivered: it isn't completed, or it was cancelled. | Esta venta no se puede entregar: no está completada o se canceló. |
| `delivery_order.sales_order_unpaid` | — | The sale must be paid, or sold on credit, before it can be delivered. | La venta debe estar pagada o ser a crédito antes de poder entregarse. |
| `document.not_editable` | — | This document is completed or cancelled and can't be edited. | Este documento está completado o cancelado y ya no se puede editar. |
| `email.not_configured` | — | Email isn't set up on the server. | El correo no está configurado en el servidor. |
| `email.send_failed` | — | The email couldn't be sent. Try again later. | No se pudo enviar el correo. Inténtalo de nuevo más tarde. |
| `facility.no_dispatch_warehouse` | — | This facility has no warehouse to dispatch from. | Esta sucursal no tiene un almacén desde el cual despachar. |
| `facility.other_facility` | resource: noun | This {resource} belongs to another facility, and you don't have access to other facilities. | Este {resource} pertenece a otra sucursal y no tienes acceso a otras sucursales. |
| `facility.required` | — | Choose a facility. Your user has none assigned. | Elige una sucursal. Tu usuario no tiene una asignada. |
| `image.too_large` | max_bytes: size | The image is too large. The maximum is {max}. | La imagen es demasiado grande. El máximo es {max}. |
| `image.unsupported_format` | — | The file isn't an image the server can read. Try another file. | El archivo no es una imagen que el servidor pueda leer. Prueba con otro archivo. |
| `incidence.reason_required` | — | Enter a reason. | Escribe un motivo. |
| `lock.busy` | — | Someone else is updating this right now. Try again in a moment. | Alguien más está actualizando esto en este momento. Inténtalo de nuevo en un momento. |
| `payment.no_ticket` | — | This kind of payment has no ticket to print. | Este tipo de pago no tiene ticket para imprimir. |
| `point_of_sale.warehouse_facility_mismatch` | — | The warehouse must belong to the same facility as the point of sale. | El almacén debe pertenecer a la misma sucursal que el punto de venta. |
| `price_list.cost_not_assignable` | — | The cost list can't be assigned to a customer or used as a replacement. | La lista de costos no se puede asignar a un cliente ni usar como reemplazo. |
| `price_list.cost_not_deletable` | — | The cost list can't be deleted. | La lista de costos no se puede eliminar. |
| `price_list.cost_read_only` | — | Prices on the cost list can't be edited here. | Los precios de la lista de costos no se pueden editar aquí. |
| `price_list.replace_with_itself` | — | A price list can't be replaced with itself. | Una lista de precios no se puede reemplazar por sí misma. |
| `product.lookup_criteria_required` | — | Type something to search for. | Escribe algo para buscar. |
| `product.lookup_too_many` | max: count | Too many products at once. The maximum is {max}. | Demasiados productos a la vez. El máximo es {max}. |
| `product.merge_with_itself` | — | A product can't be merged into itself. | Un producto no se puede fusionar consigo mismo. |
| `product_price.duplicate_entry` | — | The same price was entered twice. | El mismo precio se capturó dos veces. |
| `product_price.references_not_found` | resource: noun | Some of the {resource} in this change no longer exist. Reload and try again. | Algunos de los {resource} de este cambio ya no existen. Recarga e inténtalo de nuevo. |
| `quote.already_cancelled` | — | This quote is already cancelled. | Esta cotización ya está cancelada. |
| `quote.cancelled` | — | This quote was cancelled and can't be converted. | Esta cotización se canceló y no se puede convertir. |
| `quote.expired` | — | This quote has expired. | Esta cotización ya venció. |
| `quote.not_confirmed` | — | Confirm the quote first. | Primero confirma la cotización. |
| `refund.already_cancelled` | — | This refund is already cancelled. | Esta devolución ya está cancelada. |
| `refund.completed_cannot_cancel` | — | A completed refund is final and can't be cancelled. | Una devolución completada es definitiva y no se puede cancelar. |
| `refund.line_invoiced` | product_code: text, invoice?: text | {product} is on invoice {invoice}. Cancel or adjust that invoice before refunding it. (without invoice: {product} is on a live invoice. …) | {product} está en la factura {invoice}. Cancela o ajusta esa factura antes de devolverlo. (sin factura: {product} está en una factura vigente. …) |
| `refund.no_returnable_lines` | — | Enter a quantity to return on at least one line. | Captura una cantidad a devolver en al menos una partida. |
| `refund.not_confirmed` | — | Only a confirmed refund has a receipt to print. | Solo una devolución confirmada tiene comprobante para imprimir. |
| `refund.nothing_refundable` | — | Nothing on this order is left to refund. | No queda nada por devolver en este pedido. |
| `refund.order_not_completed` | — | This order isn't completed, so it can't be refunded. | Este pedido no está completado, así que no se puede devolver. |
| `refund.order_not_paid` | — | This order isn't paid. Cancel it instead of refunding it. | Este pedido no está pagado. Cancélalo en lugar de devolverlo. |
| `sales_order.already_cancelled` | — | This order is already cancelled. | Este pedido ya está cancelado. |
| `sales_order.below_min_quantity` | min_order_qty: count | A product is below its minimum order of {min}. | Un producto está por debajo de su pedido mínimo de {min}. |
| `sales_order.has_payment_applications` | — | This order has payments applied. Reverse them first. | Este pedido tiene pagos aplicados. Revírtelos primero. |
| `sales_order.insufficient_stock` | lines (error-mapping §5) | Some lines don't have enough stock | Algunas partidas no tienen existencia suficiente |
| `sales_order.missing_delivery_details` | missing (error-mapping §5) | Delivery details are missing | Faltan datos de entrega |
| `sales_order.no_lines` | — | Add at least one line before confirming. | Agrega al menos una partida antes de confirmar. |
| `sales_order.paid_cannot_cancel` | — | A paid order can't be cancelled. Refund it instead. | Un pedido pagado no se puede cancelar. Haz una devolución. |
| `sales_order.zero_priced_lines` | lines (error-mapping §5) | Some lines have no price | Algunas partidas no tienen precio |
| `supplier_agreement.end_before_start` | start: date, end: date | The end date ({end}) is before the start date ({start}). | La fecha de fin ({end}) es anterior a la de inicio ({start}). |
| `taxpayer_certificate.holder_mismatch` | certificate_taxpayer: text, taxpayer: text | The certificate belongs to {certificateTaxpayer}, not to {taxpayer}. | El certificado es de {certificateTaxpayer}, no de {taxpayer}. |
| `taxpayer_issuer.unknown` | taxpayer: text | The issuer {taxpayer} isn't registered. | El emisor {taxpayer} no está registrado. |
| `user.no_cash_drawer` | — | Your user has no cash drawer assigned. | Tu usuario no tiene una caja asignada. |
| `user.no_facility` | — | Your user has no facility assigned. | Tu usuario no tiene una sucursal asignada. |
| `user.no_point_of_sale` | — | Your user has no point of sale assigned. | Tu usuario no tiene un punto de venta asignado. |
| `user_profile.not_active` | — | This profile is inactive and can't be applied. | Este perfil está inactivo y no se puede aplicar. |
| `warehouse.in_transit_location` | — | An in-transit warehouse can't be used here. | Aquí no se puede usar un almacén en tránsito. |
| `warehouse.in_transit_managed` | — | In-transit warehouses are managed by the system and can't be edited. | Los almacenes en tránsito los administra el sistema y no se pueden editar. |
| `warehouse.required` | — | Choose a warehouse. Your point of sale has none. | Elige un almacén. Tu punto de venta no tiene uno. |

Notes:
- `image.too_large`: `{max}` is `max_bytes` rendered as a size, e.g. "5 MB". That is the only size param in scope, rendered as whole MB, or KB below 1 MB.
- `refund.line_invoiced` is two keys, `apiErrorRefundLineInvoiced(product, invoice)` and `apiErrorRefundLineInvoicedNoFolio(product)`. `invoice` is optional per the contract.
- `facility.other_facility`'s Spanish uses the gender `select`, like §1.
- `product_price.references_not_found` uses the noun's plural, `count: 2`.
- The headline-plus-lines codes (`insufficient_stock`, `missing_delivery_details`, `zero_priced_lines`) render the headline, a colon, and then one line per item (error-mapping.md §5); with no items they render the headline alone.

## 3. Validation types (9)

| Type | en | es |
|---|---|---|
| `password_policy` | existing `localizePasswordRule` messages | (existing) |
| `contact_name_blank` | The name can't be blank. | El nombre no puede estar vacío. |
| `email_address_invalid` | That isn't a valid email address. | Ese no es un correo electrónico válido. |
| `product_barcode_invalid` | The barcode must be empty or exactly 13 digits (EAN-13). | El código de barras debe estar vacío o tener exactamente 13 dígitos (EAN-13). |
| `product_code_has_whitespace` | The code can't contain spaces. | El código no puede contener espacios. |
| `profile_duplicate_system_object` | A permission appears twice in this profile. | Un permiso aparece dos veces en este perfil. |
| `profile_unknown_system_object` | The profile has a permission the server doesn't recognize. | El perfil tiene un permiso que el servidor no reconoce. |
| `supplier_agreement_end_before_start` | The end date can't be before the start date. | La fecha de fin no puede ser anterior a la de inicio. |
| `user_id_not_alphanumeric` | The username can only have letters and numbers. | El nombre de usuario solo puede tener letras y números. |

`password_policy` has no key here: its per-rule messages stay in `localizePasswordRule`, which lives in the auth feature, and `localizeValidationType` returns `null` for it.

The ARB key is `apiValidation` + the type in PascalCase.

## 4. Record nouns (42)

Each noun is one plural-aware key, `apiResource<Name>(int count)` → `{count, plural, one{…} other{…}}`. The Spanish gender comes from a parallel key, `apiResourceGender<Name>`, holding `masculine` or `feminine`.

The set:
- every `resource` value that in-scope codes can carry (not found, already exists, other facility, lock, product-price references);
- plus the blockers of in-scope deletes that a user can recognize.

Any other name renders as the generic noun, and `still_referenced` counts it in the "and N more" tail.

| Name | en (one / other) | es (one / other) | es gender |
|---|---|---|---|
| `cash_drawer` | cash drawer / cash drawers | caja / cajas | f |
| `cash_session` | cash session / cash sessions | sesión de caja / sesiones de caja | f |
| `credit_note` | credit note / credit notes | nota de crédito / notas de crédito | f |
| `customer` | customer / customers | cliente / clientes | m |
| `customer_discount` | customer discount / customer discounts | descuento de cliente / descuentos de cliente | m |
| `customer_payment` | payment / payments | pago / pagos | m |
| `customer_refund` | refund / refunds | devolución / devoluciones | f |
| `delivery_itinerary` | delivery route / delivery routes | ruta de entrega / rutas de entrega | f |
| `delivery_order` | delivery order / delivery orders | orden de entrega / órdenes de entrega | f |
| `delivery_order_line` | delivery line / delivery lines | partida de entrega / partidas de entrega | f |
| `employee` | employee / employees | empleado / empleados | m |
| `exchange_rate` | exchange rate / exchange rates | tipo de cambio / tipos de cambio | m |
| `expense` | expense / expenses | gasto / gastos | m |
| `expense_voucher` | expense voucher / expense vouchers | vale de gasto / vales de gasto | m |
| `facility` | facility / facilities | sucursal / sucursales | f |
| `fiscal_document` | invoice / invoices | factura / facturas | f |
| `inventory_issue` | warehouse issue / warehouse issues | salida de almacén / salidas de almacén | f |
| `inventory_receipt` | warehouse receipt / warehouse receipts | entrada de almacén / entradas de almacén | f |
| `inventory_transfer` | transfer / transfers | traspaso / traspasos | m |
| `label` | label / labels | etiqueta / etiquetas | f |
| `payment_method_option` | payment method / payment methods | forma de pago / formas de pago | f |
| `point_of_sale` | point of sale / points of sale | punto de venta / puntos de venta | m |
| `price_list` | price list / price lists | lista de precios / listas de precios | f |
| `product` | product / products | producto / productos | m |
| `product_price` | price / prices | precio / precios | m |
| `purchase_order` | purchase order / purchase orders | orden de compra / órdenes de compra | f |
| `sales_order` | order / orders | pedido / pedidos | m |
| `sales_order_line` | order line / order lines | partida del pedido / partidas del pedido | f |
| `sales_order_payment` | order payment / order payments | pago de pedido / pagos de pedido | m |
| `sales_quote` | quote / quotes | cotización / cotizaciones | f |
| `sales_quote_line` | quote line / quote lines | partida de la cotización / partidas de la cotización | f |
| `stock_movement` | stock movement / stock movements | movimiento de inventario / movimientos de inventario | m |
| `supplier` | supplier / suppliers | proveedor / proveedores | m |
| `supplier_payment` | supplier payment / supplier payments | pago a proveedor / pagos a proveedor | m |
| `taxpayer_certificate` | certificate / certificates | certificado / certificados | m |
| `taxpayer_issuer` | issuer / issuers | emisor / emisores | m |
| `taxpayer_recipient` | recipient / recipients | receptor / receptores | m |
| `user` | user / users | usuario / usuarios | m |
| `user_profile` | profile / profiles | perfil / perfiles | m |
| `vehicle` | vehicle / vehicles | vehículo / vehículos | m |
| `vehicle_operator` | vehicle operator / vehicle operators | operador de vehículo / operadores de vehículo | m |
| `warehouse` | warehouse / warehouses | almacén / almacenes | m |

Generic noun: `apiResourceGeneric(count)`: en record / records, es registro / registros, m.

## 5. Out of scope (155 codes, 13 validation types)

These are returned only by routes the app does not call. They fall back to today's display (FR-010) until the spec that builds their screens adds them:
- whole domains: `analytics.*`, `commission_*`, `expense_voucher.*`, `fiscal_document.*`, `inventory_*`, `itinerary.*`, `kardex.*`, `purchase_order.*`, `purchase_request.*`, `supplier_payment.*`, `taxpayer_batch.*`, `delivery_order_line.*`, `status_filter.unsupported`, `vehicle.*`;
- the other codes of split domains:
  - `delivery_order`: approve and transition workflow;
  - `email`: recipients and contacts;
  - `facility.no_in_transit_location`;
  - `payment`: apply, verify and reverse;
  - `product`: two codes outside the lookup and merge routes;
  - `refund.quantity_exceeds_refundable`, `refund.warehouse_other_facility`;
  - `sales_order.not_confirmed`.

The out-of-scope validation types are the fiscal-document, inventory, purchase, supplier-payment, statement-email and taxpayer-batch types.
