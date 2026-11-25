import 'package:pokedex_flutter/features/settings/data/local/user_preferences_dao.dart';
import 'package:pokedex_flutter/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dao);

  final UserPreferencesDao _dao;

  static const languageKey = 'language';
  static const themeKey = 'theme';
  static const apiOutageSimulatedKey = 'simulate_api_outage';

  static const supportedLanguages = {'system', 'es', 'en'};
  static const supportedThemes = {'system', 'light', 'dark'};

  String _normalizeLanguage(String? value) {
    return supportedLanguages.contains(value) ? value! : 'system';
  }

  String _normalizeTheme(String? value) {
    return supportedThemes.contains(value) ? value! : 'system';
  }

  @override
  Stream<String> watchLanguage() {
    return _dao.watchPreference(languageKey).map(_normalizeLanguage);
  }

  @override
  Stream<String> watchTheme() {
    return _dao.watchPreference(themeKey).map(_normalizeTheme);
  }

  @override
  Future<String> getLanguage() async {
    return _normalizeLanguage(await _dao.getPreference(languageKey));
  }

  @override
  Future<String> getTheme() async {
    return _normalizeTheme(await _dao.getPreference(themeKey));
  }

  @override
  Future<void> setLanguage(String language) async {
    if (!supportedLanguages.contains(language)) {
      throw ArgumentError.value(language, 'language');
    }

    await _dao.setPreference(languageKey, language);
  }

  @override
  Future<void> setTheme(String theme) async {
    if (!supportedThemes.contains(theme)) {
      throw ArgumentError.value(theme, 'theme');
    }

    await _dao.setPreference(themeKey, theme);
  }

  @override
  Future<bool> isApiOutageSimulated() async {
    return await _dao.getPreference(apiOutageSimulatedKey) == 'true';
  }

  @override
  Future<void> setApiOutageSimulated(bool isSimulated) async {
    await _dao.setPreference(apiOutageSimulatedKey, '$isSimulated');
  }
}
