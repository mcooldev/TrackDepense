import 'package:flutter/material.dart';

class AddEntryWidget extends StatelessWidget {
  const AddEntryWidget({
    super.key,
    required this.onTap,
    required this.icon,
    required this.iconContainerColor,
    required this.iconColor,
    required this.textEntry,
  });

  final void Function() onTap;
  final IconData icon;
  final Color iconContainerColor;
  final Color iconColor;
  final String textEntry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(80),
          border: Border.all(
            width: 0.5,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xffebedef),
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Icon for button
            Container(
              margin: const EdgeInsets.only(right: 12),
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                color: iconContainerColor,
              ),
              child: Icon(icon, color: iconColor),
            ),
            // Text for button
            Text(
              textEntry,
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
