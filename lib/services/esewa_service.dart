import 'package:flutter/material.dart';
import '../models/esewa_transaction.dart';

class EsewaService extends ChangeNotifier {
  static final EsewaService instance = EsewaService._internal();

  EsewaService._internal() {
    // Seed initial transaction history
    _transactions = [
      EsewaTransaction(
        id: 'ESWA-9841029',
        title: 'Eiffel Tower Ticket Booking',
        amountNpr: 1500.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: EsewaTransactionType.payment,
        recipientEsewaId: '9841234567',
      ),
      EsewaTransaction(
        id: 'ESWA-9841011',
        title: 'Wallet Load via Bank Transfer',
        amountNpr: 5000.0,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: EsewaTransactionType.topup,
        recipientEsewaId: '9800000000',
      ),
    ];
  }

  // Official eSewa Brand Color: #60BB46
  static const esewaColor = Color(0xFF_60_BB_46);
  static const esewaDarkGreen = Color(0xFF42982B);

  String userEsewaId = '9841987654';
  String userName = 'Flutter Explorer';
  double balanceNpr = 12500.00;
  int rewardPoints = 485;

  List<EsewaTransaction> _transactions = [];

  List<EsewaTransaction> get transactions => List.unmodifiable(_transactions);

  bool makePayment({
    required String title,
    required double amountNpr,
    required String recipientEsewaId,
  }) {
    if (balanceNpr < amountNpr) {
      return false; // Insufficient Balance
    }

    balanceNpr -= amountNpr;
    rewardPoints += (amountNpr / 10).round();

    final tx = EsewaTransaction(
      id: 'ESWA-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      title: title,
      amountNpr: amountNpr,
      timestamp: DateTime.now(),
      type: EsewaTransactionType.payment,
      recipientEsewaId: recipientEsewaId,
    );

    _transactions.insert(0, tx);
    notifyListeners();
    return true;
  }

  void loadWallet(double amountNpr) {
    balanceNpr += amountNpr;
    final tx = EsewaTransaction(
      id: 'ESWA-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      title: 'Wallet Top Up via eSewa',
      amountNpr: amountNpr,
      timestamp: DateTime.now(),
      type: EsewaTransactionType.topup,
      recipientEsewaId: userEsewaId,
    );

    _transactions.insert(0, tx);
    notifyListeners();
  }
}
