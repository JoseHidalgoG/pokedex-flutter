const catalogRemoteBatchSize = 100;

const catalogFullPassFreshness = Duration(hours: 1);

const visibleFreshnessWindow = Duration(minutes: 15);

const visiblePokemonSyncKey = 'catalog:visible';

const restorationSyncKey = 'catalog:restore';

const fingerprintVerificationInterval = Duration(seconds: 60);
