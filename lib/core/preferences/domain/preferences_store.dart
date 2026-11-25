abstract interface class PreferencesStore {
  Future<String?> getPreference(String key);

  Stream<String?> watchPreference(String key);

  Future<void> setPreference(String key, String value);

  Future<void> deletePreference(String key);
}
