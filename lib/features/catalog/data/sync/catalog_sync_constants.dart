const catalogRemoteBatchSize = 100;

const catalogFullPassFreshness = Duration(hours: 1);

const visibleFreshnessWindow = Duration(minutes: 15);

const visiblePokemonSyncKey = 'catalog:visible';

const restorationSyncKey = 'catalog:restore';

const fingerprintVerificationInterval = Duration(seconds: 60);

const typeEfficacySyncKey = 'type_efficacy';

const typeEfficacyFreshness = Duration(hours: 24);

const minimumTypeCount = 18;

const detailFreshnessWindow = Duration(minutes: 5);

String detailSyncKey(int pokemonId) => 'detail:$pokemonId';
