String? optionalNameIn(Object? namedResource) {
  return switch (namedResource) {
    null => null,
    {'name': final String name} => name,
    _ => throw FormatException(
      'Recurso con nombre con formato inesperado',
      namedResource,
    ),
  };
}

Map<String, String> namesByLanguageIn(List<Object?> localizedNames) {
  return {
    for (final (:language, :name) in localizedNames.map(_localizedNameOf))
      language: name,
  };
}

({String language, String name}) _localizedNameOf(Object? localizedName) {
  if (localizedName case {
    'name': final String name,
    'language': {'name': final String language},
  }) {
    return (language: language, name: name);
  }
  throw FormatException(
    'Nombre traducido con formato inesperado',
    localizedName,
  );
}
