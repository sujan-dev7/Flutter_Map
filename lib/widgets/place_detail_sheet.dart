import 'package:flutter/material.dart';
import '../models/map_place.dart';
import '../services/esewa_service.dart';
import 'esewa_checkout_dialog.dart';

class PlaceDetailSheet extends StatelessWidget {
  final MapPlace place;
  final VoidCallback onNavigateTo;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onDelete;

  const PlaceDetailSheet({
    super.key,
    required this.place,
    required this.onNavigateTo,
    required this.onToggleFavorite,
    this.onDelete,
  });

  void _openEsewaCheckout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EsewaCheckoutDialog(
        title: '${place.title} Entry / Booking Fee',
        amountNpr: place.ticketPriceNpr,
        recipientName: place.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: place.color.withValues(alpha: 0.2),
                child: Icon(place.icon, color: place.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Chip(
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: place.color.withValues(alpha: 0.15),
                          label: Text(
                            place.category.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: place.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          place.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  place.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: place.isFavorite ? Colors.redAccent : Colors.grey,
                ),
                onPressed: onToggleFavorite,
                tooltip: place.isFavorite ? 'Remove from Saved' : 'Save Place',
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: onDelete,
                  tooltip: 'Delete custom marker',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            place.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Coordinates Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  'Lat: ${place.location.latitude.toStringAsFixed(4)}, Lng: ${place.location.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // eSewa Payment Banner Button
          InkWell(
            onTap: () => _openEsewaCheckout(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: EsewaService.esewaColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: EsewaService.esewaColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: EsewaService.esewaColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entry Fee: NPR ${place.ticketPriceNpr.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: EsewaService.esewaDarkGreen,
                          ),
                        ),
                        const Text(
                          'Instant digital checkout with eSewa',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: EsewaService.esewaDarkGreen),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onNavigateTo();
              },
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Focus on Map'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
