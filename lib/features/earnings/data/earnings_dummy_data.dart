import '../../../core/utils/demo_dates.dart';
import 'earnings_models.dart';

Commission _c(
  String id,
  String title,
  CommissionType type,
  double amount,
  CommissionStatus status,
  DateTime date, {
  String? customerId,
  String? payoutId,
}) => Commission(
  id: id,
  title: title,
  type: type,
  amount: amount,
  status: status,
  date: date,
  customerId: customerId,
  payoutId: payoutId,
);

const _first = CommissionType.firstMonth;
const _recurring = CommissionType.recurring;
const _bonus = CommissionType.bonus;
const _pending = CommissionStatus.pending;
const _approved = CommissionStatus.approved;
const _paid = CommissionStatus.paid;

final _p01 = [
  _c(
    'k20',
    'Coastal Hardware Mart',
    _first,
    500,
    _paid,
    monthsAgo(4, 11),
    customerId: 'c08',
    payoutId: 'p01',
  ),
  _c(
    'k19',
    'Kerala Coir Exports',
    _recurring,
    500,
    _paid,
    monthsAgo(4, 20),
    customerId: 'c04',
    payoutId: 'p01',
  ),
];

final _p02 = [
  _c(
    'k18',
    'Coastal Hardware Mart',
    _recurring,
    200,
    _paid,
    monthsAgo(3, 11),
    customerId: 'c08',
    payoutId: 'p02',
  ),
  _c(
    'k17',
    'Kerala Coir Exports',
    _recurring,
    500,
    _paid,
    monthsAgo(3, 20),
    customerId: 'c04',
    payoutId: 'p02',
  ),
  _c(
    'k16',
    'Bluewave Logistics',
    _first,
    2500,
    _paid,
    monthsAgo(3, 8),
    customerId: 'c02',
    payoutId: 'p02',
  ),
];

final _p03 = [
  _c(
    'k15',
    'Quarterly target bonus',
    _bonus,
    3000,
    _paid,
    monthsAgo(2, 28),
    payoutId: 'p03',
  ),
  _c(
    'k14',
    'Coastal Hardware Mart',
    _recurring,
    200,
    _paid,
    monthsAgo(2, 11),
    customerId: 'c08',
    payoutId: 'p03',
  ),
  _c(
    'k13',
    'Urban Threads Boutique',
    _first,
    500,
    _paid,
    monthsAgo(2, 2),
    customerId: 'c05',
    payoutId: 'p03',
  ),
  _c(
    'k12',
    'Kerala Coir Exports',
    _recurring,
    500,
    _paid,
    monthsAgo(2, 20),
    customerId: 'c04',
    payoutId: 'p03',
  ),
  _c(
    'k11',
    'Bluewave Logistics',
    _recurring,
    1000,
    _paid,
    monthsAgo(2, 8),
    customerId: 'c02',
    payoutId: 'p03',
  ),
];

final dummyCommissions = <Commission>[
  // This month — still inside the 30-day review window.
  _c(
    'k06',
    'Diwali Business Boost bonus',
    _bonus,
    2500,
    _pending,
    thisMonth(10),
  ),
  _c(
    'k02',
    'Lotus Wellness Spa',
    _first,
    1250,
    _pending,
    thisMonth(6),
    customerId: 'c09',
  ),
  _c(
    'k01',
    'Malabar Tech Services',
    _first,
    2500,
    _pending,
    thisMonth(3),
    customerId: 'c06',
  ),
  _c(
    'k05',
    'Periyar Travels',
    _recurring,
    1000,
    _pending,
    thisMonth(2),
    customerId: 'c11',
  ),
  _c(
    'k03',
    'Bluewave Logistics',
    _recurring,
    1000,
    _pending,
    thisMonth(8),
    customerId: 'c02',
  ),
  _c(
    'k04',
    'Kerala Coir Exports',
    _recurring,
    500,
    _pending,
    thisMonth(1),
    customerId: 'c04',
  ),
  // Last month — older than 30 days are approved for the next payout.
  _c(
    'k09',
    'Periyar Travels',
    _first,
    2500,
    _approved,
    monthsAgo(1, 5),
    customerId: 'c11',
  ),
  _c(
    'k07',
    'Bluewave Logistics',
    _recurring,
    1000,
    _approved,
    monthsAgo(1, 8),
    customerId: 'c02',
  ),
  _c(
    'k08',
    'Kerala Coir Exports',
    _recurring,
    500,
    _pending,
    monthsAgo(1, 20),
    customerId: 'c04',
  ),
  _c(
    'k10',
    'Urban Threads Boutique',
    _recurring,
    200,
    _approved,
    monthsAgo(1, 2),
    customerId: 'c05',
  ),
  ..._p03,
  ..._p02,
  ..._p01,
];

final dummyPayouts = <Payout>[
  Payout(
    id: 'p03',
    reference: 'GXP-${monthsAgo(1, 15).year}-0318',
    period: monthsAgo(2, 1),
    date: monthsAgo(1, 15),
    status: PayoutStatus.paid,
    method: 'HDFC Bank •••• 7812',
    commissions: _p03,
  ),
  Payout(
    id: 'p02',
    reference: 'GXP-${monthsAgo(2, 15).year}-0274',
    period: monthsAgo(3, 1),
    date: monthsAgo(2, 15),
    status: PayoutStatus.paid,
    method: 'HDFC Bank •••• 7812',
    commissions: _p02,
  ),
  Payout(
    id: 'p01',
    reference: 'GXP-${monthsAgo(3, 15).year}-0231',
    period: monthsAgo(4, 1),
    date: monthsAgo(3, 15),
    status: PayoutStatus.paid,
    method: 'HDFC Bank •••• 7812',
    commissions: _p01,
  ),
];
