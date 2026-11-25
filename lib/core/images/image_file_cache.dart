abstract interface class ImageFileCache {
  Future<bool> isSaved(String url);

  Future<Set<String>> savedUrlsAmong(Set<String> urls);

  Future<void> save(String url);

  Future<int> savedBytes();

  Future<void> deleteAll();
}
