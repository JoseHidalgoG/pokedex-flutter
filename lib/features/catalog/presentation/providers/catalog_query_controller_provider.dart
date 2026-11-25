import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';
import 'package:pokedex_flutter/features/catalog/presentation/controllers/catalog_query_controller.dart';

final catalogQueryControllerProvider =
    AsyncNotifierProvider<CatalogQueryController, CatalogQueryState>(
      CatalogQueryController.new,
    );
