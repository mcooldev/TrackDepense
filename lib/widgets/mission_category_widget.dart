import 'package:flutter/material.dart';

class MissionCategoryWidget extends StatelessWidget {
  const MissionCategoryWidget({
    super.key,
    required this.missionTypeIcon,
    required this.missionTypeName,
    required this.onTapMissionType,
    this.isSelected = false,
  });

  final String missionTypeIcon;
  final String missionTypeName;
  final void Function() onTapMissionType;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapMissionType,
      child: Column(
        children: [
          // Icône de la catégorie
          CircleAvatar(
            radius: 25,
            backgroundColor: isSelected
                ? Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.secondary
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.surface,
            child: Text(
              missionTypeIcon,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 4),
          // Nom de la catégorie
          Text(
            missionTypeName,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
