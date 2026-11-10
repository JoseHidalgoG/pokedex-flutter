import 'package:flutter/material.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_type_chip.dart';
import 'package:pokedex_flutter/features/catalog/presentation/widgets/pokemon_cached_image.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({
    super.key,
    required this.pokemon,
  });

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final capitalizedName = pokemon.name[0].toUpperCase() +
        pokemon.name.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: Text(capitalizedName),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                '#${pokemon.id.toString().padLeft(4, '0')}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              PokemonCachedImage(
                imageUrl: pokemon.imageUrl,
                size: 220,
                errorIconSize: 120,
              ),
              const SizedBox(height: 16),
              Text(
                capitalizedName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: pokemon.typeNames
                    .map((type) => PokemonTypeChip(typeName: type))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}