import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/settings/presentation/providers/settings_providers.dart';
import 'package:pokedex_flutter/features/settings/presentation/screens/settings_screen.dart';
import 'package:pokedex_flutter/l10n/generated/app_localizations.dart';

import '../../fakes/fake_settings_repository.dart';

void main() {
  late FakeSettingsRepository repository;

  setUp(() {
    repository = FakeSettingsRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  Future<void> pumpSettingsScreen(
    WidgetTester tester, {
    Locale? locale = const Locale('es'),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
  }

  testWidgets('muestra los controles de idioma y tema', (tester) async {
    await pumpSettingsScreen(tester);

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
  });

  testWidgets('muestra las preferencias predeterminadas', (tester) async {
    await pumpSettingsScreen(tester);

    expect(find.text('Automático (sistema)'), findsNWidgets(2));
  });

  testWidgets('permite cambiar el idioma a inglés', (tester) async {
    await pumpSettingsScreen(tester);

    final dropdowns = find.byType(DropdownButtonFormField<String>);

    await tester.tap(dropdowns.first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Inglés').last);
    await tester.pumpAndSettle();

    expect(repository.language, 'en');
  });

  testWidgets('permite seleccionar el tema oscuro', (tester) async {
    await pumpSettingsScreen(tester);

    final dropdowns = find.byType(DropdownButtonFormField<String>);

    await tester.tap(dropdowns.last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oscuro').last);
    await tester.pumpAndSettle();

    expect(repository.theme, 'dark');
  });

  testWidgets('muestra las preferencias previamente guardadas', (tester) async {
    repository.language = 'es';
    repository.theme = 'dark';

    await pumpSettingsScreen(tester);

    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);
  });

  testWidgets('muestra los textos de ajustes en inglés', (tester) async {
    await pumpSettingsScreen(tester, locale: const Locale('en'));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Select the application language'), findsOneWidget);
    expect(find.text('Select the application appearance'), findsOneWidget);
  });

  testWidgets('muestra los textos de ajustes en español', (tester) async {
    await pumpSettingsScreen(tester, locale: const Locale('es'));

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Selecciona el idioma de la aplicación'), findsOneWidget);
    expect(
      find.text('Selecciona la apariencia de la aplicación'),
      findsOneWidget,
    );
  });

  testWidgets('actualiza los textos al cambiar el idioma', (tester) async {
    await pumpSettingsScreen(tester, locale: const Locale('es'));

    expect(find.text('Ajustes'), findsOneWidget);

    await pumpSettingsScreen(tester, locale: const Locale('en'));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Ajustes'), findsNothing);
  });
}
