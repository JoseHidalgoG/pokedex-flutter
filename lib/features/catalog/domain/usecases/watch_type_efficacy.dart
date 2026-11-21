import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';

class WatchTypeEfficacy {
  const WatchTypeEfficacy(this._repository);

  final PokemonDetailRepository _repository;

  Stream<List<TypeEfficacy>> call() => _repository.watchTypeEfficacy();
}
