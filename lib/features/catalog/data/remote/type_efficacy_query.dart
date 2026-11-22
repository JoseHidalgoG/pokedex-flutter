import 'package:graphql/client.dart';

const _typeEfficacyOperation = r'''
  query TypeEfficacy {
    typeefficacy(
      order_by: [{ damage_type_id: asc }, { target_type_id: asc }]
    ) {
      damage_factor
      type {
        name
      }
      TypeByTargetTypeId {
        name
      }
    }
  }
''';

final typeEfficacyQuery = gql(_typeEfficacyOperation);
