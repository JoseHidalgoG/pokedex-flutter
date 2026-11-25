import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/network/api_outage_simulation.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/settings_providers.dart';
import 'package:pokedex_flutter/features/settings/presentation/widgets/demo_tools_section.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

import '../../fakes/fake_settings_repository.dart';

const outageSwitchLabel = 'Simular caída de PokeAPI';

void main() {
  late FakeSettingsRepository settings;

  setUp(() {
    settings = FakeSettingsRepository();
  });

  tearDown(() async {
    await settings.dispose();
  });

  Future<void> pumpSection(
    WidgetTester tester, {
    ApiOutageSimulationMode mode = ApiOutageSimulationMode.fromSettings,
    Locale locale = const Locale('es'),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiOutageSimulationModeProvider.overrideWithValue(mode),
          settingsRepositoryProvider.overrideWithValue(settings),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DemoToolsSection()),
        ),
      ),
    );
    await tester.pump();
  }

  bool isSwitchOn(WidgetTester tester) {
    return tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value;
  }

  testWidgets('muestra el interruptor con el valor guardado', (tester) async {
    settings.apiOutageSimulated = true;

    await pumpSection(tester);

    expect(find.text('Herramientas de demostración'), findsOneWidget);
    expect(find.text('Solo en compilaciones debug y profile'), findsOneWidget);
    expect(find.text(outageSwitchLabel), findsOneWidget);
    expect(find.text('Responde HTTP 503 sin salir a la red'), findsOneWidget);
    expect(isSwitchOn(tester), isTrue);
  });

  testWidgets('activarlo guarda la preferencia', (tester) async {
    await pumpSection(tester);
    expect(isSwitchOn(tester), isFalse);

    await tester.tap(find.text(outageSwitchLabel));
    await tester.pump();

    expect(isSwitchOn(tester), isTrue);
    expect(settings.apiOutageSimulated, isTrue);
  });

  testWidgets('desactivarlo guarda la preferencia', (tester) async {
    settings.apiOutageSimulated = true;
    await pumpSection(tester);

    await tester.tap(find.text(outageSwitchLabel));
    await tester.pump();

    expect(isSwitchOn(tester), isFalse);
    expect(settings.apiOutageSimulated, isFalse);
  });

  testWidgets(
    'si no se puede guardar lo avisa y la simulación sigue aplicada',
    (tester) async {
      settings.apiOutageSaveError = Exception('disco lleno');
      await pumpSection(tester);

      await tester.tap(find.text(outageSwitchLabel));
      await tester.pump();

      expect(
        find.text('No se pudo guardar el ajuste; durará hasta cerrar la app'),
        findsOneWidget,
      );
      expect(isSwitchOn(tester), isTrue);
    },
  );

  testWidgets('lanzada con SIMULATE_API_OUTAGE aparece activada', (
    tester,
  ) async {
    await pumpSection(tester, mode: ApiOutageSimulationMode.forcedAtLaunch);

    expect(isSwitchOn(tester), isTrue);
  });

  testWidgets('no aparece en compilaciones release', (tester) async {
    await pumpSection(tester, mode: ApiOutageSimulationMode.unavailable);

    expect(find.text('Herramientas de demostración'), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
  });

  testWidgets('muestra los textos en inglés', (tester) async {
    await pumpSection(tester, locale: const Locale('en'));

    expect(find.text('Demo tools'), findsOneWidget);
    expect(find.text('Simulate PokeAPI outage'), findsOneWidget);
    expect(
      find.text('Answers HTTP 503 without using the network'),
      findsOneWidget,
    );
  });
}
