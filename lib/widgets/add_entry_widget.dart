import 'package:flutter/material.dart';

class AddEntryWidget extends StatelessWidget {
  const AddEntryWidget({
    super.key,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.containerBg,
    required this.textEntry,
  });

  final void Function() onTap;
  final IconData icon;
  final Color iconColor;
  final Color containerBg;
  final Color textColor;
  final String textEntry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(80),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : containerBg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon for button
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            // Text for button
            Text(
              textEntry,
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontSize: 18, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
