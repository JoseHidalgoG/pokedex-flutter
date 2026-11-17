import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('cada esquema migra a todos los posteriores', () {
    const versions = GeneratedHelper.versions;
    for (final (index, fromVersion) in versions.indexed) {
      group('desde v$fromVersion', () {
        for (final toVersion in versions.skip(index + 1)) {
          test('hasta v$toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final database = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(database, toVersion);
            await database.close();
          });
        }
      });
    }
  });

  test('de v1 a v2 conserva catálogo y favoritos y vence la última '
      'sincronización del catálogo', () async {
    const savedAt = 1794830400;
    const favoritedAt = 1794834000;
    const artworkUrl = 'https://example.com/artwork';

    const oldPokemon = [
      v1.PokemonData(
        id: 1,
        name: 'bulbasaur',
        imageUrl: '$artworkUrl/1.png',
        updatedAt: savedAt,
      ),
      v1.PokemonData(
        id: 4,
        name: 'charmander',
        imageUrl: '$artworkUrl/4.png',
        updatedAt: savedAt,
      ),
      v1.PokemonData(
        id: 25,
        name: 'pikachu',
        imageUrl: '$artworkUrl/25.png',
        updatedAt: savedAt,
      ),
    ];
    const migratedPokemon = [
      v2.PokemonData(
        id: 1,
        name: 'bulbasaur',
        imageUrl: '$artworkUrl/1.png',
        updatedAt: savedAt,
        isDefault: 1,
      ),
      v2.PokemonData(
        id: 4,
        name: 'charmander',
        imageUrl: '$artworkUrl/4.png',
        updatedAt: savedAt,
        isDefault: 1,
      ),
      v2.PokemonData(
        id: 25,
        name: 'pikachu',
        imageUrl: '$artworkUrl/25.png',
        updatedAt: savedAt,
        isDefault: 1,
      ),
    ];

    const oldPokemonTypes = [
      v1.PokemonTypesData(pokemonId: 1, slot: 1, typeName: 'grass'),
      v1.PokemonTypesData(pokemonId: 1, slot: 2, typeName: 'poison'),
      v1.PokemonTypesData(pokemonId: 4, slot: 1, typeName: 'fire'),
      v1.PokemonTypesData(pokemonId: 25, slot: 1, typeName: 'electric'),
    ];
    const migratedPokemonTypes = [
      v2.PokemonTypesData(pokemonId: 1, slot: 1, typeName: 'grass'),
      v2.PokemonTypesData(pokemonId: 1, slot: 2, typeName: 'poison'),
      v2.PokemonTypesData(pokemonId: 4, slot: 1, typeName: 'fire'),
      v2.PokemonTypesData(pokemonId: 25, slot: 1, typeName: 'electric'),
    ];

    const oldFavorites = [
      v1.FavoritesData(pokemonId: 25, createdAt: favoritedAt),
    ];
    const migratedFavorites = [
      v2.FavoritesData(pokemonId: 25, createdAt: favoritedAt),
    ];

    const oldSyncMetadata = [
      v1.SyncMetadataData(
        key: 'catalog',
        nextOffset: 1025,
        totalCount: 1025,
        isComplete: 1,
        lastSyncedAt: savedAt,
      ),
    ];
    const migratedSyncMetadata = [
      v2.SyncMetadataData(
        key: 'catalog',
        nextOffset: 1025,
        totalCount: 1025,
        isComplete: 1,
        status: 'idle',
        attempt: 0,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDatabase) {
        batch
          ..insertAll(oldDatabase.pokemon, oldPokemon)
          ..insertAll(oldDatabase.pokemonTypes, oldPokemonTypes)
          ..insertAll(oldDatabase.favorites, oldFavorites)
          ..insertAll(oldDatabase.syncMetadata, oldSyncMetadata);
      },
      validateItems: (newDatabase) async {
        expect(
          await newDatabase.select(newDatabase.pokemon).get(),
          migratedPokemon,
        );
        expect(
          await newDatabase.select(newDatabase.pokemonTypes).get(),
          migratedPokemonTypes,
        );
        expect(
          await newDatabase.select(newDatabase.favorites).get(),
          migratedFavorites,
        );
        expect(
          await newDatabase.select(newDatabase.syncMetadata).get(),
          migratedSyncMetadata,
        );
      },
    );
  });
}
