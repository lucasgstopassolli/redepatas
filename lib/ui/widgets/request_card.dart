import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/help_request_model.dart';
import 'status_badge.dart';
import 'urgency_badge.dart';

class RequestCard extends StatelessWidget {
  final HelpRequestModel request;
  final VoidCallback onTap;
  final String? distanceLabel;

  const RequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.distanceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return RepaintBoundary(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'request_photo_${request.id}',
                  child: _AnimalAvatarThumbnail(
                    species: request.species,
                    photoPath: request.photoPath,
                    size: 64,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              request.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
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
                      const SizedBox(height: 4),
                      Text(
                        request.needsSummary,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              distanceLabel != null
                                  ? '${request.neighborhood} • ${request.city} ($distanceLabel)'
                                  : '${request.neighborhood} • ${request.city}',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 14,
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
                          if (request.status == RequestStatus.open) ...[
                            Builder(
                              builder: (_) {
                                final hours = DateTime.now()
                                    .difference(request.createdAt)
                                    .inHours;
                                if (hours < 1) return const SizedBox.shrink();
                                return Text(
                                  'Sem atendimento há ${hours}h',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: secondaryTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ],
                          if (request.status == RequestStatus.inProgress &&
                              request.helperName != null)
                            Text(
                              'Por ${request.helperName}',
                              style: TextStyle(
                                fontSize: 13,
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
                  size: 22,
                  color: secondaryTextColor,
                ),
              ],
            ),
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
    final theme = Theme.of(context);

    if (photoPath != null && photoPath!.trim().isNotEmpty) {
      if (kIsWeb ||
          photoPath!.startsWith('http') ||
          photoPath!.startsWith('blob:')) {
        return ClipRRect(
          borderRadius: AppRadius.controlRadius,
          child: Image.network(
            photoPath!,
            width: size,
            height: size,
            cacheWidth: 160,
            fit: BoxFit.cover,
          ),
        );
      }
      final file = File(photoPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: AppRadius.controlRadius,
          child: Image.file(
            file,
            width: size,
            height: size,
            cacheWidth: 160,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.controlRadius,
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          species.icon,
          size: 28,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
