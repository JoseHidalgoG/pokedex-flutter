import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/settings/data/local/user_preferences_dao.dart';

void main() {
  late AppDatabase database;
  late UserPreferencesDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = UserPreferencesDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('devuelve null cuando la preferencia no existe', () async {
    final result = await dao.getPreference('language');

    expect(result, isNull);
  });

  test('guarda y recupera una preferencia', () async {
    await dao.setPreference('language', 'es');

    final result = await dao.getPreference('language');

    expect(result, 'es');
  });

  test('actualiza una preferencia existente', () async {
    await dao.setPreference('language', 'es');
    await dao.setPreference('language', 'en');

    final result = await dao.getPreference('language');

    expect(result, 'en');
  });

  test('elimina una preferencia', () async {
    await dao.setPreference('theme', 'dark');
    await dao.deletePreference('theme');

    final result = await dao.getPreference('theme');

    expect(result, isNull);
  });

  test('mantiene independientes las preferencias', () async {
    await dao.setPreference('language', 'es');
    await dao.setPreference('theme', 'dark');

    expect(await dao.getPreference('language'), 'es');
    expect(await dao.getPreference('theme'), 'dark');
  });

  test('notifica los cambios mediante watchPreference', () async {
    final stream = dao.watchPreference('language').asBroadcastStream();

    expect(await stream.first, isNull);

    final spanishValue = stream.firstWhere((value) => value == 'es');
    await dao.setPreference('language', 'es');
    expect(await spanishValue, 'es');

    final englishValue = stream.firstWhere((value) => value == 'en');
    await dao.setPreference('language', 'en');
    expect(await englishValue, 'en');

    final deletedValue = stream.firstWhere((value) => value == null);
    await dao.deletePreference('language');
    expect(await deletedValue, isNull);
  });
}
