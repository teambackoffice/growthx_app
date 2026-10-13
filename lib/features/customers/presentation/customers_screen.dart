import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/card_sliver_list.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_chip_bar.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/page_title.dart';
import '../data/customer.dart';
import '../data/customer_providers.dart';
import 'widgets/customer_tile.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen>
    with FirstLoadMixin {
  late final _search = TextEditingController(
    text: ref.read(customerFilterProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearAll() {
    _search.clear();
    ref.read(customerFilterProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(customerFilterProvider);
    final all = ref.watch(customersProvider);
    final results = ref.watch(filteredCustomersProvider);
    final notifier = ref.read(customerFilterProvider.notifier);
    final text = Theme.of(context).textTheme;
    final active = all
        .where((c) => c.status == SubscriptionStatus.active)
        .length;

    int countOf(SubscriptionStatus s) => all.where((c) => c.status == s).length;

    return Scaffold(
      appBar: AppBar(
        title: PageTitle(
          'Customers',
          subtitle: '${all.length} businesses · $active paying',
        ),
        actions: [
          IconButton(
            tooltip: 'Add a lead',
            onPressed: () => context.push(AppRoutes.addLead),
            icon: const Icon(Icons.person_add_alt_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => Future.delayed(const Duration(milliseconds: 600)),
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: AppSearchField(
                  controller: _search,
                  hint: 'Search business, contact or city',
                  onChanged: notifier.setQuery,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FilterChipBar<SubscriptionStatus?>(
                selected: filter.status,
                onSelected: notifier.setStatus,
                options: [
                  FilterOption(null, 'All', count: all.length),
                  for (final s in SubscriptionStatus.values)
                    FilterOption(s, s.label, count: countOf(s)),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedSize(
                duration: AppMotion.of(context, AppMotion.medium),
                curve: AppMotion.curve,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          results.length == 1
                              ? '1 customer'
                              : '${results.length} customers',
                          style: text.labelMedium?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      if (filter.segment != null)
                        Flexible(
                          flex: 3,
                          child: InputChip(
                            label: Text(
                              filter.segment!.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onDeleted: notifier.clearSegment,
                            deleteIconColor: AppColors.primaryDark,
                            backgroundColor: AppColors.primarySoft,
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                            labelStyle: text.labelMedium?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (firstLoading)
              const SliverPadding(
                padding: AppSpacing.page,
                sliver: SliverToBoxAdapter(child: SkeletonList(rows: 6)),
              )
            else if (results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No customers found',
                  message: filter.query.isNotEmpty
                      ? 'Nothing matches "${filter.query}". Try another name '
                            'or city.'
                      : 'No customers match this filter yet.',
                  actionLabel: 'Clear filters',
                  onAction: _clearAll,
                ),
              )
            else
              CardSliverList(
                // Re-key so a new filter replays the row entrance.
                key: ValueKey('${filter.status}-${filter.segment}'),
                itemCount: results.length,
                itemBuilder: (context, i) => CustomerTile(customer: results[i]),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}
