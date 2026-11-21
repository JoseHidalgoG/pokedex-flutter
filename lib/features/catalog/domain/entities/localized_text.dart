class LocalizedText {
  const LocalizedText({this.english, this.spanish});

  final String? english;
  final String? spanish;

  String? inLanguage(String languageCode) {
    return switch (languageCode) {
      'es' => spanish ?? english,
      _ => english ?? spanish,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is LocalizedText &&
      other.english == english &&
      other.spanish == spanish;

  @override
  int get hashCode => Object.hash(english, spanish);

  @override
  String toString() => 'LocalizedText(english: $english, spanish: $spanish)';
}
