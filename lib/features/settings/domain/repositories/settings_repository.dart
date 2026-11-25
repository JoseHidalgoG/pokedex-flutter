abstract class SettingsRepository {
  Stream<String> watchLanguage();

  Stream<String> watchTheme();

  Future<String> getLanguage();

  Future<String> getTheme();

  Future<void> setLanguage(String language);

  Future<void> setTheme(String theme);

  Future<bool> isApiOutageSimulated();

  Future<void> setApiOutageSimulated(bool isSimulated);
}
