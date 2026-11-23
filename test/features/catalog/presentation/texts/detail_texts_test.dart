import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/evolution_tree.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';
import 'package:pokedex_flutter/features/catalog/presentation/texts/detail_texts.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

void main() {
  final spanish = lookupAppLocalizations(const Locale('es'));
  final english = lookupAppLocalizations(const Locale('en'));
  final now = DateTime(2026, 11, 23, 18, 30);

  setUpAll(initializeDateFormatting);

  group('freshnessTextOf', () {
    String freshnessText(
      DetailFreshness freshness, {
      AppLocalizations? l10n,
      String locale = 'es',
    }) {
      return freshnessTextOf(
        freshness,
        now: now,
        locale: locale,
        l10n: l10n ?? spanish,
      );
    }

    test('dice «hace un momento» en el primer minuto', () {
      expect(
        freshnessText(
          FreshFromPokeApi(now.subtract(const Duration(seconds: 59))),
        ),
        'Actualizado desde PokeAPI hace un momento',
      );
    });

    test('cuenta los minutos durante la primera hora', () {
      expect(
        freshnessText(
          FreshFromPokeApi(now.subtract(const Duration(minutes: 3))),
        ),
        'Actualizado desde PokeAPI hace 3 min',
      );
      expect(
        freshnessText(
          FreshFromPokeApi(now.subtract(const Duration(minutes: 59))),
        ),
        'Actualizado desde PokeAPI hace 59 min',
      );
    });

    test('pasa a horas después de la primera hora', () {
      expect(
        freshnessText(
          FreshFromPokeApi(now.subtract(const Duration(hours: 2, minutes: 5))),
        ),
        'Actualizado desde PokeAPI hace 2 h',
      );
    });

    test('muestra el día y la hora de los datos locales', () {
      final savedAt = DateTime(2026, 11, 10, 9, 15);

      expect(
        freshnessText(LocalData(savedAt: savedAt)),
        'Datos locales del 10/11 · 09:15',
      );
      expect(
        freshnessText(
          LocalData(savedAt: savedAt),
          l10n: english,
          locale: 'en',
        ),
        'Local data from 11/10 · 09:15',
      );
    });

    test('avisa cuando el detalle nunca se guardó', () {
      expect(
        freshnessText(const LocalData()),
        'Sin detalle guardado · se descargará con conexión',
      );
      expect(
        freshnessText(const LocalData(), l10n: english, locale: 'en'),
        'No saved detail · it will download when online',
      );
    });
  });

  group('evolutionTriggerTextOf', () {
    test('describe cada trigger en español', () {
      final expectedTexts = {
        const LevelTrigger(16): 'Nivel 16',
        const LevelTrigger(25, timeOfDay: EvolutionTimeOfDay.night):
            'Nivel 25 · De noche',
        const ItemTrigger('thunder-stone'): 'Thunder Stone',
        const TradeTrigger(): 'Intercambio',
        const TradeTrigger(heldItem: 'metal-coat'):
            'Intercambio · con Metal Coat equipado',
        const FriendshipTrigger(): 'Amistad',
        const FriendshipTrigger(timeOfDay: EvolutionTimeOfDay.day):
            'Amistad · De día',
        const FriendshipTrigger(knownMoveType: 'fairy'):
            'Amistad · con un movimiento de tipo Hada',
        const TimeOfDayTrigger(
          EvolutionTimeOfDay.night,
          heldItem: 'razor-claw',
        ): 'De noche · con Razor Claw equipado',
        const TimeOfDayTrigger(EvolutionTimeOfDay.dusk): 'Al anochecer',
        const OtherTrigger('level-up'): 'Subir de nivel',
        const OtherTrigger('three-critical-hits'): 'Three Critical Hits',
        const OtherTrigger(null): 'Otro método',
      };

      for (final MapEntry(key: trigger, value: expectedText)
          in expectedTexts.entries) {
        expect(
          evolutionTriggerTextOf(trigger, spanish),
          expectedText,
          reason: '$trigger',
        );
      }
    });

    test('describe los triggers en inglés', () {
      expect(
        evolutionTriggerTextOf(const LevelTrigger(16), english),
        'Level 16',
      );
      expect(
        evolutionTriggerTextOf(
          const FriendshipTrigger(knownMoveType: 'fairy'),
          english,
        ),
        'Friendship · knowing a Fairy move',
      );
      expect(
        evolutionTriggerTextOf(
          const TimeOfDayTrigger(
            EvolutionTimeOfDay.night,
            heldItem: 'razor-claw',
          ),
          english,
        ),
        'At night · holding Razor Claw',
      );
    });
  });

  test('titula cada grupo de matchups con su multiplicador', () {
    expect(
      [
        for (final matchup in DefensiveMatchup.values)
          matchupTitleOf(matchup, spanish),
      ],
      [
        'Muy débil · ×4',
        'Débil · ×2',
        'Resiste · ×0,5',
        'Resiste mucho · ×0,25',
        'Inmune · ×0',
      ],
    );
    expect(
      matchupTitleOf(DefensiveMatchup.resistance, english),
      'Resists · ×0.5',
    );
  });

  group('shareTextOf', () {
    const charizard = Pokemon(
      id: 6,
      name: 'charizard',
      imageUrl: 'https://example.com/6.png',
      typeNames: ['fire', 'flying'],
    );

    test('incluye nombre, número, tipos, total base e imagen', () {
      expect(
        shareTextOf(charizard, baseStatTotal: 534, l10n: spanish),
        'Charizard #0006\nFuego / Volador\nTotal base: 534\n'
        'https://example.com/6.png',
      );
    });

    test('omite el total base mientras no hay estadísticas', () {
      expect(
        shareTextOf(charizard, baseStatTotal: null, l10n: english),
        'Charizard #0006\nFire / Flying\nhttps://example.com/6.png',
      );
    });
  });
}
