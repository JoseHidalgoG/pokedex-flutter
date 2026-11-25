import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/settings/data/local/user_preferences_dao.dart';
import 'package:pokedex_flutter/features/settings/data/repositories/settings_repository_impl.dart';

void main() {
  late AppDatabase database;
  late UserPreferencesDao dao;
  late SettingsRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = UserPreferencesDao(database);
    repository = SettingsRepositoryImpl(dao);
  });

  tearDown(() async {
    await database.close();
  });

  test('utiliza system como idioma predeterminado', () async {
    expect(await repository.getLanguage(), 'system');
  });

  test('utiliza system como tema predeterminado', () async {
    expect(await repository.getTheme(), 'system');
  });

  test('guarda y recupera el idioma seleccionado', () async {
    await repository.setLanguage('en');

    expect(await repository.getLanguage(), 'en');
  });

  test('guarda y recupera el tema seleccionado', () async {
    await repository.setTheme('dark');

    expect(await repository.getTheme(), 'dark');
  });

  test('rechaza idiomas no soportados', () async {
    await expectLater(repository.setLanguage('fr'), throwsArgumentError);
  });

  test('rechaza temas no soportados', () async {
    await expectLater(repository.setTheme('blue'), throwsArgumentError);
  });

  test('normaliza preferencias almacenadas no válidas', () async {
    await dao.setPreference('language', 'invalid');
    await dao.setPreference('theme', 'invalid');

    expect(await repository.getLanguage(), 'system');
    expect(await repository.getTheme(), 'system');
  });

  test('observa los cambios del idioma', () async {
    final stream = repository.watchLanguage().asBroadcastStream();

    expect(await stream.first, 'system');

    final nextValue = stream.firstWhere((value) => value == 'es');

    await repository.setLanguage('es');

    expect(await nextValue, 'es');
  });

  test('observa los cambios del tema', () async {
    final stream = repository.watchTheme().asBroadcastStream();

    expect(await stream.first, 'system');

    final nextValue = stream.firstWhere((value) => value == 'dark');

    await repository.setTheme('dark');

    expect(await nextValue, 'dark');
  });

  test('la simulación de caída de PokeAPI está apagada por omisión', () async {
    expect(await repository.isApiOutageSimulated(), isFalse);
  });

  test('guarda la simulación de caída como true o false', () async {
    await repository.setApiOutageSimulated(true);
    final savedOn = await dao.getPreference('simulate_api_outage');
    final readOn = await repository.isApiOutageSimulated();

    await repository.setApiOutageSimulated(false);
    final savedOff = await dao.getPreference('simulate_api_outage');
    final readOff = await repository.isApiOutageSimulated();

    expect((savedOn, readOn), ('true', true));
    expect((savedOff, readOff), ('false', false));
  });
}
