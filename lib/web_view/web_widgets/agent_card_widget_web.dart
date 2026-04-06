import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../web_providers/home_web_provider.dart';

class AgentCardWidgetWeb extends StatelessWidget {
  const AgentCardWidgetWeb({
    super.key,
    required this.agent,
    this.isSelected = false,
  });

  final UserModel agent;
  final bool? isSelected;

  @override
  Widget build(BuildContext context) {
    ///
    final theme = Theme.of(context);

    ///
    return InkWell(
      onTap: () {
        context.read<HomeWebProvider>().selectedAgent = agent;
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected == true
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected == true
              ? Border.all(width: 0, color: Colors.transparent)
              : Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Name symbol
            CircleAvatar(
              radius: 40,
              backgroundColor: isSelected == true
                  ? Colors.white
                  : Colors.grey.shade100,
              child: Text(
                agent.name?.split(" ")[0].substring(0, 1).toUpperCase() ?? "I",
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // badge
            Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                color: Colors.green,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    agent.userRole?.toUpperCase() ?? "Inconnu",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // agent name
            Text(
              agent.name?.toUpperCase() ?? "Inconnu",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isSelected == true ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            // agent email
            Text(
              agent.email,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isSelected == true
                    ? Colors.white.withValues(alpha: 0.75)
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
