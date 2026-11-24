import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/location_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/help_request_model.dart';
import '../widgets/request_card.dart';
import 'request_detail_screen.dart';

/// Mapa de pedidos (ou seletor de ponto quando [isPickerMode] = true).
class RequestsMapScreen extends StatefulWidget {
  final List<HelpRequestModel> requests;
  final bool isPickerMode;
  final LocationPoint? initialPoint;

  const RequestsMapScreen({
    super.key,
    this.requests = const [],
    this.isPickerMode = false,
    this.initialPoint,
  });

  @override
  State<RequestsMapScreen> createState() => _RequestsMapScreenState();
}

class _RequestsMapScreenState extends State<RequestsMapScreen> {
  late LatLng _pickedPoint;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPoint ?? LocationService.rioDoSulCenter;
    _pickedPoint = LatLng(p.latitude, p.longitude);
  }

  Future<void> _openExternalRoute(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showRequestSheet(BuildContext context, HelpRequestModel req) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RequestCard(
                request: req,
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RequestDetailScreen(requestId: req.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              if (req.hasCoordinates)
                OutlinedButton.icon(
                  onPressed: () =>
                      _openExternalRoute(req.latitude!, req.longitude!),
                  icon: const Icon(Icons.directions_outlined),
                  label: const Text('Abrir rota no mapa'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final mappableRequests =
        widget.requests.where((r) => r.hasCoordinates).toList();

    final mapWidget = FlutterMap(
      options: MapOptions(
        initialCenter: _pickedPoint,
        initialZoom: 13.5,
        onTap: widget.isPickerMode
            ? (_, point) => setState(() => _pickedPoint = point)
            : null,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.edu.redepatas.redepatas',
        ),
        if (widget.isPickerMode)
          MarkerLayer(
            markers: [
              Marker(
                point: _pickedPoint,
                width: 48,
                height: 48,
                child: Icon(
                  Icons.location_pin,
                  size: 46,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          )
        else
          MarkerLayer(
            markers: mappableRequests.map((req) {
              final pinColor = switch (req.urgency) {
                UrgencyLevel.critical => semantic.urgencyCriticalFg,
                UrgencyLevel.high => semantic.urgencyHighFg,
                UrgencyLevel.normal => theme.colorScheme.primary,
              };
              return Marker(
                point: LatLng(req.latitude!, req.longitude!),
                width: 48,
                height: 48,
                child: Tooltip(
                  message: req.title,
                  child: GestureDetector(
                    onTap: () => _showRequestSheet(context, req),
                    child: Container(
                      decoration: BoxDecoration(
                        color: pinColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );

    if (!widget.isPickerMode) {
      return Stack(
        children: [
          mapWidget,
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  '${mappableRequests.length} pedidos com localização no mapa. Toque em um marcador para ver detalhes.',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Marcar local no mapa')),
      body: Stack(
        children: [
          mapWidget,
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Text(
                  'Toque no mapa para posicionar o marcador onde o animal foi visto.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.lg,
            child: SafeArea(
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(
                    LocationPoint(
                      _pickedPoint.latitude,
                      _pickedPoint.longitude,
                    ),
                  );
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Confirmar localização'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
