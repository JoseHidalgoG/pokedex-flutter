import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/detail_texts.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

const _elapsedTimeRefreshInterval = Duration(seconds: 30);

class DetailFreshnessLine extends StatefulWidget {
  const DetailFreshnessLine({super.key, required this.freshness});

  final DetailFreshness freshness;

  @override
  State<DetailFreshnessLine> createState() => _DetailFreshnessLineState();
}

class _DetailFreshnessLineState extends State<DetailFreshnessLine> {
  Timer? _elapsedTimeTicker;

  @override
  void initState() {
    super.initState();
    _tickWhileFresh();
  }

  @override
  void didUpdateWidget(DetailFreshnessLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tickWhileFresh();
  }

  @override
  void dispose() {
    _elapsedTimeTicker?.cancel();
    super.dispose();
  }

  void _tickWhileFresh() {
    if (widget.freshness is! FreshFromPokeApi) {
      _elapsedTimeTicker?.cancel();
      _elapsedTimeTicker = null;
      return;
    }
    _elapsedTimeTicker ??= Timer.periodic(
      _elapsedTimeRefreshInterval,
      (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final text = freshnessTextOf(
      widget.freshness,
      now: DateTime.now(),
      locale: Localizations.localeOf(context).toLanguageTag(),
      l10n: l10n,
    );
    final icon = switch (widget.freshness) {
      FreshFromPokeApi() => Icons.cloud_done_outlined,
      LocalData(hasStoredDetail: true) => Icons.save_outlined,
      LocalData() => Icons.cloud_download_outlined,
    };

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
