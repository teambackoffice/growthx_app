import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import 'customer.dart';
import 'customers_dummy_data.dart';

final customersProvider = Provider<List<Customer>>((ref) => dummyCustomers);

final customerByIdProvider = Provider.family<Customer?, String>((ref, id) {
  for (final c in ref.watch(customersProvider)) {
    if (c.id == id) return c;
  }
  return null;
});

/// Trials ending within the next 7 days, soonest first.
final trialsEndingSoonProvider = Provider<List<Customer>>((ref) {
  final trials =
      ref
          .watch(customersProvider)
          .where(
            (c) =>
                c.status == SubscriptionStatus.trial &&
                c.trialEndsOn != null &&
                Fmt.daysUntil(c.trialEndsOn!) <= 7,
          )
          .toList()
        ..sort((a, b) => a.trialEndsOn!.compareTo(b.trialEndsOn!));
  return trials;
});

final newCustomersThisMonthProvider = Provider<List<Customer>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(customersProvider)
      .where(
        (c) => c.joinedOn.year == now.year && c.joinedOn.month == now.month,
      )
      .toList();
});

/// Most recent sign-ups first — drives the Home activity feed.
final recentCustomersProvider = Provider<List<Customer>>((ref) {
  return [...ref.watch(customersProvider)]
    ..sort((a, b) => b.joinedOn.compareTo(a.joinedOn));
});

/// Shortcuts opened from Home, shown as a removable chip on the list.
enum CustomerSegment {
  trialsEndingSoon('Trials ending in 7 days'),
  newThisMonth('Joined this month');

  const CustomerSegment(this.label);

  final String label;
}

/// Filter for the customers list. `null` status means "all".
class CustomerFilter {
  const CustomerFilter({this.status, this.query = '', this.segment});

  final SubscriptionStatus? status;
  final String query;
  final CustomerSegment? segment;
}

final customerFilterProvider =
    NotifierProvider<CustomerFilterNotifier, CustomerFilter>(
      CustomerFilterNotifier.new,
    );

class CustomerFilterNotifier extends Notifier<CustomerFilter> {
  @override
  CustomerFilter build() => const CustomerFilter();

  void setStatus(SubscriptionStatus? status) =>
      state = CustomerFilter(status: status, query: state.query);

  void setQuery(String query) => state = CustomerFilter(
    status: state.status,
    query: query,
    segment: state.segment,
  );

  void showSegment(CustomerSegment segment) => state = CustomerFilter(
    query: state.query,
    segment: segment,
    status: segment == CustomerSegment.trialsEndingSoon
        ? SubscriptionStatus.trial
        : null,
  );

  void clearSegment() =>
      state = CustomerFilter(status: state.status, query: state.query);

  void reset() => state = const CustomerFilter();
}

final filteredCustomersProvider = Provider<List<Customer>>((ref) {
  final filter = ref.watch(customerFilterProvider);
  final segmentIds = switch (filter.segment) {
    CustomerSegment.trialsEndingSoon =>
      ref.watch(trialsEndingSoonProvider).map((c) => c.id).toSet(),
    CustomerSegment.newThisMonth =>
      ref.watch(newCustomersThisMonthProvider).map((c) => c.id).toSet(),
    null => null,
  };
  final q = filter.query.trim().toLowerCase();
  return ref.watch(customersProvider).where((c) {
    if (filter.status != null && c.status != filter.status) return false;
    if (segmentIds != null && !segmentIds.contains(c.id)) return false;
    if (q.isEmpty) return true;
    return c.businessName.toLowerCase().contains(q) ||
        c.contactName.toLowerCase().contains(q) ||
        c.city.toLowerCase().contains(q);
  }).toList();
});
