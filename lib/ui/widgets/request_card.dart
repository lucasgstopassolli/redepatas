import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/help_request_model.dart';
import 'status_badge.dart';
import 'urgency_badge.dart';

class RequestCard extends StatelessWidget {
  final HelpRequestModel request;
  final VoidCallback onTap;

  const RequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AnimalAvatarThumbnail(
                species: request.species,
                photoPath: request.photoPath,
                size: 84,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            request.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (request.urgency != UrgencyLevel.normal) ...[
                          const SizedBox(width: 6),
                          UrgencyBadge(urgency: request.urgency),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      request.needsSummary,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${request.neighborhood} • ${request.city}',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusBadge(status: request.status, compact: true),
                        if (request.status == RequestStatus.inProgress &&
                            request.helperName != null)
                          Text(
                            'Por ${request.helperName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalAvatarThumbnail extends StatelessWidget {
  final AnimalSpecies species;
  final String? photoPath;
  final double size;

  const _AnimalAvatarThumbnail({
    required this.species,
    required this.photoPath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (photoPath != null && photoPath!.trim().isNotEmpty && !kIsWeb) {
      final file = File(photoPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    final (Color bg, Color iconColor, IconData icon, String emoji) =
        switch (species) {
      AnimalSpecies.dog => (
          isDark ? const Color(0xFF3E2C22) : const Color(0xFFF6E7D8),
          isDark ? const Color(0xFFE5A467) : const Color(0xFFC86D32),
          Icons.pets_rounded,
          '🐕',
        ),
      AnimalSpecies.cat => (
          isDark ? const Color(0xFF343138) : const Color(0xFFEBE8EE),
          isDark ? const Color(0xFFC2B8CE) : const Color(0xFF6B5E78),
          Icons.pets_rounded,
          '🐈',
        ),
      AnimalSpecies.other => (
          isDark ? const Color(0xFF2B362C) : const Color(0xFFE4EFE5),
          isDark ? const Color(0xFF98C39B) : const Color(0xFF4A734D),
          Icons.cruelty_free_rounded,
          '🐾',
        ),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.25),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -6,
            bottom: -6,
            child: Icon(
              icon,
              size: size * 0.55,
              color: iconColor.withValues(alpha: 0.14),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: size * 0.38),
              ),
              const SizedBox(height: 2),
              Text(
                species.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
