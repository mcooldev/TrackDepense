
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class MenuItemWeb extends StatelessWidget {
  const MenuItemWeb({
    super.key,
    required this.onTap,
    required this.isSelected,
    required this.labelItem,
    required this.iconData,
  });

  final Function() onTap;
  final bool isSelected;
  final String labelItem;
  final List<List<dynamic>> iconData;

  @override
  Widget build(BuildContext context) {
    //
    final theme = Theme.of(context);
    //
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 36,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(80),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HugeIcon(
              icon: iconData,
              color: isSelected ? Colors.white : Colors.black,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              labelItem,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
