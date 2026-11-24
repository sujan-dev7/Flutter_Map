import 'package:flutter/material.dart';
import '../services/esewa_service.dart';

class EsewaCheckoutDialog extends StatefulWidget {
  final String title;
  final double amountNpr;
  final String recipientName;

  const EsewaCheckoutDialog({
    super.key,
    required this.title,
    required this.amountNpr,
    required this.recipientName,
  });

  @override
  State<EsewaCheckoutDialog> createState() => _EsewaCheckoutDialogState();
}

class _EsewaCheckoutDialogState extends State<EsewaCheckoutDialog> {
  final _idController = TextEditingController(text: '9841987654');
  final _mpinController = TextEditingController();
  bool _isProcessing = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String _transactionId = '';

  @override
  void dispose() {
    _idController.dispose();
    _mpinController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_mpinController.text.length < 4) {
      setState(() {
        _errorMessage = 'Please enter a valid 4-digit eSewa MPIN.';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    final success = EsewaService.instance.makePayment(
      title: widget.title,
      amountNpr: widget.amountNpr,
      recipientEsewaId: _idController.text,
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
        if (success) {
          _isSuccess = true;
          _transactionId = 'ESWA-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        } else {
          _errorMessage = 'Insufficient eSewa Wallet Balance! Please load funds.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: _isSuccess ? _buildReceiptView() : _buildCheckoutView(),
      ),
    );
  }

  Widget _buildCheckoutView() {
    final balance = EsewaService.instance.balanceNpr;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // eSewa Header Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: EsewaService.esewaColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, color: EsewaService.esewaColor, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'eSewa Mobile Payment',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Secure Digital Checkout',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          'Merchant: ${widget.recipientName}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),

        // Amount Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                'NPR ${widget.amountNpr.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EsewaService.esewaDarkGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Avail. Balance: NPR ${balance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: balance >= widget.amountNpr ? Colors.green.shade700 : Colors.red,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // eSewa Mobile / ID Input
        TextField(
          controller: _idController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'eSewa ID / Mobile Number',
            prefixIcon: const Icon(Icons.phone_android, color: EsewaService.esewaColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        // MPIN Input
        TextField(
          controller: _mpinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: 'eSewa MPIN (4-Digits)',
            prefixIcon: const Icon(Icons.lock, color: EsewaService.esewaColor),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],

        const SizedBox(height: 18),

        // Confirm Pay Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: EsewaService.esewaColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'PAY NPR ${widget.amountNpr.toStringAsFixed(0)} WITH ESEWA',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: EsewaService.esewaColor,
          child: Icon(Icons.check, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 12),
        const Text(
          'Payment Successful!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: EsewaService.esewaDarkGreen),
        ),
        const SizedBox(height: 4),
        Text(
          'eSewa Ref: $_transactionId',
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.grey),
        ),
        const Divider(height: 24),

        _buildReceiptRow('Payment For', widget.title),
        _buildReceiptRow('Merchant', widget.recipientName),
        _buildReceiptRow('Amount Paid', 'NPR ${widget.amountNpr.toStringAsFixed(2)}'),
        _buildReceiptRow('Paid From', _idController.text),
        _buildReceiptRow('Status', 'COMPLETE (eSewa Verified)'),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: EsewaService.esewaColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('DONE'),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
