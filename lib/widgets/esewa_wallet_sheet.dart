import 'package:flutter/material.dart';
import '../models/esewa_transaction.dart';
import '../services/esewa_service.dart';

class EsewaWalletSheet extends StatefulWidget {
  const EsewaWalletSheet({super.key});

  @override
  State<EsewaWalletSheet> createState() => _EsewaWalletSheetState();
}

class _EsewaWalletSheetState extends State<EsewaWalletSheet> {
  final EsewaService _esewaService = EsewaService.instance;

  void _showLoadWalletDialog() {
    final amountController = TextEditingController(text: '1000');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.account_balance, color: EsewaService.esewaColor),
              SizedBox(width: 8),
              Text('Load eSewa Fund'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter amount to load into your eSewa Wallet:'),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (NPR)',
                  prefixText: 'NPR ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: EsewaService.esewaColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final amt = double.tryParse(amountController.text) ?? 0;
                if (amt > 0) {
                  _esewaService.loadWallet(amt);
                  setState(() {});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully loaded NPR $amt into eSewa Wallet!')),
                  );
                }
              },
              child: const Text('Load Fund'),
            ),
          ],
        );
      },
    );
  }

  void _showSendMoneyDialog() {
    final recipientController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.send, color: EsewaService.esewaColor),
              SizedBox(width: 8),
              Text('Send eSewa Money'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: recipientController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Recipient eSewa ID / Mobile',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (NPR)',
                  prefixText: 'NPR ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: EsewaService.esewaColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final amt = double.tryParse(amountController.text) ?? 0;
                final recipient = recipientController.text.trim();

                if (amt > 0 && recipient.isNotEmpty) {
                  final success = _esewaService.makePayment(
                    title: 'Money Transfer to $recipient',
                    amountNpr: amt,
                    recipientEsewaId: recipient,
                  );

                  Navigator.pop(context);
                  setState(() {});

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transferred NPR $amt to $recipient successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Insufficient eSewa Wallet balance!')),
                    );
                  }
                }
              },
              child: const Text('Send Money'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _esewaService.balanceNpr;
    final rewardPts = _esewaService.rewardPoints;
    final userEsewaId = _esewaService.userEsewaId;
    final txs = _esewaService.transactions;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // eSewa Wallet Card Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [EsewaService.esewaColor, EsewaService.esewaDarkGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'eSewa Digital Wallet',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ID: $userEsewaId',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  'NPR ${balance.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$rewardPts Reward Points',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons: Load & Send Money
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showLoadWalletDialog,
                  icon: const Icon(Icons.add_card),
                  label: const Text('Load Fund'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EsewaService.esewaColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showSendMoneyDialog,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Money'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EsewaService.esewaDarkGreen,
                    side: const BorderSide(color: EsewaService.esewaColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Recent eSewa Transactions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Transactions List
          Expanded(
            child: txs.isEmpty
                ? const Center(child: Text('No transactions yet.'))
                : ListView.separated(
                    itemCount: txs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tx = txs[index];
                      final isTopup = tx.type == EsewaTransactionType.topup;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (isTopup ? Colors.green : Colors.redAccent).withValues(alpha: 0.15),
                          child: Icon(
                            isTopup ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isTopup ? Colors.green : Colors.redAccent,
                            size: 20,
                          ),
                        ),
                        title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          '${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')} • ${tx.id}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        trailing: Text(
                          '${isTopup ? '+' : '-'} NPR ${tx.amountNpr.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isTopup ? Colors.green.shade700 : Colors.redAccent,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
