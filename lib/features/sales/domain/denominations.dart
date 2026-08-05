/// The MXN denomination ladder for a cash session close count (data-model.md
/// §8). mbe-api has no denomination catalog of any kind — no table, no
/// constant, no config — so this is a client-owned constant (research.md §8).
///
/// Descending, declared as strings so a count never round-trips through
/// `double` on its way into [money.dart]. The 20-peso value appears once even
/// though it circulates as both a note and a coin: `cash_count.type`
/// distinguishes only starting-cash from counted-cash, never bills from
/// coins, so a duplicated row would only confuse the count.
const List<String> kMxnDenominations = [
  '1000',
  '500',
  '200',
  '100',
  '50',
  '20',
  '10',
  '5',
  '2',
  '1',
  '0.50',
];
