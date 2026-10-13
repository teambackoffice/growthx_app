import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lead.dart';
import 'leads_dummy_data.dart';

final leadsProvider = NotifierProvider<LeadsNotifier, List<Lead>>(
  LeadsNotifier.new,
);

class LeadsNotifier extends Notifier<List<Lead>> {
  @override
  List<Lead> build() => dummyLeads;

  /// Simulates a network call so the form can show its loading state.
  Future<Lead> add(Lead lead) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    state = [lead, ...state];
    return lead;
  }

  void updateStatus(String id, LeadStatus status) {
    state = [
      for (final l in state)
        if (l.id == id) l.copyWith(status: status) else l,
    ];
  }
}
