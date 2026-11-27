import 'package:flutter/material.dart' show Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/nav_destination.dart';
import 'package:mbe_ui/core/navigation/nav_destinations.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';

/// Spec 049 FR-003/FR-004: the exchange-rates destination exists only on a
/// multi-currency deployment, on top of its privilege gate.
void main() {
  const exchangeRatesReader = Privilege(
    systemObject: SystemObject.exchangeRates,
    rawValue: 2,
  );

  Set<String> visibleIds({
    required bool multiCurrency,
    required bool administrator,
    List<Privilege> privileges = const [],
  }) {
    final user = User(
      userId: 'u',
      email: 'u@example.com',
      administrator: administrator,
      status: EntityStatus.active,
      sessionVersion: 1,
      privileges: privileges,
    );
    final container = ProviderContainer(
      overrides: [
        multiCurrencyEnabledProvider.overrideWithValue(multiCurrency),
        accessControlProvider.overrideWithValue(
          AccessControlService(AuthState.authenticated(token: 't', user: user)),
        ),
      ],
    );
    addTearDown(container.dispose);
    return {
      for (final item in container.read(navDestinationsProvider))
        ...switch (item) {
          NavDestination() => [item.id],
          NavGroup() => item.children.map((d) => d.id),
        },
    };
  }

  test('off: the entry is hidden even for an administrator', () {
    expect(
      visibleIds(multiCurrency: false, administrator: true),
      isNot(contains('exchange-rates')),
    );
  });

  test('on: an administrator sees it', () {
    expect(
      visibleIds(multiCurrency: true, administrator: true),
      contains('exchange-rates'),
    );
  });

  test('on: the privilege gate still applies', () {
    expect(
      visibleIds(multiCurrency: true, administrator: false),
      isNot(contains('exchange-rates')),
    );
    expect(
      visibleIds(
        multiCurrency: true,
        administrator: false,
        privileges: const [exchangeRatesReader],
      ),
      contains('exchange-rates'),
    );
  });

  test('the option does not hide other destinations', () {
    expect(
      visibleIds(multiCurrency: false, administrator: true),
      contains('price-lists'),
    );
  });

  test('routeRequiresMultiCurrency covers the destination and its records', () {
    expect(routeRequiresMultiCurrency('/exchange-rates'), isTrue);
    expect(routeRequiresMultiCurrency('/exchange-rates/new'), isTrue);
    expect(routeRequiresMultiCurrency('/exchange-rates/7'), isTrue);
    expect(routeRequiresMultiCurrency('/products'), isFalse);
    expect(routeRequiresMultiCurrency('/exchange-rates-archive'), isFalse);
  });

  group('Pagos destination (spec 054 FR-001)', () {
    test('a user without Customer Payments read has no entry', () {
      expect(
        visibleIds(multiCurrency: false, administrator: false),
        isNot(contains('payments')),
      );
      // POS read alone is not enough: a payment is permissioned separately.
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.pos, rawValue: 2),
          ],
        ),
        isNot(contains('payments')),
      );
    });

    test('a user with Customer Payments read has the entry', () {
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.customerPayments, rawValue: 2),
          ],
        ),
        contains('payments'),
      );
    });

    test('an administrator has the entry', () {
      expect(
        visibleIds(multiCurrency: false, administrator: true),
        contains('payments'),
      );
    });
  });

  group('Notas de crédito destination (spec 056 FR-013)', () {
    test('a user without Credit Payments read has no entry', () {
      expect(
        visibleIds(multiCurrency: false, administrator: false),
        isNot(contains('credit-notes')),
      );
      // Customer Payments read alone is not enough: a credit note is
      // permissioned separately, as Credit Payments (83).
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.customerPayments, rawValue: 2),
          ],
        ),
        isNot(contains('credit-notes')),
      );
    });

    test('a user with Credit Payments read has the entry', () {
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.creditPayments, rawValue: 2),
          ],
        ),
        contains('credit-notes'),
      );
    });

    test('an administrator has the entry', () {
      expect(
        visibleIds(multiCurrency: false, administrator: true),
        contains('credit-notes'),
      );
    });

    test('it sits right after Pagos', () {
      final container = ProviderContainer(
        overrides: [
          multiCurrencyEnabledProvider.overrideWithValue(false),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(
                token: 't',
                user: const User(
                  userId: 'u',
                  email: 'u@example.com',
                  administrator: true,
                  status: EntityStatus.active,
                  sessionVersion: 1,
                  privileges: [],
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final ids = [
        for (final item in container.read(navDestinationsProvider))
          ...switch (item) {
            NavDestination() => [item.id],
            NavGroup() => item.children.map((d) => d.id),
          },
      ];

      // Verificación de pagos sits between Pagos and Notas de crédito
      // (spec 060), so a user holding both rights sees them in that order.
      expect(ids.indexOf('credit-notes'), greaterThan(ids.indexOf('payments')));
    });
  });

  group('Verificación de pagos destination (spec 060 FR-001)', () {
    test('a user without Payments Verification read has no entry', () {
      expect(
        visibleIds(multiCurrency: false, administrator: false),
        isNot(contains('payment-verification')),
      );
      // Customer Payments read alone is not enough: verification is its own
      // right, on the server too.
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.customerPayments, rawValue: 2),
          ],
        ),
        isNot(contains('payment-verification')),
      );
    });

    test('a user with Payments Verification read has the entry', () {
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(
              systemObject: SystemObject.paymentsVerification,
              rawValue: 2,
            ),
          ],
        ),
        contains('payment-verification'),
      );
    });

    test('an administrator has the entry', () {
      expect(
        visibleIds(multiCurrency: false, administrator: true),
        contains('payment-verification'),
      );
    });

    test('it sits right after Pagos, on its own branch', () {
      final container = ProviderContainer(
        overrides: [
          multiCurrencyEnabledProvider.overrideWithValue(false),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(
                token: 't',
                user: const User(
                  userId: 'u',
                  email: 'u@example.com',
                  administrator: true,
                  status: EntityStatus.active,
                  sessionVersion: 1,
                  privileges: [],
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final destinations = [
        for (final item in container.read(navDestinationsProvider))
          ...switch (item) {
            NavDestination() => [item],
            NavGroup() => item.children.whereType<NavDestination>(),
          },
      ];
      final ids = [for (final d in destinations) d.id];

      expect(ids.indexOf('payment-verification'), ids.indexOf('payments') + 1);
      expect(
        destinations
            .firstWhere((d) => d.id == 'payment-verification')
            .branchIndex,
        25,
      );
    });
  });

  group('Devoluciones destination (spec 057 FR-013)', () {
    test('a user without Customer Refunds read has no entry', () {
      expect(
        visibleIds(multiCurrency: false, administrator: false),
        isNot(contains('refunds')),
      );
      // Customer Payments and Credit Payments read are not enough: a refund
      // is permissioned on its own.
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.customerPayments, rawValue: 2),
            Privilege(systemObject: SystemObject.creditPayments, rawValue: 2),
          ],
        ),
        isNot(contains('refunds')),
      );
    });

    test('a user with Customer Refunds read has the entry', () {
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.customerRefunds, rawValue: 2),
          ],
        ),
        contains('refunds'),
      );
    });

    test('an administrator has the entry', () {
      expect(
        visibleIds(multiCurrency: false, administrator: true),
        contains('refunds'),
      );
    });

    test('it sits right after Notas de crédito, on branch 24', () {
      final container = ProviderContainer(
        overrides: [
          multiCurrencyEnabledProvider.overrideWithValue(false),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(
                token: 't',
                user: const User(
                  userId: 'u',
                  email: 'u@example.com',
                  administrator: true,
                  status: EntityStatus.active,
                  sessionVersion: 1,
                  privileges: [],
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final destinations = [
        for (final item in container.read(navDestinationsProvider))
          ...switch (item) {
            NavDestination() => [item],
            NavGroup() => item.children,
          },
      ];
      final ids = [for (final d in destinations) d.id];

      expect(ids.indexOf('refunds'), ids.indexOf('credit-notes') + 1);
      expect(destinations.firstWhere((d) => d.id == 'refunds').branchIndex, 24);
    });
  });
  group('Órdenes de entrega destination (spec 061 FR-001, C1)', () {
    test('a user without Delivery Orders read has no entry', () {
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.salesOrders, rawValue: 2),
          ],
        ),
        isNot(contains('delivery-orders')),
      );
    });

    test('a user with Delivery Orders read has the entry', () {
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.deliveryOrders, rawValue: 2),
          ],
        ),
        contains('delivery-orders'),
      );
    });

    test(
      'it sits after Cajas in Operación, ahead of vehicles and operators, on branch 26',
      () {
        final container = ProviderContainer(
          overrides: [
            multiCurrencyEnabledProvider.overrideWithValue(false),
            accessControlProvider.overrideWithValue(
              AccessControlService(
                AuthState.authenticated(
                  token: 't',
                  user: const User(
                    userId: 'u',
                    email: 'u@example.com',
                    administrator: true,
                    status: EntityStatus.active,
                    sessionVersion: 1,
                    privileges: [],
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        final items = container.read(navDestinationsProvider);
        final operation =
            items.firstWhere((i) => i is NavGroup && i.id == 'operation')
                as NavGroup;
        final ids = [for (final d in operation.children) d.id];
        expect(
          ids.indexOf('delivery-orders'),
          ids.indexOf('cash-sessions') + 1,
        );
        expect(ids.sublist(ids.indexOf('delivery-orders')), [
          'delivery-orders',
          'delivery-order-approval',
          'for-delivery',
          'delivery-itineraries',
          'vehicles',
          'vehicle-operators',
        ]);
        final others = [
          for (final g in items.whereType<NavGroup>().where(
            (g) => g.id != 'operation',
          ))
            for (final d in g.children) d.id,
        ];
        expect(others, isNot(contains('delivery-orders')));
        expect(others, isNot(contains('vehicles')));
        expect(others, isNot(contains('vehicle-operators')));
        expect(
          operation.children
              .firstWhere((d) => d.id == 'delivery-orders')
              .branchIndex,
          NavBranch.deliveryOrders,
        );
        expect(NavBranch.deliveryOrders, 26);
      },
    );
  });

  group('Aprobación de entregas destination (spec 062 FR-001, C1)', () {
    test('a user without Delivery Order Approval read has no entry, even '
        'with Delivery Orders read', () {
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.deliveryOrders, rawValue: 2),
          ],
        ),
        isNot(contains('delivery-order-approval')),
      );
    });

    test('a user with Delivery Order Approval read has the entry, and no '
        'Delivery Orders entry unless they hold that right too', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(
            systemObject: SystemObject.deliveryOrderApproval,
            rawValue: 2,
          ),
        ],
      );
      expect(ids, contains('delivery-order-approval'));
      expect(ids, isNot(contains('delivery-orders')));
    });

    test('it sits right after Órdenes de entrega in Operación, on branch 27 '
        'at /sales/delivery-order-approval', () {
      final container = ProviderContainer(
        overrides: [
          multiCurrencyEnabledProvider.overrideWithValue(false),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(
                token: 't',
                user: const User(
                  userId: 'u',
                  email: 'u@example.com',
                  administrator: true,
                  status: EntityStatus.active,
                  sessionVersion: 1,
                  privileges: [],
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final operation =
          container
                  .read(navDestinationsProvider)
                  .firstWhere((i) => i is NavGroup && i.id == 'operation')
              as NavGroup;
      final ids = [for (final d in operation.children) d.id];
      expect(
        ids.indexOf('delivery-order-approval'),
        ids.indexOf('delivery-orders') + 1,
      );
      final entry = operation.children.firstWhere(
        (d) => d.id == 'delivery-order-approval',
      );
      expect(entry.branchIndex, NavBranch.deliveryOrderApproval);
      expect(entry.route, '/sales/delivery-order-approval');
      expect(NavBranch.deliveryOrderApproval, 27);
    });
  });
  group('Por entregar destination (spec 063 FR-001, C1)', () {
    test('a user without For Delivery read has no entry, even with Delivery '
        'Orders and Delivery Order Approval read', () {
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(systemObject: SystemObject.deliveryOrders, rawValue: 2),
            Privilege(
              systemObject: SystemObject.deliveryOrderApproval,
              rawValue: 2,
            ),
          ],
        ),
        isNot(contains('for-delivery')),
      );
    });

    test('a user with For Delivery read has the entry, and no Delivery '
        'Orders entry unless they hold that right too', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.forDeliver, rawValue: 2),
        ],
      );
      expect(ids, contains('for-delivery'));
      expect(ids, isNot(contains('delivery-orders')));
    });

    test('it sits right after Aprobación de entregas in Operación, on branch '
        '28 at /sales/for-delivery', () {
      final container = ProviderContainer(
        overrides: [
          multiCurrencyEnabledProvider.overrideWithValue(false),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(
                token: 't',
                user: const User(
                  userId: 'u',
                  email: 'u@example.com',
                  administrator: true,
                  status: EntityStatus.active,
                  sessionVersion: 1,
                  privileges: [],
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final operation =
          container
                  .read(navDestinationsProvider)
                  .firstWhere((i) => i is NavGroup && i.id == 'operation')
              as NavGroup;
      final ids = [for (final d in operation.children) d.id];
      expect(
        ids.indexOf('for-delivery'),
        ids.indexOf('delivery-order-approval') + 1,
      );
      final entry = operation.children.firstWhere(
        (d) => d.id == 'for-delivery',
      );
      expect(entry.branchIndex, NavBranch.forDelivery);
      expect(entry.route, '/sales/for-delivery');
      expect(NavBranch.forDelivery, 28);
    });
  });

  group('Itinerarios destination (spec 075 FR-001)', () {
    test('a user without Delivery Itineraries read has no entry', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.deliveryOrders, rawValue: 2),
          Privilege(systemObject: SystemObject.forDeliver, rawValue: 2),
          // Create without read still doesn't open the list.
          Privilege(
            systemObject: SystemObject.deliveryItineraries,
            rawValue: 1,
          ),
        ],
      );
      expect(ids, isNot(contains('delivery-itineraries')));
    });

    test('a user with Delivery Itineraries read has the entry, and no '
        'Delivery Orders entry unless they hold that right too', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(
            systemObject: SystemObject.deliveryItineraries,
            rawValue: 2,
          ),
        ],
      );
      expect(ids, contains('delivery-itineraries'));
      expect(ids, isNot(contains('delivery-orders')));
      expect(ids, isNot(contains('for-delivery')));
    });

    test('an administrator has the entry', () {
      expect(
        visibleIds(multiCurrency: false, administrator: true),
        contains('delivery-itineraries'),
      );
    });

    test('it sits right after Por entregar in Operación, on branch 36 at '
        '/sales/delivery-itineraries', () {
      final container = ProviderContainer(
        overrides: [
          multiCurrencyEnabledProvider.overrideWithValue(false),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(
                token: 't',
                user: const User(
                  userId: 'u',
                  email: 'u@example.com',
                  administrator: true,
                  status: EntityStatus.active,
                  sessionVersion: 1,
                  privileges: [],
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final operation =
          container
                  .read(navDestinationsProvider)
                  .firstWhere((i) => i is NavGroup && i.id == 'operation')
              as NavGroup;
      final ids = [for (final d in operation.children) d.id];
      expect(
        ids.indexOf('delivery-itineraries'),
        ids.indexOf('for-delivery') + 1,
      );
      final entry = operation.children.firstWhere(
        (d) => d.id == 'delivery-itineraries',
      );
      expect(entry.branchIndex, NavBranch.deliveryItineraries);
      expect(entry.route, '/sales/delivery-itineraries');
      expect(NavBranch.deliveryItineraries, 36);
    });
  });

  group('Comisiones destination (spec 078)', () {
    test('a user without commissionsBySalesPerson read has no entry', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.expenses, rawValue: 2),
        ],
      );
      expect(ids, isNot(contains('commissions')));
    });

    test('read on commissionsBySalesPerson (112) shows the entry', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(
            systemObject: SystemObject.commissionsBySalesPerson,
            rawValue: 2,
          ),
        ],
      );
      expect(ids, contains('commissions'));
    });

    test('it sits right after Gastos in Finanzas, on branch 37 at '
        '/commissions', () {
      final container = ProviderContainer(
        overrides: [
          multiCurrencyEnabledProvider.overrideWithValue(false),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(
                token: 't',
                user: const User(
                  userId: 'u',
                  email: 'u@example.com',
                  administrator: true,
                  status: EntityStatus.active,
                  sessionVersion: 1,
                  privileges: [],
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final finance =
          container
                  .read(navDestinationsProvider)
                  .firstWhere((i) => i is NavGroup && i.id == 'finance')
              as NavGroup;
      final ids = [for (final d in finance.children) d.id];
      expect(ids.indexOf('commissions'), ids.indexOf('expenses') + 1);
      final entry = finance.children.firstWhere((d) => d.id == 'commissions');
      expect(entry.branchIndex, NavBranch.commissions);
      expect(entry.route, '/commissions');
      expect(NavBranch.commissions, 37);
    });
  });

  group('Solicitudes de compra destination (spec 079)', () {
    test('a user without PurchaseRequest (86) read has no Compras group', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.inventoryReceipts, rawValue: 2),
        ],
      );
      expect(ids, isNot(contains('purchase-requests')));
    });

    test('read on PurchaseRequest (86) shows the entry', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.purchaseRequest, rawValue: 2),
        ],
      );
      expect(ids, contains('purchase-requests'));
    });

    test('it opens the Compras group, between Inventario and Finanzas, on '
        'branch 38 at /purchases/requests', () {
      final groups = kNavigationTree.whereType<NavGroup>().toList();
      final groupIds = [for (final g in groups) g.id];
      expect(groupIds.indexOf('purchases'), groupIds.indexOf('inventory') + 1);
      expect(groupIds.indexOf('finance'), groupIds.indexOf('purchases') + 1);
      final entry = groups
          .firstWhere((g) => g.id == 'purchases')
          .children
          .first;
      expect(entry.id, 'purchase-requests');
      expect(entry.route, '/purchases/requests');
      expect(entry.branchIndex, NavBranch.purchaseRequests);
      expect(NavBranch.purchaseRequests, 38);
      expect(entry.icon, Icons.assignment_outlined);
      expect(entry.selectedIcon, Icons.assignment);
    });
  });

  group('Aprobación de solicitudes destination (spec 079)', () {
    test('read on PurchaseRequestApproval (96) alone shows the entry and '
        'the Compras group, without Solicitudes de compra', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(
            systemObject: SystemObject.purchaseRequestApproval,
            rawValue: 2,
          ),
        ],
      );
      // The Compras group shows, holding only this entry.
      expect(ids, contains('purchase-request-approval'));
      expect(ids, isNot(contains('purchase-requests')));
    });

    test('read on PurchaseRequest (86) alone shows the group without the '
        'approval entry', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.purchaseRequest, rawValue: 2),
        ],
      );
      expect(ids, contains('purchase-requests'));
      expect(ids, isNot(contains('purchase-request-approval')));
    });

    test('it follows Solicitudes de compra in Compras, on branch 39 at '
        '/purchases/request-approval', () {
      final entry = kNavigationTree
          .whereType<NavGroup>()
          .firstWhere((g) => g.id == 'purchases')
          .children[1];
      expect(entry.id, 'purchase-request-approval');
      expect(entry.route, '/purchases/request-approval');
      expect(entry.branchIndex, NavBranch.purchaseRequestApproval);
      expect(NavBranch.purchaseRequestApproval, 39);
      expect(entry.icon, Icons.fact_check_outlined);
      expect(entry.selectedIcon, Icons.fact_check);
    });
  });

  group('Facturas destination (spec 066 C1)', () {
    test('a user without FiscalDocuments read has no Facturas entry', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.deliveryOrders, rawValue: 2),
        ],
      );
      expect(ids, isNot(contains('fiscal-documents')));
    });

    test('a user with FiscalDocuments read has the entry, on branch 29 at '
        '/invoicing/fiscal-documents, in Finanzas, after Devoluciones', () {
      final privileges = const [
        Privilege(systemObject: SystemObject.fiscalDocuments, rawValue: 2),
      ];
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: privileges,
        ),
        contains('fiscal-documents'),
      );
      final children = kNavigationTree
          .whereType<NavGroup>()
          .firstWhere((g) => g.id == 'finance')
          .children;
      final ids = [for (final d in children) d.id];
      expect(ids.indexOf('fiscal-documents'), ids.indexOf('refunds') + 1);
      final entry = children.firstWhere((d) => d.id == 'fiscal-documents');
      expect(entry.route, '/invoicing/fiscal-documents');
      expect(entry.branchIndex, NavBranch.fiscalDocuments);
      expect(NavBranch.fiscalDocuments, 29);
    });
  });

  group('Entradas de almacén destination (spec 067 ui-contract)', () {
    test('a user without InventoryReceipts read has no Inventario group', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.fiscalDocuments, rawValue: 2),
        ],
      );
      expect(ids, isNot(contains('inventory-receipts')));
    });

    test('a user with InventoryReceipts read has the entry, on branch 30 at '
        '/inventory/receipts, in its Inventario group between Operación and '
        'Finanzas', () {
      expect(
        visibleIds(
          multiCurrency: false,
          administrator: false,
          privileges: const [
            Privilege(
              systemObject: SystemObject.inventoryReceipts,
              rawValue: 2,
            ),
          ],
        ),
        contains('inventory-receipts'),
      );
      final groupIds = [
        for (final g in kNavigationTree.whereType<NavGroup>()) g.id,
      ];
      expect(groupIds.indexOf('inventory'), groupIds.indexOf('operation') + 1);
      // Compras (spec 079) sits between Inventario and Finanzas.
      expect(
        groupIds.indexOf('finance'),
        greaterThan(groupIds.indexOf('inventory')),
      );
      final entry = kNavigationTree
          .whereType<NavGroup>()
          .firstWhere((g) => g.id == 'inventory')
          .children
          .first;
      expect(entry.id, 'inventory-receipts');
      expect(entry.route, '/inventory/receipts');
      expect(entry.branchIndex, NavBranch.inventoryReceipts);
      expect(NavBranch.inventoryReceipts, 30);
    });
  });

  group('Salidas de almacén destination (spec 068 ui-contract)', () {
    NavGroup inventoryGroup() => kNavigationTree
        .whereType<NavGroup>()
        .firstWhere((g) => g.id == 'inventory');

    test('a user without InventoryIssues read has no Salidas entry', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.inventoryReceipts, rawValue: 2),
        ],
      );
      expect(ids, contains('inventory-receipts'));
      expect(ids, isNot(contains('inventory-issues')));
    });

    test('a user with InventoryIssues read has the entry, and the group stays '
        'when they can read only that one', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.inventoryIssues, rawValue: 2),
        ],
      );
      expect(ids, contains('inventory-issues'));
      expect(ids, isNot(contains('inventory-receipts')));
    });

    test('it is the second entry of Inventario, after Entradas, on branch 31 '
        'at /inventory/issues', () {
      final children = inventoryGroup().children;
      expect(
        [for (final c in children.take(6)) c.id],
        [
          'inventory-receipts',
          'inventory-issues',
          'inventory-transfers',
          'inventory-counts',
          'inventory-stock',
          'inventory-kardex',
        ],
      );
      final entry = children[1];
      expect(entry.route, '/inventory/issues');
      expect(entry.branchIndex, NavBranch.inventoryIssues);
      expect(NavBranch.inventoryIssues, 31);
      expect(entry.icon, Icons.outbox_outlined);
      expect(entry.selectedIcon, Icons.outbox);
    });
  });

  group('Traspasos destination (spec 069 ui-contract)', () {
    NavGroup inventoryGroup() => kNavigationTree
        .whereType<NavGroup>()
        .firstWhere((g) => g.id == 'inventory');

    test('a user without InventoryTransfers read has no Traspasos entry', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.inventoryIssues, rawValue: 2),
        ],
      );
      expect(ids, contains('inventory-issues'));
      expect(ids, isNot(contains('inventory-transfers')));
    });

    test('a user with InventoryTransfers read has the entry, and the group '
        'stays when they can read only that one', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.inventoryTransfers, rawValue: 2),
        ],
      );
      expect(ids, contains('inventory-transfers'));
      expect(ids, isNot(contains('inventory-receipts')));
      expect(ids, isNot(contains('inventory-issues')));
    });

    test('it is the third entry of Inventario, after Salidas, on branch 32 '
        'at /inventory/transfers', () {
      final children = inventoryGroup().children;
      expect(
        [for (final c in children.take(6)) c.id],
        [
          'inventory-receipts',
          'inventory-issues',
          'inventory-transfers',
          'inventory-counts',
          'inventory-stock',
          'inventory-kardex',
        ],
      );
      final entry = children[2];
      expect(entry.route, '/inventory/transfers');
      expect(entry.branchIndex, NavBranch.inventoryTransfers);
      expect(NavBranch.inventoryTransfers, 32);
      expect(entry.icon, Icons.swap_horiz_outlined);
      expect(entry.selectedIcon, Icons.swap_horiz);
    });
  });

  group('Conteos físicos destination (spec 070 ui-contract)', () {
    NavGroup inventoryGroup() => kNavigationTree
        .whereType<NavGroup>()
        .firstWhere((g) => g.id == 'inventory');

    test('a user without PhysicalCountAdjustment read has no Conteos '
        'entry', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.inventoryTransfers, rawValue: 2),
        ],
      );
      expect(ids, contains('inventory-transfers'));
      expect(ids, isNot(contains('inventory-counts')));
    });

    test('a user with PhysicalCountAdjustment read has the entry, and the '
        'group stays when they can read only that one', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(
            systemObject: SystemObject.physicalCountAdjustment,
            rawValue: 2,
          ),
        ],
      );
      expect(ids, contains('inventory-counts'));
      expect(ids, isNot(contains('inventory-receipts')));
      expect(ids, isNot(contains('inventory-issues')));
      expect(ids, isNot(contains('inventory-transfers')));
    });

    test('it is the fourth entry of Inventario, after Traspasos, on branch 33 '
        'at /inventory/counts', () {
      final children = inventoryGroup().children;
      expect(
        [for (final c in children.take(6)) c.id],
        [
          'inventory-receipts',
          'inventory-issues',
          'inventory-transfers',
          'inventory-counts',
          'inventory-stock',
          'inventory-kardex',
        ],
      );
      final entry = children[3];
      expect(entry.route, '/inventory/counts');
      expect(entry.branchIndex, NavBranch.inventoryCounts);
      expect(NavBranch.inventoryCounts, 33);
      expect(entry.icon, Icons.fact_check_outlined);
      expect(entry.selectedIcon, Icons.fact_check);
    });
  });

  group('Existencias destination (spec 071 ui-contract)', () {
    NavGroup inventoryGroup() => kNavigationTree
        .whereType<NavGroup>()
        .firstWhere((g) => g.id == 'inventory');

    test('a user without WarehouseStockReport read has no Existencias '
        'entry', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(
            systemObject: SystemObject.physicalCountAdjustment,
            rawValue: 2,
          ),
        ],
      );
      expect(ids, contains('inventory-counts'));
      expect(ids, isNot(contains('inventory-stock')));
    });

    test('a user with WarehouseStockReport read has the entry, and the group '
        'stays when they can read only that one', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(
            systemObject: SystemObject.warehouseStockReport,
            rawValue: 2,
          ),
        ],
      );
      expect(ids, contains('inventory-stock'));
      expect(ids, isNot(contains('inventory-receipts')));
      expect(ids, isNot(contains('inventory-issues')));
      expect(ids, isNot(contains('inventory-transfers')));
      expect(ids, isNot(contains('inventory-counts')));
    });

    test('it is the fifth entry of Inventario, after Conteos físicos, on '
        'branch 34 at /inventory/stock', () {
      final children = inventoryGroup().children;
      expect(
        [for (final c in children.take(6)) c.id],
        [
          'inventory-receipts',
          'inventory-issues',
          'inventory-transfers',
          'inventory-counts',
          'inventory-stock',
          'inventory-kardex',
        ],
      );
      final entry = children[4];
      expect(entry.route, '/inventory/stock');
      expect(entry.branchIndex, NavBranch.inventoryStock);
      expect(NavBranch.inventoryStock, 34);
      expect(entry.icon, Icons.inventory_2_outlined);
      expect(entry.selectedIcon, Icons.inventory_2);
    });
  });

  group('Kardex destination (spec 071 ui-contract)', () {
    NavGroup inventoryGroup() => kNavigationTree
        .whereType<NavGroup>()
        .firstWhere((g) => g.id == 'inventory');

    test('a user with only WarehouseStockReport read sees Existencias but '
        'not Kardex', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(
            systemObject: SystemObject.warehouseStockReport,
            rawValue: 2,
          ),
        ],
      );
      expect(ids, contains('inventory-stock'));
      expect(ids, isNot(contains('inventory-kardex')));
    });

    test('a user with Kardex (32) read has the entry, and the group stays '
        'when they can read only that one', () {
      final ids = visibleIds(
        multiCurrency: false,
        administrator: false,
        privileges: const [
          Privilege(systemObject: SystemObject.kardex, rawValue: 2),
        ],
      );
      expect(ids, contains('inventory-kardex'));
      expect(ids, isNot(contains('inventory-stock')));
      expect(ids, isNot(contains('inventory-receipts')));
    });

    test('it is the sixth entry of Inventario, after Existencias, on branch '
        '35 at /inventory/kardex', () {
      final children = inventoryGroup().children;
      expect(children.map((c) => c.id).toList().indexOf('inventory-kardex'), 5);
      final entry = children[5];
      expect(entry.route, '/inventory/kardex');
      expect(entry.branchIndex, NavBranch.inventoryKardex);
      expect(NavBranch.inventoryKardex, 35);
      expect(entry.icon, Icons.receipt_long_outlined);
      expect(entry.selectedIcon, Icons.receipt_long);
    });
  });

  test(
    'five sections in order, Home first, every destination exactly once',
    () {
      expect(kNavigationTree.first, isA<NavDestination>());
      expect((kNavigationTree.first as NavDestination).id, 'home');
      final groups = kNavigationTree.whereType<NavGroup>().toList();
      expect(kNavigationTree.length, 1 + groups.length);
      expect(
        {
          for (final g in groups) g.id: [for (final d in g.children) d.id],
        },
        {
          'operation': [
            'pos',
            'sales-orders',
            'sales-quotes',
            'pricing',
            'customers',
            'cash-sessions',
            'delivery-orders',
            'delivery-order-approval',
            'for-delivery',
            'delivery-itineraries',
            'vehicles',
            'vehicle-operators',
          ],
          'inventory': [
            'inventory-receipts',
            'inventory-issues',
            'inventory-transfers',
            'inventory-counts',
            'inventory-stock',
            'inventory-kardex',
            'products',
            'price-lists',
            'suppliers',
            'labels',
          ],
          'purchases': ['purchase-requests', 'purchase-request-approval'],
          'finance': [
            'payments',
            'payment-verification',
            'credit-notes',
            'refunds',
            'fiscal-documents',
            'taxpayer-issuers',
            'taxpayer-recipients',
            'exchange-rates',
            'payment-method-options',
            'expenses',
            'commissions',
          ],
          'system': ['users', 'user-profiles', 'employees', 'facilities'],
        },
      );
      expect(
        [for (final g in groups) g.id],
        ['operation', 'inventory', 'purchases', 'finance', 'system'],
      );
      final all = [
        for (final item in kNavigationTree)
          ...switch (item) {
            NavDestination() => [item.id],
            NavGroup() => item.children.map((d) => d.id),
          },
      ];
      expect(all.length, 40);
      expect(all.toSet().length, 40);
    },
  );
}
