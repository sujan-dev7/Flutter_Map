enum EsewaTransactionType {
  payment,
  topup,
  transfer,
}

class EsewaTransaction {
  final String id;
  final String title;
  final double amountNpr;
  final DateTime timestamp;
  final EsewaTransactionType type;
  final String status;
  final String recipientEsewaId;

  const EsewaTransaction({
    required this.id,
    required this.title,
    required this.amountNpr,
    required this.timestamp,
    required this.type,
    this.status = 'SUCCESS',
    required this.recipientEsewaId,
  });
}
