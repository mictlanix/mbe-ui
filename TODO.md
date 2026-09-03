
## 2026-07-18
- ~~Cambie en merge prod cards, y hacer más explicito que producto es el que queda. ~~
- Opción para desaparecer etiquetas descartadas
- ~~Crud etiquetas~~
- ~~Accion para capturar precio desde crud de productos~~
- ~~Exchange rate en productos~~

## 2026-07-28
- ~~Alta de cliente facil sin salir de la pantalla, y una vez dado de alta, que ya aparezca seleccionado~~
- Cuando un cliente tenga credito, que por default la forma de pago sea credito y restringir pago de contado
- ~~Seccion laterarl asegurar q sea touch friendly~~
- Prioridad normal por default
- Tipo de cambio configurable por empresa
- ~~Inicio de caja~~

## 2026-08-02
- Quitar restricción de plantas de producción
- ~~Filtrar Activo por defecto~~
- Operadores -> Agregar foto de licencia
- Vehiculos -> Agregar Foto de tarjeta de circulación
- Renombrar Sitio de producción => Planta de producción
- ~~En formularios sencillos, cambiar navegación por drawers~~
- ¿Quitar catalogo Formas de Pago?
- ~~Mejorar UX de lista de precios, que sea lista de productos pivoted~~

## 2026-08-15
- ~~Alinear textfields de cantidad/ precio/ descuento/ impuesto.~~
- Incrementar Fontweight de importe
- Estados en una sola palabra (Venta, Cobro, Entrega, Finalizada)
- ~~Filtros de pantalla de punto de venta, alinearla con cruds (boton de filtros + drawer)~~
- ~~Configuraciones generales del sistema~~
  - ~~Formatos de fecha, montos, idioma de la aplicación~~
- ~~Configuraciones del usuario~~
  - ~~Tema de la aplicacion (light / dark)~~

## 2026-08-16
- ~~Falta botón para editar destinos (destination card)~~

## 2026-08-30
- Ajustes a ui de cruds:
  - ~~Habilitar filtro status=activo por defecto~~
  - ~~Corrección de márgenes/paddings horizontales de CatalogFilterBar~~
  - ~~Cambiar formularios sencillos a drawers:~~
    - ~~PriceLists~~
    - ~~Suppliers~~
    - ~~Labels~~
    - ~~Employees~~
    - ~~Customers~~
    - ~~Taxpayer recipients~~
    - ~~Expenses~~
    - ~~Vehicles~~
    - ~~Operators~~
    - ~~Warehouse~~
    - ~~Point of Sale~~
    - ~~Cash Drawer~~
    - ~~Payment Method?~~

  - ~~Esquinas redondeadas de DataTableView?~~
  - ~~Hairline borders en tablas?~~
  - ~~Hairline borders en cards de FacilityCard WarehouseChildRow PointSaleChildRow CashDrawerChildRow~~
  - ~~Que CRUD actualice DataTableView al realizar busqueda, aun cuando el filtro no haya cambiado~~

## 2026-09-01
Login:
  - Requerir reinicio de password en primer login
  - Requerir strong password

Clientes:
  - ~~Codigo de capura de cliente opcional y ubicarlo al final del form~~
  - ~~Quitar bool envio y req documento~~

POS Sales:
  - ~~Mostrar sin existenicias en almacen~~
  - ~~Permitir que puedan regresar si no se ha pagado~~
  - ~~Checar pasos de pos sale~~
  - ~~Por default, al agregar primer domicilio, se asigne toda la qty a éste~~

Pedidos:
  - ~~De pedidos, quitar publico en gral, y se debe de elegir el cliente~~
  - Quitar pago y agregar entrega obligatorio
  - Fecha de entrega
  - ~~Vendedor associado al cliente~~

lista de precios
  - ~~Mostrar dos decimales~~
  - ~~No detecta submit~~

## 2026-09-02
Pedidos:
  - Balance field shows on two places, on customer bar and order header panel.
  - On Customer bar, change label 'Credit Line' to Payment terms
  - On Order header panel, remove payment terms.
  - On Order header panel, reorder the fields: 1. Priority, 2. Currency, 3. Exchange rate, 4. Tax ID, 5. Delivery details, 6. Contact, 7. Comment.
  - Move Order header panel, below customer bar.