import 'package:flutter/material.dart';
import '../theme.dart';

/// The "EDIT" popup for Tumdak — lets the user flip which touchpad (thick /
/// thin) sits on the left vs the right. Returns the new swapped value, or
/// null if the user closed the sheet without changing anything relevant
/// (caller can just ignore a null and keep current state).
Future<bool?> showPadEditSheet(BuildContext context, {required bool currentlySwapped}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.panelDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      bool swapped = currentlySwapped;
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.edit_rounded, color: AppColors.gold),
                      SizedBox(width: 8),
                      GoldText('Edit Pads', fontSize: 18),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Swap the left/right touchpads however you like',
                    style: TextStyle(color: Colors.white54, fontSize: 12.5),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SidePreview(label: swapped ? 'Thin' : 'Thick', isLeft: true),
                      IconButton(
                        onPressed: () => setState(() => swapped = !swapped),
                        icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.goldBright, size: 34),
                        tooltip: 'Swap sides',
                      ),
                      _SidePreview(label: swapped ? 'Thick' : 'Thin', isLeft: false),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(swapped),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _SidePreview extends StatelessWidget {
  final String label;
  final bool isLeft;
  const _SidePreview({required this.label, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2C2C2C),
            border: Border.all(color: AppColors.gold.withOpacity(0.7), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            isLeft ? 'Left' : 'Right',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12)),
      ],
    );
  }
}
