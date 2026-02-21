import 'package:flutter/material.dart';

class MissionCategoryWidget extends StatelessWidget {
  const MissionCategoryWidget({
    super.key,
    required this.missionTypeIcon,
    required this.missionTypeName,
    required this.onTapMissionType,
    this.isSelected = false,
    required this.isEntree,
  });

  final String missionTypeIcon;
  final String missionTypeName;
  final void Function() onTapMissionType;
  final bool isSelected, isEntree;

  @override
  Widget build(BuildContext context) {
    ///
    final theme = Theme.of(context);

    ///
    return GestureDetector(
      onTap: onTapMissionType,
      child: Column(
        children: [
          // Icône de la catégorie
          CircleAvatar(
            radius: 25,
            backgroundColor: isSelected
                ? isEntree == true ? theme.colorScheme.secondary : theme
                .colorScheme.primary : theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
            child: Text(
              missionTypeIcon,
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,
            ),
          ),
          const SizedBox(height: 4),
          // Nom de la catégorie
          Text(
            missionTypeName,
            softWrap: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme
                .of(
              context,
            )
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
