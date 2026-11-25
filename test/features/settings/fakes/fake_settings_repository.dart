import 'dart:async';

import 'package:pokedex_flutter/features/settings/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  String language = 'system';
  String theme = 'system';
  bool apiOutageSimulated = false;
  Object? apiOutageSaveError;

  final _languageController = StreamController<String>.broadcast();
  final _themeController = StreamController<String>.broadcast();

  @override
  Future<String> getLanguage() async => language;

  @override
  Future<String> getTheme() async => theme;

  @override
  Stream<String> watchLanguage() async* {
    yield language;
    yield* _languageController.stream;
  }

  @override
  Stream<String> watchTheme() async* {
    yield theme;
    yield* _themeController.stream;
  }

  @override
  Future<void> setLanguage(String value) async {
    language = value;
    _languageController.add(value);
  }

  @override
  Future<void> setTheme(String value) async {
    theme = value;
    _themeController.add(value);
  }

  @override
  Future<bool> isApiOutageSimulated() async => apiOutageSimulated;

  @override
  Future<void> setApiOutageSimulated(bool isSimulated) async {
    if (apiOutageSaveError case final error?) {
      throw error;
    }
    apiOutageSimulated = isSimulated;
  }

  Future<void> dispose() async {
    await _languageController.close();
    await _themeController.close();
  }
}
