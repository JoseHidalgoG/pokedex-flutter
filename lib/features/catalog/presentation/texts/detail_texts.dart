import 'package:intl/intl.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/evolution_tree.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/pokemon_texts.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

const _partSeparator = ' · ';

String freshnessTextOf(
  DetailFreshness freshness, {
  required DateTime now,
  required String locale,
  required AppLocalizations l10n,
}) {
  return switch (freshness) {
    FreshFromPokeApi(:final at) => _updatedAgoText(now.difference(at), l10n),
    LocalData(:final savedAt?) => l10n.detailLocalData(
      shortDateTimeOf(savedAt, locale),
    ),
    LocalData() => l10n.detailNotStored,
  };
}

String _updatedAgoText(Duration elapsed, AppLocalizations l10n) {
  if (elapsed.inMinutes < 1) {
    return l10n.detailFreshJustNow;
  }
  if (elapsed.inHours < 1) {
    return l10n.detailFreshMinutesAgo(elapsed.inMinutes);
  }
  return l10n.detailFreshHoursAgo(elapsed.inHours);
}

String shortDateTimeOf(DateTime dateTime, String locale) {
  final local = dateTime.toLocal();
  final day = DateFormat.Md(locale).format(local);
  final time = DateFormat('HH:mm', locale).format(local);
  return '$day$_partSeparator$time';
}

String evolutionTriggerTextOf(EvolutionTrigger trigger, AppLocalizations l10n) {
  final parts = switch (trigger) {
    LevelTrigger(:final level, :final timeOfDay) => [
      l10n.evolutionLevel(level),
      ?_timeOfDayText(timeOfDay, l10n),
    ],
    ItemTrigger(:final item) => [prettifiedIdentifier(item)],
    TradeTrigger(:final heldItem) => [
      l10n.evolutionTrade,
      ?_holdingText(heldItem, l10n),
    ],
    FriendshipTrigger(:final timeOfDay, :final knownMoveType) => [
      l10n.evolutionFriendship,
      ?_timeOfDayText(timeOfDay, l10n),
      if (knownMoveType != null)
        l10n.evolutionKnowingMoveType(localizedTypeName(knownMoveType, l10n)),
    ],
    TimeOfDayTrigger(:final timeOfDay, :final heldItem) => [
      ?_timeOfDayText(timeOfDay, l10n),
      ?_holdingText(heldItem, l10n),
    ],
    OtherTrigger(method: 'level-up') => [l10n.evolutionLevelUp],
    OtherTrigger(:final method?) => [prettifiedIdentifier(method)],
    OtherTrigger() => [l10n.evolutionOther],
  };
  return parts.join(_partSeparator);
}

String? _timeOfDayText(EvolutionTimeOfDay? timeOfDay, AppLocalizations l10n) {
  return switch (timeOfDay) {
    EvolutionTimeOfDay.day => l10n.timeOfDayDay,
    EvolutionTimeOfDay.night => l10n.timeOfDayNight,
    EvolutionTimeOfDay.dusk => l10n.timeOfDayDusk,
    null => null,
  };
}

String? _holdingText(String? item, AppLocalizations l10n) {
  return item == null
      ? null
      : l10n.evolutionHolding(prettifiedIdentifier(item));
}

String matchupTitleOf(DefensiveMatchup matchup, AppLocalizations l10n) {
  return switch (matchup) {
    DefensiveMatchup.quadrupleWeakness => l10n.matchupQuadrupleWeakness,
    DefensiveMatchup.weakness => l10n.matchupWeakness,
    DefensiveMatchup.resistance => l10n.matchupResistance,
    DefensiveMatchup.doubleResistance => l10n.matchupDoubleResistance,
    DefensiveMatchup.immunity => l10n.matchupImmunity,
  };
}

String shareTextOf(
  Pokemon pokemon, {
  required int? baseStatTotal,
  required AppLocalizations l10n,
}) {
  return [
    '${displayNameOf(pokemon.name)} ${pokedexNumberOf(pokemon.id)}',
    pokemon.typeNames
        .map((typeName) => localizedTypeName(typeName, l10n))
        .join(' / '),
    if (baseStatTotal != null) l10n.detailShareBaseTotal(baseStatTotal),
    if (pokemon.imageUrl.isNotEmpty) pokemon.imageUrl,
  ].join('\n');
}
