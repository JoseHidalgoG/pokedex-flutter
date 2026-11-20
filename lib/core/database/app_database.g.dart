// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PokemonTableTable extends PokemonTable
    with TableInfo<$PokemonTableTable, PokemonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _generationIdMeta = const VerificationMeta(
    'generationId',
  );
  @override
  late final GeneratedColumn<int> generationId = GeneratedColumn<int>(
    'generation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _heightDmMeta = const VerificationMeta(
    'heightDm',
  );
  @override
  late final GeneratedColumn<int> heightDm = GeneratedColumn<int>(
    'height_dm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightHgMeta = const VerificationMeta(
    'weightHg',
  );
  @override
  late final GeneratedColumn<int> weightHg = GeneratedColumn<int>(
    'weight_hg',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseStatTotalMeta = const VerificationMeta(
    'baseStatTotal',
  );
  @override
  late final GeneratedColumn<int> baseStatTotal = GeneratedColumn<int>(
    'base_stat_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteFingerprintMeta = const VerificationMeta(
    'remoteFingerprint',
  );
  @override
  late final GeneratedColumn<String> remoteFingerprint =
      GeneratedColumn<String>(
        'remote_fingerprint',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imageUrl,
    updatedAt,
    speciesId,
    generationId,
    isDefault,
    heightDm,
    weightHg,
    baseStatTotal,
    remoteFingerprint,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    }
    if (data.containsKey('generation_id')) {
      context.handle(
        _generationIdMeta,
        generationId.isAcceptableOrUnknown(
          data['generation_id']!,
          _generationIdMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('height_dm')) {
      context.handle(
        _heightDmMeta,
        heightDm.isAcceptableOrUnknown(data['height_dm']!, _heightDmMeta),
      );
    }
    if (data.containsKey('weight_hg')) {
      context.handle(
        _weightHgMeta,
        weightHg.isAcceptableOrUnknown(data['weight_hg']!, _weightHgMeta),
      );
    }
    if (data.containsKey('base_stat_total')) {
      context.handle(
        _baseStatTotalMeta,
        baseStatTotal.isAcceptableOrUnknown(
          data['base_stat_total']!,
          _baseStatTotalMeta,
        ),
      );
    }
    if (data.containsKey('remote_fingerprint')) {
      context.handle(
        _remoteFingerprintMeta,
        remoteFingerprint.isAcceptableOrUnknown(
          data['remote_fingerprint']!,
          _remoteFingerprintMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PokemonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      ),
      generationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation_id'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      heightDm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_dm'],
      ),
      weightHg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_hg'],
      ),
      baseStatTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_stat_total'],
      ),
      remoteFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_fingerprint'],
      ),
    );
  }

  @override
  $PokemonTableTable createAlias(String alias) {
    return $PokemonTableTable(attachedDatabase, alias);
  }
}

class PokemonRow extends DataClass implements Insertable<PokemonRow> {
  final int id;
  final String name;
  final String imageUrl;
  final DateTime updatedAt;
  final int? speciesId;
  final int? generationId;
  final bool isDefault;
  final int? heightDm;
  final int? weightHg;
  final int? baseStatTotal;
  final String? remoteFingerprint;
  const PokemonRow({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.updatedAt,
    this.speciesId,
    this.generationId,
    required this.isDefault,
    this.heightDm,
    this.weightHg,
    this.baseStatTotal,
    this.remoteFingerprint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['image_url'] = Variable<String>(imageUrl);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || speciesId != null) {
      map['species_id'] = Variable<int>(speciesId);
    }
    if (!nullToAbsent || generationId != null) {
      map['generation_id'] = Variable<int>(generationId);
    }
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || heightDm != null) {
      map['height_dm'] = Variable<int>(heightDm);
    }
    if (!nullToAbsent || weightHg != null) {
      map['weight_hg'] = Variable<int>(weightHg);
    }
    if (!nullToAbsent || baseStatTotal != null) {
      map['base_stat_total'] = Variable<int>(baseStatTotal);
    }
    if (!nullToAbsent || remoteFingerprint != null) {
      map['remote_fingerprint'] = Variable<String>(remoteFingerprint);
    }
    return map;
  }

  PokemonTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonTableCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: Value(imageUrl),
      updatedAt: Value(updatedAt),
      speciesId: speciesId == null && nullToAbsent
          ? const Value.absent()
          : Value(speciesId),
      generationId: generationId == null && nullToAbsent
          ? const Value.absent()
          : Value(generationId),
      isDefault: Value(isDefault),
      heightDm: heightDm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightDm),
      weightHg: weightHg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightHg),
      baseStatTotal: baseStatTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(baseStatTotal),
      remoteFingerprint: remoteFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteFingerprint),
    );
  }

  factory PokemonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      speciesId: serializer.fromJson<int?>(json['speciesId']),
      generationId: serializer.fromJson<int?>(json['generationId']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      heightDm: serializer.fromJson<int?>(json['heightDm']),
      weightHg: serializer.fromJson<int?>(json['weightHg']),
      baseStatTotal: serializer.fromJson<int?>(json['baseStatTotal']),
      remoteFingerprint: serializer.fromJson<String?>(
        json['remoteFingerprint'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'speciesId': serializer.toJson<int?>(speciesId),
      'generationId': serializer.toJson<int?>(generationId),
      'isDefault': serializer.toJson<bool>(isDefault),
      'heightDm': serializer.toJson<int?>(heightDm),
      'weightHg': serializer.toJson<int?>(weightHg),
      'baseStatTotal': serializer.toJson<int?>(baseStatTotal),
      'remoteFingerprint': serializer.toJson<String?>(remoteFingerprint),
    };
  }

  PokemonRow copyWith({
    int? id,
    String? name,
    String? imageUrl,
    DateTime? updatedAt,
    Value<int?> speciesId = const Value.absent(),
    Value<int?> generationId = const Value.absent(),
    bool? isDefault,
    Value<int?> heightDm = const Value.absent(),
    Value<int?> weightHg = const Value.absent(),
    Value<int?> baseStatTotal = const Value.absent(),
    Value<String?> remoteFingerprint = const Value.absent(),
  }) => PokemonRow(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    updatedAt: updatedAt ?? this.updatedAt,
    speciesId: speciesId.present ? speciesId.value : this.speciesId,
    generationId: generationId.present ? generationId.value : this.generationId,
    isDefault: isDefault ?? this.isDefault,
    heightDm: heightDm.present ? heightDm.value : this.heightDm,
    weightHg: weightHg.present ? weightHg.value : this.weightHg,
    baseStatTotal: baseStatTotal.present
        ? baseStatTotal.value
        : this.baseStatTotal,
    remoteFingerprint: remoteFingerprint.present
        ? remoteFingerprint.value
        : this.remoteFingerprint,
  );
  PokemonRow copyWithCompanion(PokemonTableCompanion data) {
    return PokemonRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      generationId: data.generationId.present
          ? data.generationId.value
          : this.generationId,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      heightDm: data.heightDm.present ? data.heightDm.value : this.heightDm,
      weightHg: data.weightHg.present ? data.weightHg.value : this.weightHg,
      baseStatTotal: data.baseStatTotal.present
          ? data.baseStatTotal.value
          : this.baseStatTotal,
      remoteFingerprint: data.remoteFingerprint.present
          ? data.remoteFingerprint.value
          : this.remoteFingerprint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('speciesId: $speciesId, ')
          ..write('generationId: $generationId, ')
          ..write('isDefault: $isDefault, ')
          ..write('heightDm: $heightDm, ')
          ..write('weightHg: $weightHg, ')
          ..write('baseStatTotal: $baseStatTotal, ')
          ..write('remoteFingerprint: $remoteFingerprint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imageUrl,
    updatedAt,
    speciesId,
    generationId,
    isDefault,
    heightDm,
    weightHg,
    baseStatTotal,
    remoteFingerprint,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.updatedAt == this.updatedAt &&
          other.speciesId == this.speciesId &&
          other.generationId == this.generationId &&
          other.isDefault == this.isDefault &&
          other.heightDm == this.heightDm &&
          other.weightHg == this.weightHg &&
          other.baseStatTotal == this.baseStatTotal &&
          other.remoteFingerprint == this.remoteFingerprint);
}

class PokemonTableCompanion extends UpdateCompanion<PokemonRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> imageUrl;
  final Value<DateTime> updatedAt;
  final Value<int?> speciesId;
  final Value<int?> generationId;
  final Value<bool> isDefault;
  final Value<int?> heightDm;
  final Value<int?> weightHg;
  final Value<int?> baseStatTotal;
  final Value<String?> remoteFingerprint;
  const PokemonTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.generationId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.heightDm = const Value.absent(),
    this.weightHg = const Value.absent(),
    this.baseStatTotal = const Value.absent(),
    this.remoteFingerprint = const Value.absent(),
  });
  PokemonTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String imageUrl,
    required DateTime updatedAt,
    this.speciesId = const Value.absent(),
    this.generationId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.heightDm = const Value.absent(),
    this.weightHg = const Value.absent(),
    this.baseStatTotal = const Value.absent(),
    this.remoteFingerprint = const Value.absent(),
  }) : name = Value(name),
       imageUrl = Value(imageUrl),
       updatedAt = Value(updatedAt);
  static Insertable<PokemonRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<DateTime>? updatedAt,
    Expression<int>? speciesId,
    Expression<int>? generationId,
    Expression<bool>? isDefault,
    Expression<int>? heightDm,
    Expression<int>? weightHg,
    Expression<int>? baseStatTotal,
    Expression<String>? remoteFingerprint,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (speciesId != null) 'species_id': speciesId,
      if (generationId != null) 'generation_id': generationId,
      if (isDefault != null) 'is_default': isDefault,
      if (heightDm != null) 'height_dm': heightDm,
      if (weightHg != null) 'weight_hg': weightHg,
      if (baseStatTotal != null) 'base_stat_total': baseStatTotal,
      if (remoteFingerprint != null) 'remote_fingerprint': remoteFingerprint,
    });
  }

  PokemonTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? imageUrl,
    Value<DateTime>? updatedAt,
    Value<int?>? speciesId,
    Value<int?>? generationId,
    Value<bool>? isDefault,
    Value<int?>? heightDm,
    Value<int?>? weightHg,
    Value<int?>? baseStatTotal,
    Value<String?>? remoteFingerprint,
  }) {
    return PokemonTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      speciesId: speciesId ?? this.speciesId,
      generationId: generationId ?? this.generationId,
      isDefault: isDefault ?? this.isDefault,
      heightDm: heightDm ?? this.heightDm,
      weightHg: weightHg ?? this.weightHg,
      baseStatTotal: baseStatTotal ?? this.baseStatTotal,
      remoteFingerprint: remoteFingerprint ?? this.remoteFingerprint,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (generationId.present) {
      map['generation_id'] = Variable<int>(generationId.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (heightDm.present) {
      map['height_dm'] = Variable<int>(heightDm.value);
    }
    if (weightHg.present) {
      map['weight_hg'] = Variable<int>(weightHg.value);
    }
    if (baseStatTotal.present) {
      map['base_stat_total'] = Variable<int>(baseStatTotal.value);
    }
    if (remoteFingerprint.present) {
      map['remote_fingerprint'] = Variable<String>(remoteFingerprint.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('speciesId: $speciesId, ')
          ..write('generationId: $generationId, ')
          ..write('isDefault: $isDefault, ')
          ..write('heightDm: $heightDm, ')
          ..write('weightHg: $weightHg, ')
          ..write('baseStatTotal: $baseStatTotal, ')
          ..write('remoteFingerprint: $remoteFingerprint')
          ..write(')'))
        .toString();
  }
}

class $PokemonTypesTableTable extends PokemonTypesTable
    with TableInfo<$PokemonTypesTableTable, PokemonTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonTypesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeNameMeta = const VerificationMeta(
    'typeName',
  );
  @override
  late final GeneratedColumn<String> typeName = GeneratedColumn<String>(
    'type_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pokemonId, slot, typeName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('type_name')) {
      context.handle(
        _typeNameMeta,
        typeName.isAcceptableOrUnknown(data['type_name']!, _typeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_typeNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId, slot};
  @override
  PokemonTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonTypeRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      typeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_name'],
      )!,
    );
  }

  @override
  $PokemonTypesTableTable createAlias(String alias) {
    return $PokemonTypesTableTable(attachedDatabase, alias);
  }
}

class PokemonTypeRow extends DataClass implements Insertable<PokemonTypeRow> {
  final int pokemonId;
  final int slot;
  final String typeName;
  const PokemonTypeRow({
    required this.pokemonId,
    required this.slot,
    required this.typeName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['slot'] = Variable<int>(slot);
    map['type_name'] = Variable<String>(typeName);
    return map;
  }

  PokemonTypesTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonTypesTableCompanion(
      pokemonId: Value(pokemonId),
      slot: Value(slot),
      typeName: Value(typeName),
    );
  }

  factory PokemonTypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonTypeRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      slot: serializer.fromJson<int>(json['slot']),
      typeName: serializer.fromJson<String>(json['typeName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'slot': serializer.toJson<int>(slot),
      'typeName': serializer.toJson<String>(typeName),
    };
  }

  PokemonTypeRow copyWith({int? pokemonId, int? slot, String? typeName}) =>
      PokemonTypeRow(
        pokemonId: pokemonId ?? this.pokemonId,
        slot: slot ?? this.slot,
        typeName: typeName ?? this.typeName,
      );
  PokemonTypeRow copyWithCompanion(PokemonTypesTableCompanion data) {
    return PokemonTypeRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      slot: data.slot.present ? data.slot.value : this.slot,
      typeName: data.typeName.present ? data.typeName.value : this.typeName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTypeRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('slot: $slot, ')
          ..write('typeName: $typeName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, slot, typeName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonTypeRow &&
          other.pokemonId == this.pokemonId &&
          other.slot == this.slot &&
          other.typeName == this.typeName);
}

class PokemonTypesTableCompanion extends UpdateCompanion<PokemonTypeRow> {
  final Value<int> pokemonId;
  final Value<int> slot;
  final Value<String> typeName;
  final Value<int> rowid;
  const PokemonTypesTableCompanion({
    this.pokemonId = const Value.absent(),
    this.slot = const Value.absent(),
    this.typeName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonTypesTableCompanion.insert({
    required int pokemonId,
    required int slot,
    required String typeName,
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       slot = Value(slot),
       typeName = Value(typeName);
  static Insertable<PokemonTypeRow> custom({
    Expression<int>? pokemonId,
    Expression<int>? slot,
    Expression<String>? typeName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (slot != null) 'slot': slot,
      if (typeName != null) 'type_name': typeName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonTypesTableCompanion copyWith({
    Value<int>? pokemonId,
    Value<int>? slot,
    Value<String>? typeName,
    Value<int>? rowid,
  }) {
    return PokemonTypesTableCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      slot: slot ?? this.slot,
      typeName: typeName ?? this.typeName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (typeName.present) {
      map['type_name'] = Variable<String>(typeName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTypesTableCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('slot: $slot, ')
          ..write('typeName: $typeName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PokemonStatsTableTable extends PokemonStatsTable
    with TableInfo<$PokemonStatsTableTable, PokemonStatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonStatsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statNameMeta = const VerificationMeta(
    'statName',
  );
  @override
  late final GeneratedColumn<String> statName = GeneratedColumn<String>(
    'stat_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseStatMeta = const VerificationMeta(
    'baseStat',
  );
  @override
  late final GeneratedColumn<int> baseStat = GeneratedColumn<int>(
    'base_stat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pokemonId, statName, baseStat];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonStatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('stat_name')) {
      context.handle(
        _statNameMeta,
        statName.isAcceptableOrUnknown(data['stat_name']!, _statNameMeta),
      );
    } else if (isInserting) {
      context.missing(_statNameMeta);
    }
    if (data.containsKey('base_stat')) {
      context.handle(
        _baseStatMeta,
        baseStat.isAcceptableOrUnknown(data['base_stat']!, _baseStatMeta),
      );
    } else if (isInserting) {
      context.missing(_baseStatMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId, statName};
  @override
  PokemonStatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonStatRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      statName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stat_name'],
      )!,
      baseStat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_stat'],
      )!,
    );
  }

  @override
  $PokemonStatsTableTable createAlias(String alias) {
    return $PokemonStatsTableTable(attachedDatabase, alias);
  }
}

class PokemonStatRow extends DataClass implements Insertable<PokemonStatRow> {
  final int pokemonId;
  final String statName;
  final int baseStat;
  const PokemonStatRow({
    required this.pokemonId,
    required this.statName,
    required this.baseStat,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['stat_name'] = Variable<String>(statName);
    map['base_stat'] = Variable<int>(baseStat);
    return map;
  }

  PokemonStatsTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonStatsTableCompanion(
      pokemonId: Value(pokemonId),
      statName: Value(statName),
      baseStat: Value(baseStat),
    );
  }

  factory PokemonStatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonStatRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      statName: serializer.fromJson<String>(json['statName']),
      baseStat: serializer.fromJson<int>(json['baseStat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'statName': serializer.toJson<String>(statName),
      'baseStat': serializer.toJson<int>(baseStat),
    };
  }

  PokemonStatRow copyWith({int? pokemonId, String? statName, int? baseStat}) =>
      PokemonStatRow(
        pokemonId: pokemonId ?? this.pokemonId,
        statName: statName ?? this.statName,
        baseStat: baseStat ?? this.baseStat,
      );
  PokemonStatRow copyWithCompanion(PokemonStatsTableCompanion data) {
    return PokemonStatRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      statName: data.statName.present ? data.statName.value : this.statName,
      baseStat: data.baseStat.present ? data.baseStat.value : this.baseStat,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonStatRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('statName: $statName, ')
          ..write('baseStat: $baseStat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, statName, baseStat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonStatRow &&
          other.pokemonId == this.pokemonId &&
          other.statName == this.statName &&
          other.baseStat == this.baseStat);
}

class PokemonStatsTableCompanion extends UpdateCompanion<PokemonStatRow> {
  final Value<int> pokemonId;
  final Value<String> statName;
  final Value<int> baseStat;
  final Value<int> rowid;
  const PokemonStatsTableCompanion({
    this.pokemonId = const Value.absent(),
    this.statName = const Value.absent(),
    this.baseStat = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonStatsTableCompanion.insert({
    required int pokemonId,
    required String statName,
    required int baseStat,
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       statName = Value(statName),
       baseStat = Value(baseStat);
  static Insertable<PokemonStatRow> custom({
    Expression<int>? pokemonId,
    Expression<String>? statName,
    Expression<int>? baseStat,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (statName != null) 'stat_name': statName,
      if (baseStat != null) 'base_stat': baseStat,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonStatsTableCompanion copyWith({
    Value<int>? pokemonId,
    Value<String>? statName,
    Value<int>? baseStat,
    Value<int>? rowid,
  }) {
    return PokemonStatsTableCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      statName: statName ?? this.statName,
      baseStat: baseStat ?? this.baseStat,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (statName.present) {
      map['stat_name'] = Variable<String>(statName.value);
    }
    if (baseStat.present) {
      map['base_stat'] = Variable<int>(baseStat.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonStatsTableCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('statName: $statName, ')
          ..write('baseStat: $baseStat, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpeciesTableTable extends SpeciesTable
    with TableInfo<$SpeciesTableTable, SpeciesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generationIdMeta = const VerificationMeta(
    'generationId',
  );
  @override
  late final GeneratedColumn<int> generationId = GeneratedColumn<int>(
    'generation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _evolutionChainIdMeta = const VerificationMeta(
    'evolutionChainId',
  );
  @override
  late final GeneratedColumn<int> evolutionChainId = GeneratedColumn<int>(
    'evolution_chain_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    generationId,
    evolutionChainId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('generation_id')) {
      context.handle(
        _generationIdMeta,
        generationId.isAcceptableOrUnknown(
          data['generation_id']!,
          _generationIdMeta,
        ),
      );
    }
    if (data.containsKey('evolution_chain_id')) {
      context.handle(
        _evolutionChainIdMeta,
        evolutionChainId.isAcceptableOrUnknown(
          data['evolution_chain_id']!,
          _evolutionChainIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      generationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation_id'],
      ),
      evolutionChainId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}evolution_chain_id'],
      ),
    );
  }

  @override
  $SpeciesTableTable createAlias(String alias) {
    return $SpeciesTableTable(attachedDatabase, alias);
  }
}

class SpeciesRow extends DataClass implements Insertable<SpeciesRow> {
  final int id;
  final String name;
  final int? generationId;
  final int? evolutionChainId;
  const SpeciesRow({
    required this.id,
    required this.name,
    this.generationId,
    this.evolutionChainId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || generationId != null) {
      map['generation_id'] = Variable<int>(generationId);
    }
    if (!nullToAbsent || evolutionChainId != null) {
      map['evolution_chain_id'] = Variable<int>(evolutionChainId);
    }
    return map;
  }

  SpeciesTableCompanion toCompanion(bool nullToAbsent) {
    return SpeciesTableCompanion(
      id: Value(id),
      name: Value(name),
      generationId: generationId == null && nullToAbsent
          ? const Value.absent()
          : Value(generationId),
      evolutionChainId: evolutionChainId == null && nullToAbsent
          ? const Value.absent()
          : Value(evolutionChainId),
    );
  }

  factory SpeciesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      generationId: serializer.fromJson<int?>(json['generationId']),
      evolutionChainId: serializer.fromJson<int?>(json['evolutionChainId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'generationId': serializer.toJson<int?>(generationId),
      'evolutionChainId': serializer.toJson<int?>(evolutionChainId),
    };
  }

  SpeciesRow copyWith({
    int? id,
    String? name,
    Value<int?> generationId = const Value.absent(),
    Value<int?> evolutionChainId = const Value.absent(),
  }) => SpeciesRow(
    id: id ?? this.id,
    name: name ?? this.name,
    generationId: generationId.present ? generationId.value : this.generationId,
    evolutionChainId: evolutionChainId.present
        ? evolutionChainId.value
        : this.evolutionChainId,
  );
  SpeciesRow copyWithCompanion(SpeciesTableCompanion data) {
    return SpeciesRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      generationId: data.generationId.present
          ? data.generationId.value
          : this.generationId,
      evolutionChainId: data.evolutionChainId.present
          ? data.evolutionChainId.value
          : this.evolutionChainId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('generationId: $generationId, ')
          ..write('evolutionChainId: $evolutionChainId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, generationId, evolutionChainId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.generationId == this.generationId &&
          other.evolutionChainId == this.evolutionChainId);
}

class SpeciesTableCompanion extends UpdateCompanion<SpeciesRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> generationId;
  final Value<int?> evolutionChainId;
  const SpeciesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.generationId = const Value.absent(),
    this.evolutionChainId = const Value.absent(),
  });
  SpeciesTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.generationId = const Value.absent(),
    this.evolutionChainId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<SpeciesRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? generationId,
    Expression<int>? evolutionChainId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (generationId != null) 'generation_id': generationId,
      if (evolutionChainId != null) 'evolution_chain_id': evolutionChainId,
    });
  }

  SpeciesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? generationId,
    Value<int?>? evolutionChainId,
  }) {
    return SpeciesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      generationId: generationId ?? this.generationId,
      evolutionChainId: evolutionChainId ?? this.evolutionChainId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (generationId.present) {
      map['generation_id'] = Variable<int>(generationId.value);
    }
    if (evolutionChainId.present) {
      map['evolution_chain_id'] = Variable<int>(evolutionChainId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('generationId: $generationId, ')
          ..write('evolutionChainId: $evolutionChainId')
          ..write(')'))
        .toString();
  }
}

class $SpeciesEggGroupsTableTable extends SpeciesEggGroupsTable
    with TableInfo<$SpeciesEggGroupsTableTable, SpeciesEggGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesEggGroupsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES species (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _eggGroupMeta = const VerificationMeta(
    'eggGroup',
  );
  @override
  late final GeneratedColumn<String> eggGroup = GeneratedColumn<String>(
    'egg_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [speciesId, eggGroup];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_egg_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesEggGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('egg_group')) {
      context.handle(
        _eggGroupMeta,
        eggGroup.isAcceptableOrUnknown(data['egg_group']!, _eggGroupMeta),
      );
    } else if (isInserting) {
      context.missing(_eggGroupMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {speciesId, eggGroup};
  @override
  SpeciesEggGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesEggGroupRow(
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      eggGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}egg_group'],
      )!,
    );
  }

  @override
  $SpeciesEggGroupsTableTable createAlias(String alias) {
    return $SpeciesEggGroupsTableTable(attachedDatabase, alias);
  }
}

class SpeciesEggGroupRow extends DataClass
    implements Insertable<SpeciesEggGroupRow> {
  final int speciesId;
  final String eggGroup;
  const SpeciesEggGroupRow({required this.speciesId, required this.eggGroup});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['species_id'] = Variable<int>(speciesId);
    map['egg_group'] = Variable<String>(eggGroup);
    return map;
  }

  SpeciesEggGroupsTableCompanion toCompanion(bool nullToAbsent) {
    return SpeciesEggGroupsTableCompanion(
      speciesId: Value(speciesId),
      eggGroup: Value(eggGroup),
    );
  }

  factory SpeciesEggGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesEggGroupRow(
      speciesId: serializer.fromJson<int>(json['speciesId']),
      eggGroup: serializer.fromJson<String>(json['eggGroup']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'speciesId': serializer.toJson<int>(speciesId),
      'eggGroup': serializer.toJson<String>(eggGroup),
    };
  }

  SpeciesEggGroupRow copyWith({int? speciesId, String? eggGroup}) =>
      SpeciesEggGroupRow(
        speciesId: speciesId ?? this.speciesId,
        eggGroup: eggGroup ?? this.eggGroup,
      );
  SpeciesEggGroupRow copyWithCompanion(SpeciesEggGroupsTableCompanion data) {
    return SpeciesEggGroupRow(
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      eggGroup: data.eggGroup.present ? data.eggGroup.value : this.eggGroup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesEggGroupRow(')
          ..write('speciesId: $speciesId, ')
          ..write('eggGroup: $eggGroup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(speciesId, eggGroup);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesEggGroupRow &&
          other.speciesId == this.speciesId &&
          other.eggGroup == this.eggGroup);
}

class SpeciesEggGroupsTableCompanion
    extends UpdateCompanion<SpeciesEggGroupRow> {
  final Value<int> speciesId;
  final Value<String> eggGroup;
  final Value<int> rowid;
  const SpeciesEggGroupsTableCompanion({
    this.speciesId = const Value.absent(),
    this.eggGroup = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpeciesEggGroupsTableCompanion.insert({
    required int speciesId,
    required String eggGroup,
    this.rowid = const Value.absent(),
  }) : speciesId = Value(speciesId),
       eggGroup = Value(eggGroup);
  static Insertable<SpeciesEggGroupRow> custom({
    Expression<int>? speciesId,
    Expression<String>? eggGroup,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (speciesId != null) 'species_id': speciesId,
      if (eggGroup != null) 'egg_group': eggGroup,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpeciesEggGroupsTableCompanion copyWith({
    Value<int>? speciesId,
    Value<String>? eggGroup,
    Value<int>? rowid,
  }) {
    return SpeciesEggGroupsTableCompanion(
      speciesId: speciesId ?? this.speciesId,
      eggGroup: eggGroup ?? this.eggGroup,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (eggGroup.present) {
      map['egg_group'] = Variable<String>(eggGroup.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesEggGroupsTableCompanion(')
          ..write('speciesId: $speciesId, ')
          ..write('eggGroup: $eggGroup, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AbilitiesTableTable extends AbilitiesTable
    with TableInfo<$AbilitiesTableTable, AbilityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AbilitiesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEsMeta = const VerificationMeta('nameEs');
  @override
  late final GeneratedColumn<String> nameEs = GeneratedColumn<String>(
    'name_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shortEffectEsMeta = const VerificationMeta(
    'shortEffectEs',
  );
  @override
  late final GeneratedColumn<String> shortEffectEs = GeneratedColumn<String>(
    'short_effect_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shortEffectEnMeta = const VerificationMeta(
    'shortEffectEn',
  );
  @override
  late final GeneratedColumn<String> shortEffectEn = GeneratedColumn<String>(
    'short_effect_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameEs,
    shortEffectEs,
    shortEffectEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'abilities';
  @override
  VerificationContext validateIntegrity(
    Insertable<AbilityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_es')) {
      context.handle(
        _nameEsMeta,
        nameEs.isAcceptableOrUnknown(data['name_es']!, _nameEsMeta),
      );
    }
    if (data.containsKey('short_effect_es')) {
      context.handle(
        _shortEffectEsMeta,
        shortEffectEs.isAcceptableOrUnknown(
          data['short_effect_es']!,
          _shortEffectEsMeta,
        ),
      );
    }
    if (data.containsKey('short_effect_en')) {
      context.handle(
        _shortEffectEnMeta,
        shortEffectEn.isAcceptableOrUnknown(
          data['short_effect_en']!,
          _shortEffectEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AbilityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AbilityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_es'],
      ),
      shortEffectEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_effect_es'],
      ),
      shortEffectEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_effect_en'],
      ),
    );
  }

  @override
  $AbilitiesTableTable createAlias(String alias) {
    return $AbilitiesTableTable(attachedDatabase, alias);
  }
}

class AbilityRow extends DataClass implements Insertable<AbilityRow> {
  final int id;
  final String name;
  final String? nameEs;
  final String? shortEffectEs;
  final String? shortEffectEn;
  const AbilityRow({
    required this.id,
    required this.name,
    this.nameEs,
    this.shortEffectEs,
    this.shortEffectEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameEs != null) {
      map['name_es'] = Variable<String>(nameEs);
    }
    if (!nullToAbsent || shortEffectEs != null) {
      map['short_effect_es'] = Variable<String>(shortEffectEs);
    }
    if (!nullToAbsent || shortEffectEn != null) {
      map['short_effect_en'] = Variable<String>(shortEffectEn);
    }
    return map;
  }

  AbilitiesTableCompanion toCompanion(bool nullToAbsent) {
    return AbilitiesTableCompanion(
      id: Value(id),
      name: Value(name),
      nameEs: nameEs == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEs),
      shortEffectEs: shortEffectEs == null && nullToAbsent
          ? const Value.absent()
          : Value(shortEffectEs),
      shortEffectEn: shortEffectEn == null && nullToAbsent
          ? const Value.absent()
          : Value(shortEffectEn),
    );
  }

  factory AbilityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AbilityRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameEs: serializer.fromJson<String?>(json['nameEs']),
      shortEffectEs: serializer.fromJson<String?>(json['shortEffectEs']),
      shortEffectEn: serializer.fromJson<String?>(json['shortEffectEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameEs': serializer.toJson<String?>(nameEs),
      'shortEffectEs': serializer.toJson<String?>(shortEffectEs),
      'shortEffectEn': serializer.toJson<String?>(shortEffectEn),
    };
  }

  AbilityRow copyWith({
    int? id,
    String? name,
    Value<String?> nameEs = const Value.absent(),
    Value<String?> shortEffectEs = const Value.absent(),
    Value<String?> shortEffectEn = const Value.absent(),
  }) => AbilityRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameEs: nameEs.present ? nameEs.value : this.nameEs,
    shortEffectEs: shortEffectEs.present
        ? shortEffectEs.value
        : this.shortEffectEs,
    shortEffectEn: shortEffectEn.present
        ? shortEffectEn.value
        : this.shortEffectEn,
  );
  AbilityRow copyWithCompanion(AbilitiesTableCompanion data) {
    return AbilityRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameEs: data.nameEs.present ? data.nameEs.value : this.nameEs,
      shortEffectEs: data.shortEffectEs.present
          ? data.shortEffectEs.value
          : this.shortEffectEs,
      shortEffectEn: data.shortEffectEn.present
          ? data.shortEffectEn.value
          : this.shortEffectEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AbilityRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEs: $nameEs, ')
          ..write('shortEffectEs: $shortEffectEs, ')
          ..write('shortEffectEn: $shortEffectEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, nameEs, shortEffectEs, shortEffectEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AbilityRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameEs == this.nameEs &&
          other.shortEffectEs == this.shortEffectEs &&
          other.shortEffectEn == this.shortEffectEn);
}

class AbilitiesTableCompanion extends UpdateCompanion<AbilityRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> nameEs;
  final Value<String?> shortEffectEs;
  final Value<String?> shortEffectEn;
  const AbilitiesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameEs = const Value.absent(),
    this.shortEffectEs = const Value.absent(),
    this.shortEffectEn = const Value.absent(),
  });
  AbilitiesTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nameEs = const Value.absent(),
    this.shortEffectEs = const Value.absent(),
    this.shortEffectEn = const Value.absent(),
  }) : name = Value(name);
  static Insertable<AbilityRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameEs,
    Expression<String>? shortEffectEs,
    Expression<String>? shortEffectEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameEs != null) 'name_es': nameEs,
      if (shortEffectEs != null) 'short_effect_es': shortEffectEs,
      if (shortEffectEn != null) 'short_effect_en': shortEffectEn,
    });
  }

  AbilitiesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? nameEs,
    Value<String?>? shortEffectEs,
    Value<String?>? shortEffectEn,
  }) {
    return AbilitiesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEs: nameEs ?? this.nameEs,
      shortEffectEs: shortEffectEs ?? this.shortEffectEs,
      shortEffectEn: shortEffectEn ?? this.shortEffectEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameEs.present) {
      map['name_es'] = Variable<String>(nameEs.value);
    }
    if (shortEffectEs.present) {
      map['short_effect_es'] = Variable<String>(shortEffectEs.value);
    }
    if (shortEffectEn.present) {
      map['short_effect_en'] = Variable<String>(shortEffectEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbilitiesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEs: $nameEs, ')
          ..write('shortEffectEs: $shortEffectEs, ')
          ..write('shortEffectEn: $shortEffectEn')
          ..write(')'))
        .toString();
  }
}

class $PokemonAbilitiesTableTable extends PokemonAbilitiesTable
    with TableInfo<$PokemonAbilitiesTableTable, PokemonAbilityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonAbilitiesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _abilityIdMeta = const VerificationMeta(
    'abilityId',
  );
  @override
  late final GeneratedColumn<int> abilityId = GeneratedColumn<int>(
    'ability_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [pokemonId, abilityId, slot, isHidden];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_abilities';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonAbilityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('ability_id')) {
      context.handle(
        _abilityIdMeta,
        abilityId.isAcceptableOrUnknown(data['ability_id']!, _abilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_abilityIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    } else if (isInserting) {
      context.missing(_isHiddenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId, slot};
  @override
  PokemonAbilityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonAbilityRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      abilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ability_id'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
    );
  }

  @override
  $PokemonAbilitiesTableTable createAlias(String alias) {
    return $PokemonAbilitiesTableTable(attachedDatabase, alias);
  }
}

class PokemonAbilityRow extends DataClass
    implements Insertable<PokemonAbilityRow> {
  final int pokemonId;
  final int abilityId;
  final int slot;
  final bool isHidden;
  const PokemonAbilityRow({
    required this.pokemonId,
    required this.abilityId,
    required this.slot,
    required this.isHidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['ability_id'] = Variable<int>(abilityId);
    map['slot'] = Variable<int>(slot);
    map['is_hidden'] = Variable<bool>(isHidden);
    return map;
  }

  PokemonAbilitiesTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonAbilitiesTableCompanion(
      pokemonId: Value(pokemonId),
      abilityId: Value(abilityId),
      slot: Value(slot),
      isHidden: Value(isHidden),
    );
  }

  factory PokemonAbilityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonAbilityRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      abilityId: serializer.fromJson<int>(json['abilityId']),
      slot: serializer.fromJson<int>(json['slot']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'abilityId': serializer.toJson<int>(abilityId),
      'slot': serializer.toJson<int>(slot),
      'isHidden': serializer.toJson<bool>(isHidden),
    };
  }

  PokemonAbilityRow copyWith({
    int? pokemonId,
    int? abilityId,
    int? slot,
    bool? isHidden,
  }) => PokemonAbilityRow(
    pokemonId: pokemonId ?? this.pokemonId,
    abilityId: abilityId ?? this.abilityId,
    slot: slot ?? this.slot,
    isHidden: isHidden ?? this.isHidden,
  );
  PokemonAbilityRow copyWithCompanion(PokemonAbilitiesTableCompanion data) {
    return PokemonAbilityRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      abilityId: data.abilityId.present ? data.abilityId.value : this.abilityId,
      slot: data.slot.present ? data.slot.value : this.slot,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonAbilityRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('abilityId: $abilityId, ')
          ..write('slot: $slot, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, abilityId, slot, isHidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonAbilityRow &&
          other.pokemonId == this.pokemonId &&
          other.abilityId == this.abilityId &&
          other.slot == this.slot &&
          other.isHidden == this.isHidden);
}

class PokemonAbilitiesTableCompanion
    extends UpdateCompanion<PokemonAbilityRow> {
  final Value<int> pokemonId;
  final Value<int> abilityId;
  final Value<int> slot;
  final Value<bool> isHidden;
  final Value<int> rowid;
  const PokemonAbilitiesTableCompanion({
    this.pokemonId = const Value.absent(),
    this.abilityId = const Value.absent(),
    this.slot = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonAbilitiesTableCompanion.insert({
    required int pokemonId,
    required int abilityId,
    required int slot,
    required bool isHidden,
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       abilityId = Value(abilityId),
       slot = Value(slot),
       isHidden = Value(isHidden);
  static Insertable<PokemonAbilityRow> custom({
    Expression<int>? pokemonId,
    Expression<int>? abilityId,
    Expression<int>? slot,
    Expression<bool>? isHidden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (abilityId != null) 'ability_id': abilityId,
      if (slot != null) 'slot': slot,
      if (isHidden != null) 'is_hidden': isHidden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonAbilitiesTableCompanion copyWith({
    Value<int>? pokemonId,
    Value<int>? abilityId,
    Value<int>? slot,
    Value<bool>? isHidden,
    Value<int>? rowid,
  }) {
    return PokemonAbilitiesTableCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      abilityId: abilityId ?? this.abilityId,
      slot: slot ?? this.slot,
      isHidden: isHidden ?? this.isHidden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (abilityId.present) {
      map['ability_id'] = Variable<int>(abilityId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonAbilitiesTableCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('abilityId: $abilityId, ')
          ..write('slot: $slot, ')
          ..write('isHidden: $isHidden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovesTableTable extends MovesTable
    with TableInfo<$MovesTableTable, MoveRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEsMeta = const VerificationMeta('nameEs');
  @override
  late final GeneratedColumn<String> nameEs = GeneratedColumn<String>(
    'name_es',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeNameMeta = const VerificationMeta(
    'typeName',
  );
  @override
  late final GeneratedColumn<String> typeName = GeneratedColumn<String>(
    'type_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, nameEs, typeName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'moves';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoveRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_es')) {
      context.handle(
        _nameEsMeta,
        nameEs.isAcceptableOrUnknown(data['name_es']!, _nameEsMeta),
      );
    }
    if (data.containsKey('type_name')) {
      context.handle(
        _typeNameMeta,
        typeName.isAcceptableOrUnknown(data['type_name']!, _typeNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoveRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoveRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameEs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_es'],
      ),
      typeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_name'],
      ),
    );
  }

  @override
  $MovesTableTable createAlias(String alias) {
    return $MovesTableTable(attachedDatabase, alias);
  }
}

class MoveRow extends DataClass implements Insertable<MoveRow> {
  final int id;
  final String name;
  final String? nameEs;
  final String? typeName;
  const MoveRow({
    required this.id,
    required this.name,
    this.nameEs,
    this.typeName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameEs != null) {
      map['name_es'] = Variable<String>(nameEs);
    }
    if (!nullToAbsent || typeName != null) {
      map['type_name'] = Variable<String>(typeName);
    }
    return map;
  }

  MovesTableCompanion toCompanion(bool nullToAbsent) {
    return MovesTableCompanion(
      id: Value(id),
      name: Value(name),
      nameEs: nameEs == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEs),
      typeName: typeName == null && nullToAbsent
          ? const Value.absent()
          : Value(typeName),
    );
  }

  factory MoveRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoveRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameEs: serializer.fromJson<String?>(json['nameEs']),
      typeName: serializer.fromJson<String?>(json['typeName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameEs': serializer.toJson<String?>(nameEs),
      'typeName': serializer.toJson<String?>(typeName),
    };
  }

  MoveRow copyWith({
    int? id,
    String? name,
    Value<String?> nameEs = const Value.absent(),
    Value<String?> typeName = const Value.absent(),
  }) => MoveRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameEs: nameEs.present ? nameEs.value : this.nameEs,
    typeName: typeName.present ? typeName.value : this.typeName,
  );
  MoveRow copyWithCompanion(MovesTableCompanion data) {
    return MoveRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameEs: data.nameEs.present ? data.nameEs.value : this.nameEs,
      typeName: data.typeName.present ? data.typeName.value : this.typeName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoveRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEs: $nameEs, ')
          ..write('typeName: $typeName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameEs, typeName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoveRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameEs == this.nameEs &&
          other.typeName == this.typeName);
}

class MovesTableCompanion extends UpdateCompanion<MoveRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> nameEs;
  final Value<String?> typeName;
  const MovesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameEs = const Value.absent(),
    this.typeName = const Value.absent(),
  });
  MovesTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nameEs = const Value.absent(),
    this.typeName = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MoveRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameEs,
    Expression<String>? typeName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameEs != null) 'name_es': nameEs,
      if (typeName != null) 'type_name': typeName,
    });
  }

  MovesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? nameEs,
    Value<String?>? typeName,
  }) {
    return MovesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEs: nameEs ?? this.nameEs,
      typeName: typeName ?? this.typeName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameEs.present) {
      map['name_es'] = Variable<String>(nameEs.value);
    }
    if (typeName.present) {
      map['type_name'] = Variable<String>(typeName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEs: $nameEs, ')
          ..write('typeName: $typeName')
          ..write(')'))
        .toString();
  }
}

class $PokemonMovesTableTable extends PokemonMovesTable
    with TableInfo<$PokemonMovesTableTable, PokemonMoveRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonMovesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _moveIdMeta = const VerificationMeta('moveId');
  @override
  late final GeneratedColumn<int> moveId = GeneratedColumn<int>(
    'move_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionGroupMeta = const VerificationMeta(
    'versionGroup',
  );
  @override
  late final GeneratedColumn<String> versionGroup = GeneratedColumn<String>(
    'version_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _learnMethodMeta = const VerificationMeta(
    'learnMethod',
  );
  @override
  late final GeneratedColumn<String> learnMethod = GeneratedColumn<String>(
    'learn_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pokemonId,
    moveId,
    versionGroup,
    learnMethod,
    level,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_moves';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonMoveRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('move_id')) {
      context.handle(
        _moveIdMeta,
        moveId.isAcceptableOrUnknown(data['move_id']!, _moveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moveIdMeta);
    }
    if (data.containsKey('version_group')) {
      context.handle(
        _versionGroupMeta,
        versionGroup.isAcceptableOrUnknown(
          data['version_group']!,
          _versionGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versionGroupMeta);
    }
    if (data.containsKey('learn_method')) {
      context.handle(
        _learnMethodMeta,
        learnMethod.isAcceptableOrUnknown(
          data['learn_method']!,
          _learnMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learnMethodMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    pokemonId,
    moveId,
    versionGroup,
    learnMethod,
  };
  @override
  PokemonMoveRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonMoveRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      moveId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}move_id'],
      )!,
      versionGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_group'],
      )!,
      learnMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learn_method'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
    );
  }

  @override
  $PokemonMovesTableTable createAlias(String alias) {
    return $PokemonMovesTableTable(attachedDatabase, alias);
  }
}

class PokemonMoveRow extends DataClass implements Insertable<PokemonMoveRow> {
  final int pokemonId;
  final int moveId;
  final String versionGroup;
  final String learnMethod;
  final int level;
  const PokemonMoveRow({
    required this.pokemonId,
    required this.moveId,
    required this.versionGroup,
    required this.learnMethod,
    required this.level,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['move_id'] = Variable<int>(moveId);
    map['version_group'] = Variable<String>(versionGroup);
    map['learn_method'] = Variable<String>(learnMethod);
    map['level'] = Variable<int>(level);
    return map;
  }

  PokemonMovesTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonMovesTableCompanion(
      pokemonId: Value(pokemonId),
      moveId: Value(moveId),
      versionGroup: Value(versionGroup),
      learnMethod: Value(learnMethod),
      level: Value(level),
    );
  }

  factory PokemonMoveRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonMoveRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      moveId: serializer.fromJson<int>(json['moveId']),
      versionGroup: serializer.fromJson<String>(json['versionGroup']),
      learnMethod: serializer.fromJson<String>(json['learnMethod']),
      level: serializer.fromJson<int>(json['level']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'moveId': serializer.toJson<int>(moveId),
      'versionGroup': serializer.toJson<String>(versionGroup),
      'learnMethod': serializer.toJson<String>(learnMethod),
      'level': serializer.toJson<int>(level),
    };
  }

  PokemonMoveRow copyWith({
    int? pokemonId,
    int? moveId,
    String? versionGroup,
    String? learnMethod,
    int? level,
  }) => PokemonMoveRow(
    pokemonId: pokemonId ?? this.pokemonId,
    moveId: moveId ?? this.moveId,
    versionGroup: versionGroup ?? this.versionGroup,
    learnMethod: learnMethod ?? this.learnMethod,
    level: level ?? this.level,
  );
  PokemonMoveRow copyWithCompanion(PokemonMovesTableCompanion data) {
    return PokemonMoveRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      moveId: data.moveId.present ? data.moveId.value : this.moveId,
      versionGroup: data.versionGroup.present
          ? data.versionGroup.value
          : this.versionGroup,
      learnMethod: data.learnMethod.present
          ? data.learnMethod.value
          : this.learnMethod,
      level: data.level.present ? data.level.value : this.level,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonMoveRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('moveId: $moveId, ')
          ..write('versionGroup: $versionGroup, ')
          ..write('learnMethod: $learnMethod, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(pokemonId, moveId, versionGroup, learnMethod, level);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonMoveRow &&
          other.pokemonId == this.pokemonId &&
          other.moveId == this.moveId &&
          other.versionGroup == this.versionGroup &&
          other.learnMethod == this.learnMethod &&
          other.level == this.level);
}

class PokemonMovesTableCompanion extends UpdateCompanion<PokemonMoveRow> {
  final Value<int> pokemonId;
  final Value<int> moveId;
  final Value<String> versionGroup;
  final Value<String> learnMethod;
  final Value<int> level;
  final Value<int> rowid;
  const PokemonMovesTableCompanion({
    this.pokemonId = const Value.absent(),
    this.moveId = const Value.absent(),
    this.versionGroup = const Value.absent(),
    this.learnMethod = const Value.absent(),
    this.level = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonMovesTableCompanion.insert({
    required int pokemonId,
    required int moveId,
    required String versionGroup,
    required String learnMethod,
    required int level,
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       moveId = Value(moveId),
       versionGroup = Value(versionGroup),
       learnMethod = Value(learnMethod),
       level = Value(level);
  static Insertable<PokemonMoveRow> custom({
    Expression<int>? pokemonId,
    Expression<int>? moveId,
    Expression<String>? versionGroup,
    Expression<String>? learnMethod,
    Expression<int>? level,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (moveId != null) 'move_id': moveId,
      if (versionGroup != null) 'version_group': versionGroup,
      if (learnMethod != null) 'learn_method': learnMethod,
      if (level != null) 'level': level,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonMovesTableCompanion copyWith({
    Value<int>? pokemonId,
    Value<int>? moveId,
    Value<String>? versionGroup,
    Value<String>? learnMethod,
    Value<int>? level,
    Value<int>? rowid,
  }) {
    return PokemonMovesTableCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      moveId: moveId ?? this.moveId,
      versionGroup: versionGroup ?? this.versionGroup,
      learnMethod: learnMethod ?? this.learnMethod,
      level: level ?? this.level,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (moveId.present) {
      map['move_id'] = Variable<int>(moveId.value);
    }
    if (versionGroup.present) {
      map['version_group'] = Variable<String>(versionGroup.value);
    }
    if (learnMethod.present) {
      map['learn_method'] = Variable<String>(learnMethod.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonMovesTableCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('moveId: $moveId, ')
          ..write('versionGroup: $versionGroup, ')
          ..write('learnMethod: $learnMethod, ')
          ..write('level: $level, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EvolutionsTableTable extends EvolutionsTable
    with TableInfo<$EvolutionsTableTable, EvolutionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvolutionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toSpeciesIdMeta = const VerificationMeta(
    'toSpeciesId',
  );
  @override
  late final GeneratedColumn<int> toSpeciesId = GeneratedColumn<int>(
    'to_species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromSpeciesIdMeta = const VerificationMeta(
    'fromSpeciesId',
  );
  @override
  late final GeneratedColumn<int> fromSpeciesId = GeneratedColumn<int>(
    'from_species_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chainIdMeta = const VerificationMeta(
    'chainId',
  );
  @override
  late final GeneratedColumn<int> chainId = GeneratedColumn<int>(
    'chain_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta(
    'trigger',
  );
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minLevelMeta = const VerificationMeta(
    'minLevel',
  );
  @override
  late final GeneratedColumn<int> minLevel = GeneratedColumn<int>(
    'min_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemMeta = const VerificationMeta('item');
  @override
  late final GeneratedColumn<String> item = GeneratedColumn<String>(
    'item',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minHappinessMeta = const VerificationMeta(
    'minHappiness',
  );
  @override
  late final GeneratedColumn<int> minHappiness = GeneratedColumn<int>(
    'min_happiness',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeOfDayMeta = const VerificationMeta(
    'timeOfDay',
  );
  @override
  late final GeneratedColumn<String> timeOfDay = GeneratedColumn<String>(
    'time_of_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _knownMoveTypeMeta = const VerificationMeta(
    'knownMoveType',
  );
  @override
  late final GeneratedColumn<String> knownMoveType = GeneratedColumn<String>(
    'known_move_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    toSpeciesId,
    fromSpeciesId,
    chainId,
    trigger,
    minLevel,
    item,
    minHappiness,
    timeOfDay,
    location,
    knownMoveType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evolutions';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvolutionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('to_species_id')) {
      context.handle(
        _toSpeciesIdMeta,
        toSpeciesId.isAcceptableOrUnknown(
          data['to_species_id']!,
          _toSpeciesIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toSpeciesIdMeta);
    }
    if (data.containsKey('from_species_id')) {
      context.handle(
        _fromSpeciesIdMeta,
        fromSpeciesId.isAcceptableOrUnknown(
          data['from_species_id']!,
          _fromSpeciesIdMeta,
        ),
      );
    }
    if (data.containsKey('chain_id')) {
      context.handle(
        _chainIdMeta,
        chainId.isAcceptableOrUnknown(data['chain_id']!, _chainIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chainIdMeta);
    }
    if (data.containsKey('trigger')) {
      context.handle(
        _triggerMeta,
        trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta),
      );
    }
    if (data.containsKey('min_level')) {
      context.handle(
        _minLevelMeta,
        minLevel.isAcceptableOrUnknown(data['min_level']!, _minLevelMeta),
      );
    }
    if (data.containsKey('item')) {
      context.handle(
        _itemMeta,
        item.isAcceptableOrUnknown(data['item']!, _itemMeta),
      );
    }
    if (data.containsKey('min_happiness')) {
      context.handle(
        _minHappinessMeta,
        minHappiness.isAcceptableOrUnknown(
          data['min_happiness']!,
          _minHappinessMeta,
        ),
      );
    }
    if (data.containsKey('time_of_day')) {
      context.handle(
        _timeOfDayMeta,
        timeOfDay.isAcceptableOrUnknown(data['time_of_day']!, _timeOfDayMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('known_move_type')) {
      context.handle(
        _knownMoveTypeMeta,
        knownMoveType.isAcceptableOrUnknown(
          data['known_move_type']!,
          _knownMoveTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EvolutionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvolutionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      toSpeciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_species_id'],
      )!,
      fromSpeciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_species_id'],
      ),
      chainId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chain_id'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      ),
      minLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_level'],
      ),
      item: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item'],
      ),
      minHappiness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_happiness'],
      ),
      timeOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_of_day'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      knownMoveType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}known_move_type'],
      ),
    );
  }

  @override
  $EvolutionsTableTable createAlias(String alias) {
    return $EvolutionsTableTable(attachedDatabase, alias);
  }
}

class EvolutionRow extends DataClass implements Insertable<EvolutionRow> {
  final int id;
  final int toSpeciesId;
  final int? fromSpeciesId;
  final int chainId;
  final String? trigger;
  final int? minLevel;
  final String? item;
  final int? minHappiness;
  final String? timeOfDay;
  final String? location;
  final String? knownMoveType;
  const EvolutionRow({
    required this.id,
    required this.toSpeciesId,
    this.fromSpeciesId,
    required this.chainId,
    this.trigger,
    this.minLevel,
    this.item,
    this.minHappiness,
    this.timeOfDay,
    this.location,
    this.knownMoveType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['to_species_id'] = Variable<int>(toSpeciesId);
    if (!nullToAbsent || fromSpeciesId != null) {
      map['from_species_id'] = Variable<int>(fromSpeciesId);
    }
    map['chain_id'] = Variable<int>(chainId);
    if (!nullToAbsent || trigger != null) {
      map['trigger'] = Variable<String>(trigger);
    }
    if (!nullToAbsent || minLevel != null) {
      map['min_level'] = Variable<int>(minLevel);
    }
    if (!nullToAbsent || item != null) {
      map['item'] = Variable<String>(item);
    }
    if (!nullToAbsent || minHappiness != null) {
      map['min_happiness'] = Variable<int>(minHappiness);
    }
    if (!nullToAbsent || timeOfDay != null) {
      map['time_of_day'] = Variable<String>(timeOfDay);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || knownMoveType != null) {
      map['known_move_type'] = Variable<String>(knownMoveType);
    }
    return map;
  }

  EvolutionsTableCompanion toCompanion(bool nullToAbsent) {
    return EvolutionsTableCompanion(
      id: Value(id),
      toSpeciesId: Value(toSpeciesId),
      fromSpeciesId: fromSpeciesId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromSpeciesId),
      chainId: Value(chainId),
      trigger: trigger == null && nullToAbsent
          ? const Value.absent()
          : Value(trigger),
      minLevel: minLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(minLevel),
      item: item == null && nullToAbsent ? const Value.absent() : Value(item),
      minHappiness: minHappiness == null && nullToAbsent
          ? const Value.absent()
          : Value(minHappiness),
      timeOfDay: timeOfDay == null && nullToAbsent
          ? const Value.absent()
          : Value(timeOfDay),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      knownMoveType: knownMoveType == null && nullToAbsent
          ? const Value.absent()
          : Value(knownMoveType),
    );
  }

  factory EvolutionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvolutionRow(
      id: serializer.fromJson<int>(json['id']),
      toSpeciesId: serializer.fromJson<int>(json['toSpeciesId']),
      fromSpeciesId: serializer.fromJson<int?>(json['fromSpeciesId']),
      chainId: serializer.fromJson<int>(json['chainId']),
      trigger: serializer.fromJson<String?>(json['trigger']),
      minLevel: serializer.fromJson<int?>(json['minLevel']),
      item: serializer.fromJson<String?>(json['item']),
      minHappiness: serializer.fromJson<int?>(json['minHappiness']),
      timeOfDay: serializer.fromJson<String?>(json['timeOfDay']),
      location: serializer.fromJson<String?>(json['location']),
      knownMoveType: serializer.fromJson<String?>(json['knownMoveType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'toSpeciesId': serializer.toJson<int>(toSpeciesId),
      'fromSpeciesId': serializer.toJson<int?>(fromSpeciesId),
      'chainId': serializer.toJson<int>(chainId),
      'trigger': serializer.toJson<String?>(trigger),
      'minLevel': serializer.toJson<int?>(minLevel),
      'item': serializer.toJson<String?>(item),
      'minHappiness': serializer.toJson<int?>(minHappiness),
      'timeOfDay': serializer.toJson<String?>(timeOfDay),
      'location': serializer.toJson<String?>(location),
      'knownMoveType': serializer.toJson<String?>(knownMoveType),
    };
  }

  EvolutionRow copyWith({
    int? id,
    int? toSpeciesId,
    Value<int?> fromSpeciesId = const Value.absent(),
    int? chainId,
    Value<String?> trigger = const Value.absent(),
    Value<int?> minLevel = const Value.absent(),
    Value<String?> item = const Value.absent(),
    Value<int?> minHappiness = const Value.absent(),
    Value<String?> timeOfDay = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> knownMoveType = const Value.absent(),
  }) => EvolutionRow(
    id: id ?? this.id,
    toSpeciesId: toSpeciesId ?? this.toSpeciesId,
    fromSpeciesId: fromSpeciesId.present
        ? fromSpeciesId.value
        : this.fromSpeciesId,
    chainId: chainId ?? this.chainId,
    trigger: trigger.present ? trigger.value : this.trigger,
    minLevel: minLevel.present ? minLevel.value : this.minLevel,
    item: item.present ? item.value : this.item,
    minHappiness: minHappiness.present ? minHappiness.value : this.minHappiness,
    timeOfDay: timeOfDay.present ? timeOfDay.value : this.timeOfDay,
    location: location.present ? location.value : this.location,
    knownMoveType: knownMoveType.present
        ? knownMoveType.value
        : this.knownMoveType,
  );
  EvolutionRow copyWithCompanion(EvolutionsTableCompanion data) {
    return EvolutionRow(
      id: data.id.present ? data.id.value : this.id,
      toSpeciesId: data.toSpeciesId.present
          ? data.toSpeciesId.value
          : this.toSpeciesId,
      fromSpeciesId: data.fromSpeciesId.present
          ? data.fromSpeciesId.value
          : this.fromSpeciesId,
      chainId: data.chainId.present ? data.chainId.value : this.chainId,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      minLevel: data.minLevel.present ? data.minLevel.value : this.minLevel,
      item: data.item.present ? data.item.value : this.item,
      minHappiness: data.minHappiness.present
          ? data.minHappiness.value
          : this.minHappiness,
      timeOfDay: data.timeOfDay.present ? data.timeOfDay.value : this.timeOfDay,
      location: data.location.present ? data.location.value : this.location,
      knownMoveType: data.knownMoveType.present
          ? data.knownMoveType.value
          : this.knownMoveType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvolutionRow(')
          ..write('id: $id, ')
          ..write('toSpeciesId: $toSpeciesId, ')
          ..write('fromSpeciesId: $fromSpeciesId, ')
          ..write('chainId: $chainId, ')
          ..write('trigger: $trigger, ')
          ..write('minLevel: $minLevel, ')
          ..write('item: $item, ')
          ..write('minHappiness: $minHappiness, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('location: $location, ')
          ..write('knownMoveType: $knownMoveType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    toSpeciesId,
    fromSpeciesId,
    chainId,
    trigger,
    minLevel,
    item,
    minHappiness,
    timeOfDay,
    location,
    knownMoveType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvolutionRow &&
          other.id == this.id &&
          other.toSpeciesId == this.toSpeciesId &&
          other.fromSpeciesId == this.fromSpeciesId &&
          other.chainId == this.chainId &&
          other.trigger == this.trigger &&
          other.minLevel == this.minLevel &&
          other.item == this.item &&
          other.minHappiness == this.minHappiness &&
          other.timeOfDay == this.timeOfDay &&
          other.location == this.location &&
          other.knownMoveType == this.knownMoveType);
}

class EvolutionsTableCompanion extends UpdateCompanion<EvolutionRow> {
  final Value<int> id;
  final Value<int> toSpeciesId;
  final Value<int?> fromSpeciesId;
  final Value<int> chainId;
  final Value<String?> trigger;
  final Value<int?> minLevel;
  final Value<String?> item;
  final Value<int?> minHappiness;
  final Value<String?> timeOfDay;
  final Value<String?> location;
  final Value<String?> knownMoveType;
  const EvolutionsTableCompanion({
    this.id = const Value.absent(),
    this.toSpeciesId = const Value.absent(),
    this.fromSpeciesId = const Value.absent(),
    this.chainId = const Value.absent(),
    this.trigger = const Value.absent(),
    this.minLevel = const Value.absent(),
    this.item = const Value.absent(),
    this.minHappiness = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.location = const Value.absent(),
    this.knownMoveType = const Value.absent(),
  });
  EvolutionsTableCompanion.insert({
    this.id = const Value.absent(),
    required int toSpeciesId,
    this.fromSpeciesId = const Value.absent(),
    required int chainId,
    this.trigger = const Value.absent(),
    this.minLevel = const Value.absent(),
    this.item = const Value.absent(),
    this.minHappiness = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.location = const Value.absent(),
    this.knownMoveType = const Value.absent(),
  }) : toSpeciesId = Value(toSpeciesId),
       chainId = Value(chainId);
  static Insertable<EvolutionRow> custom({
    Expression<int>? id,
    Expression<int>? toSpeciesId,
    Expression<int>? fromSpeciesId,
    Expression<int>? chainId,
    Expression<String>? trigger,
    Expression<int>? minLevel,
    Expression<String>? item,
    Expression<int>? minHappiness,
    Expression<String>? timeOfDay,
    Expression<String>? location,
    Expression<String>? knownMoveType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (toSpeciesId != null) 'to_species_id': toSpeciesId,
      if (fromSpeciesId != null) 'from_species_id': fromSpeciesId,
      if (chainId != null) 'chain_id': chainId,
      if (trigger != null) 'trigger': trigger,
      if (minLevel != null) 'min_level': minLevel,
      if (item != null) 'item': item,
      if (minHappiness != null) 'min_happiness': minHappiness,
      if (timeOfDay != null) 'time_of_day': timeOfDay,
      if (location != null) 'location': location,
      if (knownMoveType != null) 'known_move_type': knownMoveType,
    });
  }

  EvolutionsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? toSpeciesId,
    Value<int?>? fromSpeciesId,
    Value<int>? chainId,
    Value<String?>? trigger,
    Value<int?>? minLevel,
    Value<String?>? item,
    Value<int?>? minHappiness,
    Value<String?>? timeOfDay,
    Value<String?>? location,
    Value<String?>? knownMoveType,
  }) {
    return EvolutionsTableCompanion(
      id: id ?? this.id,
      toSpeciesId: toSpeciesId ?? this.toSpeciesId,
      fromSpeciesId: fromSpeciesId ?? this.fromSpeciesId,
      chainId: chainId ?? this.chainId,
      trigger: trigger ?? this.trigger,
      minLevel: minLevel ?? this.minLevel,
      item: item ?? this.item,
      minHappiness: minHappiness ?? this.minHappiness,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      location: location ?? this.location,
      knownMoveType: knownMoveType ?? this.knownMoveType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (toSpeciesId.present) {
      map['to_species_id'] = Variable<int>(toSpeciesId.value);
    }
    if (fromSpeciesId.present) {
      map['from_species_id'] = Variable<int>(fromSpeciesId.value);
    }
    if (chainId.present) {
      map['chain_id'] = Variable<int>(chainId.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (minLevel.present) {
      map['min_level'] = Variable<int>(minLevel.value);
    }
    if (item.present) {
      map['item'] = Variable<String>(item.value);
    }
    if (minHappiness.present) {
      map['min_happiness'] = Variable<int>(minHappiness.value);
    }
    if (timeOfDay.present) {
      map['time_of_day'] = Variable<String>(timeOfDay.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (knownMoveType.present) {
      map['known_move_type'] = Variable<String>(knownMoveType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvolutionsTableCompanion(')
          ..write('id: $id, ')
          ..write('toSpeciesId: $toSpeciesId, ')
          ..write('fromSpeciesId: $fromSpeciesId, ')
          ..write('chainId: $chainId, ')
          ..write('trigger: $trigger, ')
          ..write('minLevel: $minLevel, ')
          ..write('item: $item, ')
          ..write('minHappiness: $minHappiness, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('location: $location, ')
          ..write('knownMoveType: $knownMoveType')
          ..write(')'))
        .toString();
  }
}

class $PokemonGamesTableTable extends PokemonGamesTable
    with TableInfo<$PokemonGamesTableTable, PokemonGameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonGamesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _versionNameMeta = const VerificationMeta(
    'versionName',
  );
  @override
  late final GeneratedColumn<String> versionName = GeneratedColumn<String>(
    'version_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pokemonId, versionName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_games';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonGameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('version_name')) {
      context.handle(
        _versionNameMeta,
        versionName.isAcceptableOrUnknown(
          data['version_name']!,
          _versionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versionNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId, versionName};
  @override
  PokemonGameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonGameRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      versionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_name'],
      )!,
    );
  }

  @override
  $PokemonGamesTableTable createAlias(String alias) {
    return $PokemonGamesTableTable(attachedDatabase, alias);
  }
}

class PokemonGameRow extends DataClass implements Insertable<PokemonGameRow> {
  final int pokemonId;
  final String versionName;
  const PokemonGameRow({required this.pokemonId, required this.versionName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['version_name'] = Variable<String>(versionName);
    return map;
  }

  PokemonGamesTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonGamesTableCompanion(
      pokemonId: Value(pokemonId),
      versionName: Value(versionName),
    );
  }

  factory PokemonGameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonGameRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      versionName: serializer.fromJson<String>(json['versionName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'versionName': serializer.toJson<String>(versionName),
    };
  }

  PokemonGameRow copyWith({int? pokemonId, String? versionName}) =>
      PokemonGameRow(
        pokemonId: pokemonId ?? this.pokemonId,
        versionName: versionName ?? this.versionName,
      );
  PokemonGameRow copyWithCompanion(PokemonGamesTableCompanion data) {
    return PokemonGameRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      versionName: data.versionName.present
          ? data.versionName.value
          : this.versionName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonGameRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('versionName: $versionName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, versionName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonGameRow &&
          other.pokemonId == this.pokemonId &&
          other.versionName == this.versionName);
}

class PokemonGamesTableCompanion extends UpdateCompanion<PokemonGameRow> {
  final Value<int> pokemonId;
  final Value<String> versionName;
  final Value<int> rowid;
  const PokemonGamesTableCompanion({
    this.pokemonId = const Value.absent(),
    this.versionName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonGamesTableCompanion.insert({
    required int pokemonId,
    required String versionName,
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       versionName = Value(versionName);
  static Insertable<PokemonGameRow> custom({
    Expression<int>? pokemonId,
    Expression<String>? versionName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (versionName != null) 'version_name': versionName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonGamesTableCompanion copyWith({
    Value<int>? pokemonId,
    Value<String>? versionName,
    Value<int>? rowid,
  }) {
    return PokemonGamesTableCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      versionName: versionName ?? this.versionName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (versionName.present) {
      map['version_name'] = Variable<String>(versionName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonGamesTableCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('versionName: $versionName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TypeEfficacyTableTable extends TypeEfficacyTable
    with TableInfo<$TypeEfficacyTableTable, TypeEfficacyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TypeEfficacyTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attackingTypeMeta = const VerificationMeta(
    'attackingType',
  );
  @override
  late final GeneratedColumn<String> attackingType = GeneratedColumn<String>(
    'attacking_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defendingTypeMeta = const VerificationMeta(
    'defendingType',
  );
  @override
  late final GeneratedColumn<String> defendingType = GeneratedColumn<String>(
    'defending_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _damageFactorMeta = const VerificationMeta(
    'damageFactor',
  );
  @override
  late final GeneratedColumn<int> damageFactor = GeneratedColumn<int>(
    'damage_factor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attackingType,
    defendingType,
    damageFactor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'type_efficacy';
  @override
  VerificationContext validateIntegrity(
    Insertable<TypeEfficacyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attacking_type')) {
      context.handle(
        _attackingTypeMeta,
        attackingType.isAcceptableOrUnknown(
          data['attacking_type']!,
          _attackingTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attackingTypeMeta);
    }
    if (data.containsKey('defending_type')) {
      context.handle(
        _defendingTypeMeta,
        defendingType.isAcceptableOrUnknown(
          data['defending_type']!,
          _defendingTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defendingTypeMeta);
    }
    if (data.containsKey('damage_factor')) {
      context.handle(
        _damageFactorMeta,
        damageFactor.isAcceptableOrUnknown(
          data['damage_factor']!,
          _damageFactorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_damageFactorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attackingType, defendingType};
  @override
  TypeEfficacyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TypeEfficacyRow(
      attackingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attacking_type'],
      )!,
      defendingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}defending_type'],
      )!,
      damageFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}damage_factor'],
      )!,
    );
  }

  @override
  $TypeEfficacyTableTable createAlias(String alias) {
    return $TypeEfficacyTableTable(attachedDatabase, alias);
  }
}

class TypeEfficacyRow extends DataClass implements Insertable<TypeEfficacyRow> {
  final String attackingType;
  final String defendingType;
  final int damageFactor;
  const TypeEfficacyRow({
    required this.attackingType,
    required this.defendingType,
    required this.damageFactor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attacking_type'] = Variable<String>(attackingType);
    map['defending_type'] = Variable<String>(defendingType);
    map['damage_factor'] = Variable<int>(damageFactor);
    return map;
  }

  TypeEfficacyTableCompanion toCompanion(bool nullToAbsent) {
    return TypeEfficacyTableCompanion(
      attackingType: Value(attackingType),
      defendingType: Value(defendingType),
      damageFactor: Value(damageFactor),
    );
  }

  factory TypeEfficacyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TypeEfficacyRow(
      attackingType: serializer.fromJson<String>(json['attackingType']),
      defendingType: serializer.fromJson<String>(json['defendingType']),
      damageFactor: serializer.fromJson<int>(json['damageFactor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attackingType': serializer.toJson<String>(attackingType),
      'defendingType': serializer.toJson<String>(defendingType),
      'damageFactor': serializer.toJson<int>(damageFactor),
    };
  }

  TypeEfficacyRow copyWith({
    String? attackingType,
    String? defendingType,
    int? damageFactor,
  }) => TypeEfficacyRow(
    attackingType: attackingType ?? this.attackingType,
    defendingType: defendingType ?? this.defendingType,
    damageFactor: damageFactor ?? this.damageFactor,
  );
  TypeEfficacyRow copyWithCompanion(TypeEfficacyTableCompanion data) {
    return TypeEfficacyRow(
      attackingType: data.attackingType.present
          ? data.attackingType.value
          : this.attackingType,
      defendingType: data.defendingType.present
          ? data.defendingType.value
          : this.defendingType,
      damageFactor: data.damageFactor.present
          ? data.damageFactor.value
          : this.damageFactor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TypeEfficacyRow(')
          ..write('attackingType: $attackingType, ')
          ..write('defendingType: $defendingType, ')
          ..write('damageFactor: $damageFactor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(attackingType, defendingType, damageFactor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TypeEfficacyRow &&
          other.attackingType == this.attackingType &&
          other.defendingType == this.defendingType &&
          other.damageFactor == this.damageFactor);
}

class TypeEfficacyTableCompanion extends UpdateCompanion<TypeEfficacyRow> {
  final Value<String> attackingType;
  final Value<String> defendingType;
  final Value<int> damageFactor;
  final Value<int> rowid;
  const TypeEfficacyTableCompanion({
    this.attackingType = const Value.absent(),
    this.defendingType = const Value.absent(),
    this.damageFactor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TypeEfficacyTableCompanion.insert({
    required String attackingType,
    required String defendingType,
    required int damageFactor,
    this.rowid = const Value.absent(),
  }) : attackingType = Value(attackingType),
       defendingType = Value(defendingType),
       damageFactor = Value(damageFactor);
  static Insertable<TypeEfficacyRow> custom({
    Expression<String>? attackingType,
    Expression<String>? defendingType,
    Expression<int>? damageFactor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attackingType != null) 'attacking_type': attackingType,
      if (defendingType != null) 'defending_type': defendingType,
      if (damageFactor != null) 'damage_factor': damageFactor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TypeEfficacyTableCompanion copyWith({
    Value<String>? attackingType,
    Value<String>? defendingType,
    Value<int>? damageFactor,
    Value<int>? rowid,
  }) {
    return TypeEfficacyTableCompanion(
      attackingType: attackingType ?? this.attackingType,
      defendingType: defendingType ?? this.defendingType,
      damageFactor: damageFactor ?? this.damageFactor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attackingType.present) {
      map['attacking_type'] = Variable<String>(attackingType.value);
    }
    if (defendingType.present) {
      map['defending_type'] = Variable<String>(defendingType.value);
    }
    if (damageFactor.present) {
      map['damage_factor'] = Variable<int>(damageFactor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TypeEfficacyTableCompanion(')
          ..write('attackingType: $attackingType, ')
          ..write('defendingType: $defendingType, ')
          ..write('damageFactor: $damageFactor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTableTable extends FavoritesTable
    with TableInfo<$FavoritesTableTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pokemonId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FavoritesTableTable createAlias(String alias) {
    return $FavoritesTableTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final int pokemonId;
  final DateTime createdAt;
  const FavoriteRow({required this.pokemonId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoritesTableCompanion toCompanion(bool nullToAbsent) {
    return FavoritesTableCompanion(
      pokemonId: Value(pokemonId),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteRow copyWith({int? pokemonId, DateTime? createdAt}) => FavoriteRow(
    pokemonId: pokemonId ?? this.pokemonId,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteRow copyWithCompanion(FavoritesTableCompanion data) {
    return FavoriteRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.pokemonId == this.pokemonId &&
          other.createdAt == this.createdAt);
}

class FavoritesTableCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<int> pokemonId;
  final Value<DateTime> createdAt;
  const FavoritesTableCompanion({
    this.pokemonId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FavoritesTableCompanion.insert({
    this.pokemonId = const Value.absent(),
    required DateTime createdAt,
  }) : createdAt = Value(createdAt);
  static Insertable<FavoriteRow> custom({
    Expression<int>? pokemonId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FavoritesTableCompanion copyWith({
    Value<int>? pokemonId,
    Value<DateTime>? createdAt,
  }) {
    return FavoritesTableCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesTableCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TriviaResultsTableTable extends TriviaResultsTable
    with TableInfo<$TriviaResultsTableTable, TriviaResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TriviaResultsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctAnswersMeta = const VerificationMeta(
    'correctAnswers',
  );
  @override
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
    'correct_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    score,
    correctAnswers,
    totalQuestions,
    durationMs,
    playedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trivia_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<TriviaResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
        _correctAnswersMeta,
        correctAnswers.isAcceptableOrUnknown(
          data['correct_answers']!,
          _correctAnswersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswersMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TriviaResultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TriviaResultRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      correctAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answers'],
      )!,
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $TriviaResultsTableTable createAlias(String alias) {
    return $TriviaResultsTableTable(attachedDatabase, alias);
  }
}

class TriviaResultRow extends DataClass implements Insertable<TriviaResultRow> {
  final int id;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int durationMs;
  final DateTime playedAt;
  const TriviaResultRow({
    required this.id,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.durationMs,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['score'] = Variable<int>(score);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['duration_ms'] = Variable<int>(durationMs);
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  TriviaResultsTableCompanion toCompanion(bool nullToAbsent) {
    return TriviaResultsTableCompanion(
      id: Value(id),
      score: Value(score),
      correctAnswers: Value(correctAnswers),
      totalQuestions: Value(totalQuestions),
      durationMs: Value(durationMs),
      playedAt: Value(playedAt),
    );
  }

  factory TriviaResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TriviaResultRow(
      id: serializer.fromJson<int>(json['id']),
      score: serializer.fromJson<int>(json['score']),
      correctAnswers: serializer.fromJson<int>(json['correctAnswers']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'score': serializer.toJson<int>(score),
      'correctAnswers': serializer.toJson<int>(correctAnswers),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'durationMs': serializer.toJson<int>(durationMs),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  TriviaResultRow copyWith({
    int? id,
    int? score,
    int? correctAnswers,
    int? totalQuestions,
    int? durationMs,
    DateTime? playedAt,
  }) => TriviaResultRow(
    id: id ?? this.id,
    score: score ?? this.score,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    durationMs: durationMs ?? this.durationMs,
    playedAt: playedAt ?? this.playedAt,
  );
  TriviaResultRow copyWithCompanion(TriviaResultsTableCompanion data) {
    return TriviaResultRow(
      id: data.id.present ? data.id.value : this.id,
      score: data.score.present ? data.score.value : this.score,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TriviaResultRow(')
          ..write('id: $id, ')
          ..write('score: $score, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('durationMs: $durationMs, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    score,
    correctAnswers,
    totalQuestions,
    durationMs,
    playedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TriviaResultRow &&
          other.id == this.id &&
          other.score == this.score &&
          other.correctAnswers == this.correctAnswers &&
          other.totalQuestions == this.totalQuestions &&
          other.durationMs == this.durationMs &&
          other.playedAt == this.playedAt);
}

class TriviaResultsTableCompanion extends UpdateCompanion<TriviaResultRow> {
  final Value<int> id;
  final Value<int> score;
  final Value<int> correctAnswers;
  final Value<int> totalQuestions;
  final Value<int> durationMs;
  final Value<DateTime> playedAt;
  const TriviaResultsTableCompanion({
    this.id = const Value.absent(),
    this.score = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.playedAt = const Value.absent(),
  });
  TriviaResultsTableCompanion.insert({
    this.id = const Value.absent(),
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int durationMs,
    required DateTime playedAt,
  }) : score = Value(score),
       correctAnswers = Value(correctAnswers),
       totalQuestions = Value(totalQuestions),
       durationMs = Value(durationMs),
       playedAt = Value(playedAt);
  static Insertable<TriviaResultRow> custom({
    Expression<int>? id,
    Expression<int>? score,
    Expression<int>? correctAnswers,
    Expression<int>? totalQuestions,
    Expression<int>? durationMs,
    Expression<DateTime>? playedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (score != null) 'score': score,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (durationMs != null) 'duration_ms': durationMs,
      if (playedAt != null) 'played_at': playedAt,
    });
  }

  TriviaResultsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? score,
    Value<int>? correctAnswers,
    Value<int>? totalQuestions,
    Value<int>? durationMs,
    Value<DateTime>? playedAt,
  }) {
    return TriviaResultsTableCompanion(
      id: id ?? this.id,
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      durationMs: durationMs ?? this.durationMs,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TriviaResultsTableCompanion(')
          ..write('id: $id, ')
          ..write('score: $score, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('durationMs: $durationMs, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }
}

class $TriviaAnswersTableTable extends TriviaAnswersTable
    with TableInfo<$TriviaAnswersTableTable, TriviaAnswerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TriviaAnswersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resultIdMeta = const VerificationMeta(
    'resultId',
  );
  @override
  late final GeneratedColumn<int> resultId = GeneratedColumn<int>(
    'result_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trivia_results (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _responseMsMeta = const VerificationMeta(
    'responseMs',
  );
  @override
  late final GeneratedColumn<int> responseMs = GeneratedColumn<int>(
    'response_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    resultId,
    pokemonId,
    correct,
    responseMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trivia_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TriviaAnswerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('result_id')) {
      context.handle(
        _resultIdMeta,
        resultId.isAcceptableOrUnknown(data['result_id']!, _resultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resultIdMeta);
    }
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('response_ms')) {
      context.handle(
        _responseMsMeta,
        responseMs.isAcceptableOrUnknown(data['response_ms']!, _responseMsMeta),
      );
    } else if (isInserting) {
      context.missing(_responseMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TriviaAnswerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TriviaAnswerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resultId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}result_id'],
      )!,
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      responseMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_ms'],
      )!,
    );
  }

  @override
  $TriviaAnswersTableTable createAlias(String alias) {
    return $TriviaAnswersTableTable(attachedDatabase, alias);
  }
}

class TriviaAnswerRow extends DataClass implements Insertable<TriviaAnswerRow> {
  final int id;
  final int resultId;
  final int pokemonId;
  final bool correct;
  final int responseMs;
  const TriviaAnswerRow({
    required this.id,
    required this.resultId,
    required this.pokemonId,
    required this.correct,
    required this.responseMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['result_id'] = Variable<int>(resultId);
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['correct'] = Variable<bool>(correct);
    map['response_ms'] = Variable<int>(responseMs);
    return map;
  }

  TriviaAnswersTableCompanion toCompanion(bool nullToAbsent) {
    return TriviaAnswersTableCompanion(
      id: Value(id),
      resultId: Value(resultId),
      pokemonId: Value(pokemonId),
      correct: Value(correct),
      responseMs: Value(responseMs),
    );
  }

  factory TriviaAnswerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TriviaAnswerRow(
      id: serializer.fromJson<int>(json['id']),
      resultId: serializer.fromJson<int>(json['resultId']),
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      correct: serializer.fromJson<bool>(json['correct']),
      responseMs: serializer.fromJson<int>(json['responseMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resultId': serializer.toJson<int>(resultId),
      'pokemonId': serializer.toJson<int>(pokemonId),
      'correct': serializer.toJson<bool>(correct),
      'responseMs': serializer.toJson<int>(responseMs),
    };
  }

  TriviaAnswerRow copyWith({
    int? id,
    int? resultId,
    int? pokemonId,
    bool? correct,
    int? responseMs,
  }) => TriviaAnswerRow(
    id: id ?? this.id,
    resultId: resultId ?? this.resultId,
    pokemonId: pokemonId ?? this.pokemonId,
    correct: correct ?? this.correct,
    responseMs: responseMs ?? this.responseMs,
  );
  TriviaAnswerRow copyWithCompanion(TriviaAnswersTableCompanion data) {
    return TriviaAnswerRow(
      id: data.id.present ? data.id.value : this.id,
      resultId: data.resultId.present ? data.resultId.value : this.resultId,
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      correct: data.correct.present ? data.correct.value : this.correct,
      responseMs: data.responseMs.present
          ? data.responseMs.value
          : this.responseMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TriviaAnswerRow(')
          ..write('id: $id, ')
          ..write('resultId: $resultId, ')
          ..write('pokemonId: $pokemonId, ')
          ..write('correct: $correct, ')
          ..write('responseMs: $responseMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, resultId, pokemonId, correct, responseMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TriviaAnswerRow &&
          other.id == this.id &&
          other.resultId == this.resultId &&
          other.pokemonId == this.pokemonId &&
          other.correct == this.correct &&
          other.responseMs == this.responseMs);
}

class TriviaAnswersTableCompanion extends UpdateCompanion<TriviaAnswerRow> {
  final Value<int> id;
  final Value<int> resultId;
  final Value<int> pokemonId;
  final Value<bool> correct;
  final Value<int> responseMs;
  const TriviaAnswersTableCompanion({
    this.id = const Value.absent(),
    this.resultId = const Value.absent(),
    this.pokemonId = const Value.absent(),
    this.correct = const Value.absent(),
    this.responseMs = const Value.absent(),
  });
  TriviaAnswersTableCompanion.insert({
    this.id = const Value.absent(),
    required int resultId,
    required int pokemonId,
    required bool correct,
    required int responseMs,
  }) : resultId = Value(resultId),
       pokemonId = Value(pokemonId),
       correct = Value(correct),
       responseMs = Value(responseMs);
  static Insertable<TriviaAnswerRow> custom({
    Expression<int>? id,
    Expression<int>? resultId,
    Expression<int>? pokemonId,
    Expression<bool>? correct,
    Expression<int>? responseMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resultId != null) 'result_id': resultId,
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (correct != null) 'correct': correct,
      if (responseMs != null) 'response_ms': responseMs,
    });
  }

  TriviaAnswersTableCompanion copyWith({
    Value<int>? id,
    Value<int>? resultId,
    Value<int>? pokemonId,
    Value<bool>? correct,
    Value<int>? responseMs,
  }) {
    return TriviaAnswersTableCompanion(
      id: id ?? this.id,
      resultId: resultId ?? this.resultId,
      pokemonId: pokemonId ?? this.pokemonId,
      correct: correct ?? this.correct,
      responseMs: responseMs ?? this.responseMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resultId.present) {
      map['result_id'] = Variable<int>(resultId.value);
    }
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (responseMs.present) {
      map['response_ms'] = Variable<int>(responseMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TriviaAnswersTableCompanion(')
          ..write('id: $id, ')
          ..write('resultId: $resultId, ')
          ..write('pokemonId: $pokemonId, ')
          ..write('correct: $correct, ')
          ..write('responseMs: $responseMs')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTableTable extends AchievementsTable
    with TableInfo<$AchievementsTableTable, AchievementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<AchievementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AchievementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $AchievementsTableTable createAlias(String alias) {
    return $AchievementsTableTable(attachedDatabase, alias);
  }
}

class AchievementRow extends DataClass implements Insertable<AchievementRow> {
  final String key;
  final DateTime unlockedAt;
  const AchievementRow({required this.key, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  AchievementsTableCompanion toCompanion(bool nullToAbsent) {
    return AchievementsTableCompanion(
      key: Value(key),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory AchievementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementRow(
      key: serializer.fromJson<String>(json['key']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  AchievementRow copyWith({String? key, DateTime? unlockedAt}) =>
      AchievementRow(
        key: key ?? this.key,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  AchievementRow copyWithCompanion(AchievementsTableCompanion data) {
    return AchievementRow(
      key: data.key.present ? data.key.value : this.key,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementRow(')
          ..write('key: $key, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementRow &&
          other.key == this.key &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsTableCompanion extends UpdateCompanion<AchievementRow> {
  final Value<String> key;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const AchievementsTableCompanion({
    this.key = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsTableCompanion.insert({
    required String key,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       unlockedAt = Value(unlockedAt);
  static Insertable<AchievementRow> custom({
    Expression<String>? key,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsTableCompanion copyWith({
    Value<String>? key,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return AchievementsTableCompanion(
      key: key ?? this.key,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsTableCompanion(')
          ..write('key: $key, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTableTable extends UserPreferencesTable
    with TableInfo<$UserPreferencesTableTable, UserPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreferenceRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $UserPreferencesTableTable createAlias(String alias) {
    return $UserPreferencesTableTable(attachedDatabase, alias);
  }
}

class UserPreferenceRow extends DataClass
    implements Insertable<UserPreferenceRow> {
  final String key;
  final String value;
  const UserPreferenceRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  UserPreferencesTableCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesTableCompanion(key: Value(key), value: Value(value));
  }

  factory UserPreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreferenceRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  UserPreferenceRow copyWith({String? key, String? value}) =>
      UserPreferenceRow(key: key ?? this.key, value: value ?? this.value);
  UserPreferenceRow copyWithCompanion(UserPreferencesTableCompanion data) {
    return UserPreferenceRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferenceRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreferenceRow &&
          other.key == this.key &&
          other.value == this.value);
}

class UserPreferencesTableCompanion extends UpdateCompanion<UserPreferenceRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const UserPreferencesTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPreferencesTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<UserPreferenceRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPreferencesTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return UserPreferencesTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTableTable extends SyncMetadataTable
    with TableInfo<$SyncMetadataTableTable, SyncMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextOffsetMeta = const VerificationMeta(
    'nextOffset',
  );
  @override
  late final GeneratedColumn<int> nextOffset = GeneratedColumn<int>(
    'next_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('idle'),
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastVerifiedAtMeta = const VerificationMeta(
    'lastVerifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVerifiedAt =
      GeneratedColumn<DateTime>(
        'last_verified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorKindMeta = const VerificationMeta(
    'lastErrorKind',
  );
  @override
  late final GeneratedColumn<String> lastErrorKind = GeneratedColumn<String>(
    'last_error_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    nextOffset,
    totalCount,
    isComplete,
    lastSyncedAt,
    lastError,
    status,
    attempt,
    nextRetryAt,
    lastVerifiedAt,
    lastErrorKind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('next_offset')) {
      context.handle(
        _nextOffsetMeta,
        nextOffset.isAcceptableOrUnknown(data['next_offset']!, _nextOffsetMeta),
      );
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_verified_at')) {
      context.handle(
        _lastVerifiedAtMeta,
        lastVerifiedAt.isAcceptableOrUnknown(
          data['last_verified_at']!,
          _lastVerifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_kind')) {
      context.handle(
        _lastErrorKindMeta,
        lastErrorKind.isAcceptableOrUnknown(
          data['last_error_kind']!,
          _lastErrorKindMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      nextOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_offset'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      ),
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastVerifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_verified_at'],
      ),
      lastErrorKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_kind'],
      ),
    );
  }

  @override
  $SyncMetadataTableTable createAlias(String alias) {
    return $SyncMetadataTableTable(attachedDatabase, alias);
  }
}

class SyncMetadataRow extends DataClass implements Insertable<SyncMetadataRow> {
  final String key;
  final int nextOffset;
  final int? totalCount;
  final bool isComplete;
  final DateTime? lastSyncedAt;
  final String? lastError;
  final String status;
  final int attempt;
  final DateTime? nextRetryAt;
  final DateTime? lastVerifiedAt;
  final String? lastErrorKind;
  const SyncMetadataRow({
    required this.key,
    required this.nextOffset,
    this.totalCount,
    required this.isComplete,
    this.lastSyncedAt,
    this.lastError,
    required this.status,
    required this.attempt,
    this.nextRetryAt,
    this.lastVerifiedAt,
    this.lastErrorKind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['next_offset'] = Variable<int>(nextOffset);
    if (!nullToAbsent || totalCount != null) {
      map['total_count'] = Variable<int>(totalCount);
    }
    map['is_complete'] = Variable<bool>(isComplete);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['status'] = Variable<String>(status);
    map['attempt'] = Variable<int>(attempt);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || lastVerifiedAt != null) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt);
    }
    if (!nullToAbsent || lastErrorKind != null) {
      map['last_error_kind'] = Variable<String>(lastErrorKind);
    }
    return map;
  }

  SyncMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataTableCompanion(
      key: Value(key),
      nextOffset: Value(nextOffset),
      totalCount: totalCount == null && nullToAbsent
          ? const Value.absent()
          : Value(totalCount),
      isComplete: Value(isComplete),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      status: Value(status),
      attempt: Value(attempt),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastVerifiedAt: lastVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerifiedAt),
      lastErrorKind: lastErrorKind == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorKind),
    );
  }

  factory SyncMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataRow(
      key: serializer.fromJson<String>(json['key']),
      nextOffset: serializer.fromJson<int>(json['nextOffset']),
      totalCount: serializer.fromJson<int?>(json['totalCount']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      status: serializer.fromJson<String>(json['status']),
      attempt: serializer.fromJson<int>(json['attempt']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      lastVerifiedAt: serializer.fromJson<DateTime?>(json['lastVerifiedAt']),
      lastErrorKind: serializer.fromJson<String?>(json['lastErrorKind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'nextOffset': serializer.toJson<int>(nextOffset),
      'totalCount': serializer.toJson<int?>(totalCount),
      'isComplete': serializer.toJson<bool>(isComplete),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'status': serializer.toJson<String>(status),
      'attempt': serializer.toJson<int>(attempt),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'lastVerifiedAt': serializer.toJson<DateTime?>(lastVerifiedAt),
      'lastErrorKind': serializer.toJson<String?>(lastErrorKind),
    };
  }

  SyncMetadataRow copyWith({
    String? key,
    int? nextOffset,
    Value<int?> totalCount = const Value.absent(),
    bool? isComplete,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    String? status,
    int? attempt,
    Value<DateTime?> nextRetryAt = const Value.absent(),
    Value<DateTime?> lastVerifiedAt = const Value.absent(),
    Value<String?> lastErrorKind = const Value.absent(),
  }) => SyncMetadataRow(
    key: key ?? this.key,
    nextOffset: nextOffset ?? this.nextOffset,
    totalCount: totalCount.present ? totalCount.value : this.totalCount,
    isComplete: isComplete ?? this.isComplete,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    status: status ?? this.status,
    attempt: attempt ?? this.attempt,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastVerifiedAt: lastVerifiedAt.present
        ? lastVerifiedAt.value
        : this.lastVerifiedAt,
    lastErrorKind: lastErrorKind.present
        ? lastErrorKind.value
        : this.lastErrorKind,
  );
  SyncMetadataRow copyWithCompanion(SyncMetadataTableCompanion data) {
    return SyncMetadataRow(
      key: data.key.present ? data.key.value : this.key,
      nextOffset: data.nextOffset.present
          ? data.nextOffset.value
          : this.nextOffset,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      status: data.status.present ? data.status.value : this.status,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
      lastErrorKind: data.lastErrorKind.present
          ? data.lastErrorKind.value
          : this.lastErrorKind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataRow(')
          ..write('key: $key, ')
          ..write('nextOffset: $nextOffset, ')
          ..write('totalCount: $totalCount, ')
          ..write('isComplete: $isComplete, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('lastErrorKind: $lastErrorKind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    nextOffset,
    totalCount,
    isComplete,
    lastSyncedAt,
    lastError,
    status,
    attempt,
    nextRetryAt,
    lastVerifiedAt,
    lastErrorKind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataRow &&
          other.key == this.key &&
          other.nextOffset == this.nextOffset &&
          other.totalCount == this.totalCount &&
          other.isComplete == this.isComplete &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastError == this.lastError &&
          other.status == this.status &&
          other.attempt == this.attempt &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastVerifiedAt == this.lastVerifiedAt &&
          other.lastErrorKind == this.lastErrorKind);
}

class SyncMetadataTableCompanion extends UpdateCompanion<SyncMetadataRow> {
  final Value<String> key;
  final Value<int> nextOffset;
  final Value<int?> totalCount;
  final Value<bool> isComplete;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> lastError;
  final Value<String> status;
  final Value<int> attempt;
  final Value<DateTime?> nextRetryAt;
  final Value<DateTime?> lastVerifiedAt;
  final Value<String?> lastErrorKind;
  final Value<int> rowid;
  const SyncMetadataTableCompanion({
    this.key = const Value.absent(),
    this.nextOffset = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    this.attempt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.lastErrorKind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataTableCompanion.insert({
    required String key,
    this.nextOffset = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    this.attempt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.lastErrorKind = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SyncMetadataRow> custom({
    Expression<String>? key,
    Expression<int>? nextOffset,
    Expression<int>? totalCount,
    Expression<bool>? isComplete,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? lastError,
    Expression<String>? status,
    Expression<int>? attempt,
    Expression<DateTime>? nextRetryAt,
    Expression<DateTime>? lastVerifiedAt,
    Expression<String>? lastErrorKind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (nextOffset != null) 'next_offset': nextOffset,
      if (totalCount != null) 'total_count': totalCount,
      if (isComplete != null) 'is_complete': isComplete,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastError != null) 'last_error': lastError,
      if (status != null) 'status': status,
      if (attempt != null) 'attempt': attempt,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
      if (lastErrorKind != null) 'last_error_kind': lastErrorKind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataTableCompanion copyWith({
    Value<String>? key,
    Value<int>? nextOffset,
    Value<int?>? totalCount,
    Value<bool>? isComplete,
    Value<DateTime?>? lastSyncedAt,
    Value<String?>? lastError,
    Value<String>? status,
    Value<int>? attempt,
    Value<DateTime?>? nextRetryAt,
    Value<DateTime?>? lastVerifiedAt,
    Value<String?>? lastErrorKind,
    Value<int>? rowid,
  }) {
    return SyncMetadataTableCompanion(
      key: key ?? this.key,
      nextOffset: nextOffset ?? this.nextOffset,
      totalCount: totalCount ?? this.totalCount,
      isComplete: isComplete ?? this.isComplete,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
      attempt: attempt ?? this.attempt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      lastErrorKind: lastErrorKind ?? this.lastErrorKind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (nextOffset.present) {
      map['next_offset'] = Variable<int>(nextOffset.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt.value);
    }
    if (lastErrorKind.present) {
      map['last_error_kind'] = Variable<String>(lastErrorKind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataTableCompanion(')
          ..write('key: $key, ')
          ..write('nextOffset: $nextOffset, ')
          ..write('totalCount: $totalCount, ')
          ..write('isComplete: $isComplete, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('lastErrorKind: $lastErrorKind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PokemonTableTable pokemonTable = $PokemonTableTable(this);
  late final $PokemonTypesTableTable pokemonTypesTable =
      $PokemonTypesTableTable(this);
  late final $PokemonStatsTableTable pokemonStatsTable =
      $PokemonStatsTableTable(this);
  late final $SpeciesTableTable speciesTable = $SpeciesTableTable(this);
  late final $SpeciesEggGroupsTableTable speciesEggGroupsTable =
      $SpeciesEggGroupsTableTable(this);
  late final $AbilitiesTableTable abilitiesTable = $AbilitiesTableTable(this);
  late final $PokemonAbilitiesTableTable pokemonAbilitiesTable =
      $PokemonAbilitiesTableTable(this);
  late final $MovesTableTable movesTable = $MovesTableTable(this);
  late final $PokemonMovesTableTable pokemonMovesTable =
      $PokemonMovesTableTable(this);
  late final $EvolutionsTableTable evolutionsTable = $EvolutionsTableTable(
    this,
  );
  late final $PokemonGamesTableTable pokemonGamesTable =
      $PokemonGamesTableTable(this);
  late final $TypeEfficacyTableTable typeEfficacyTable =
      $TypeEfficacyTableTable(this);
  late final $FavoritesTableTable favoritesTable = $FavoritesTableTable(this);
  late final $TriviaResultsTableTable triviaResultsTable =
      $TriviaResultsTableTable(this);
  late final $TriviaAnswersTableTable triviaAnswersTable =
      $TriviaAnswersTableTable(this);
  late final $AchievementsTableTable achievementsTable =
      $AchievementsTableTable(this);
  late final $UserPreferencesTableTable userPreferencesTable =
      $UserPreferencesTableTable(this);
  late final $SyncMetadataTableTable syncMetadataTable =
      $SyncMetadataTableTable(this);
  late final Index pokemonNameNocase = Index(
    'pokemon_name_nocase',
    'CREATE INDEX pokemon_name_nocase ON pokemon (name COLLATE NOCASE)',
  );
  late final Index pokemonGenerationId = Index(
    'pokemon_generation_id',
    'CREATE INDEX pokemon_generation_id ON pokemon (generation_id)',
  );
  late final Index pokemonBaseStatTotal = Index(
    'pokemon_base_stat_total',
    'CREATE INDEX pokemon_base_stat_total ON pokemon (base_stat_total)',
  );
  late final Index pokemonSpeciesId = Index(
    'pokemon_species_id',
    'CREATE INDEX pokemon_species_id ON pokemon (species_id)',
  );
  late final Index pokemonTypesByType = Index(
    'pokemon_types_by_type',
    'CREATE INDEX pokemon_types_by_type ON pokemon_types (type_name, pokemon_id)',
  );
  late final Index pokemonMovesByVersionAndMethod = Index(
    'pokemon_moves_by_version_and_method',
    'CREATE INDEX pokemon_moves_by_version_and_method ON pokemon_moves (pokemon_id, version_group, learn_method)',
  );
  late final Index triviaResultsByScore = Index(
    'trivia_results_by_score',
    'CREATE INDEX trivia_results_by_score ON trivia_results (score)',
  );
  late final CatalogDao catalogDao = CatalogDao(this as AppDatabase);
  late final SyncMetadataDao syncMetadataDao = SyncMetadataDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pokemonTable,
    pokemonTypesTable,
    pokemonStatsTable,
    speciesTable,
    speciesEggGroupsTable,
    abilitiesTable,
    pokemonAbilitiesTable,
    movesTable,
    pokemonMovesTable,
    evolutionsTable,
    pokemonGamesTable,
    typeEfficacyTable,
    favoritesTable,
    triviaResultsTable,
    triviaAnswersTable,
    achievementsTable,
    userPreferencesTable,
    syncMetadataTable,
    pokemonNameNocase,
    pokemonGenerationId,
    pokemonBaseStatTotal,
    pokemonSpeciesId,
    pokemonTypesByType,
    pokemonMovesByVersionAndMethod,
    triviaResultsByScore,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_types', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_stats', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'species',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('species_egg_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_abilities', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_moves', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_games', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trivia_results',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('trivia_answers', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PokemonTableTableCreateCompanionBuilder =
    PokemonTableCompanion Function({
      Value<int> id,
      required String name,
      required String imageUrl,
      required DateTime updatedAt,
      Value<int?> speciesId,
      Value<int?> generationId,
      Value<bool> isDefault,
      Value<int?> heightDm,
      Value<int?> weightHg,
      Value<int?> baseStatTotal,
      Value<String?> remoteFingerprint,
    });
typedef $$PokemonTableTableUpdateCompanionBuilder =
    PokemonTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> imageUrl,
      Value<DateTime> updatedAt,
      Value<int?> speciesId,
      Value<int?> generationId,
      Value<bool> isDefault,
      Value<int?> heightDm,
      Value<int?> weightHg,
      Value<int?> baseStatTotal,
      Value<String?> remoteFingerprint,
    });

final class $$PokemonTableTableReferences
    extends BaseReferences<_$AppDatabase, $PokemonTableTable, PokemonRow> {
  $$PokemonTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PokemonTypesTableTable, List<PokemonTypeRow>>
  _pokemonTypesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pokemonTypesTable,
        aliasName: 'pokemon__id__pokemon_types__pokemon_id',
      );

  $$PokemonTypesTableTableProcessedTableManager get pokemonTypesTableRefs {
    final manager = $$PokemonTypesTableTableTableManager(
      $_db,
      $_db.pokemonTypesTable,
    ).filter((f) => f.pokemonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pokemonTypesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PokemonStatsTableTable, List<PokemonStatRow>>
  _pokemonStatsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pokemonStatsTable,
        aliasName: 'pokemon__id__pokemon_stats__pokemon_id',
      );

  $$PokemonStatsTableTableProcessedTableManager get pokemonStatsTableRefs {
    final manager = $$PokemonStatsTableTableTableManager(
      $_db,
      $_db.pokemonStatsTable,
    ).filter((f) => f.pokemonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pokemonStatsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PokemonAbilitiesTableTable,
    List<PokemonAbilityRow>
  >
  _pokemonAbilitiesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pokemonAbilitiesTable,
        aliasName: 'pokemon__id__pokemon_abilities__pokemon_id',
      );

  $$PokemonAbilitiesTableTableProcessedTableManager
  get pokemonAbilitiesTableRefs {
    final manager = $$PokemonAbilitiesTableTableTableManager(
      $_db,
      $_db.pokemonAbilitiesTable,
    ).filter((f) => f.pokemonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pokemonAbilitiesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PokemonMovesTableTable, List<PokemonMoveRow>>
  _pokemonMovesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pokemonMovesTable,
        aliasName: 'pokemon__id__pokemon_moves__pokemon_id',
      );

  $$PokemonMovesTableTableProcessedTableManager get pokemonMovesTableRefs {
    final manager = $$PokemonMovesTableTableTableManager(
      $_db,
      $_db.pokemonMovesTable,
    ).filter((f) => f.pokemonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pokemonMovesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PokemonGamesTableTable, List<PokemonGameRow>>
  _pokemonGamesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pokemonGamesTable,
        aliasName: 'pokemon__id__pokemon_games__pokemon_id',
      );

  $$PokemonGamesTableTableProcessedTableManager get pokemonGamesTableRefs {
    final manager = $$PokemonGamesTableTableTableManager(
      $_db,
      $_db.pokemonGamesTable,
    ).filter((f) => f.pokemonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pokemonGamesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PokemonTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generationId => $composableBuilder(
    column: $table.generationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightDm => $composableBuilder(
    column: $table.heightDm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weightHg => $composableBuilder(
    column: $table.weightHg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseStatTotal => $composableBuilder(
    column: $table.baseStatTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteFingerprint => $composableBuilder(
    column: $table.remoteFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pokemonTypesTableRefs(
    Expression<bool> Function($$PokemonTypesTableTableFilterComposer f) f,
  ) {
    final $$PokemonTypesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pokemonTypesTable,
      getReferencedColumn: (t) => t.pokemonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTypesTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonTypesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pokemonStatsTableRefs(
    Expression<bool> Function($$PokemonStatsTableTableFilterComposer f) f,
  ) {
    final $$PokemonStatsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pokemonStatsTable,
      getReferencedColumn: (t) => t.pokemonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonStatsTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonStatsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pokemonAbilitiesTableRefs(
    Expression<bool> Function($$PokemonAbilitiesTableTableFilterComposer f) f,
  ) {
    final $$PokemonAbilitiesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonAbilitiesTable,
          getReferencedColumn: (t) => t.pokemonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonAbilitiesTableTableFilterComposer(
                $db: $db,
                $table: $db.pokemonAbilitiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> pokemonMovesTableRefs(
    Expression<bool> Function($$PokemonMovesTableTableFilterComposer f) f,
  ) {
    final $$PokemonMovesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pokemonMovesTable,
      getReferencedColumn: (t) => t.pokemonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonMovesTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonMovesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pokemonGamesTableRefs(
    Expression<bool> Function($$PokemonGamesTableTableFilterComposer f) f,
  ) {
    final $$PokemonGamesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pokemonGamesTable,
      getReferencedColumn: (t) => t.pokemonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonGamesTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonGamesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PokemonTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generationId => $composableBuilder(
    column: $table.generationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightDm => $composableBuilder(
    column: $table.heightDm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightHg => $composableBuilder(
    column: $table.weightHg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseStatTotal => $composableBuilder(
    column: $table.baseStatTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteFingerprint => $composableBuilder(
    column: $table.remoteFingerprint,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PokemonTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<int> get generationId => $composableBuilder(
    column: $table.generationId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get heightDm =>
      $composableBuilder(column: $table.heightDm, builder: (column) => column);

  GeneratedColumn<int> get weightHg =>
      $composableBuilder(column: $table.weightHg, builder: (column) => column);

  GeneratedColumn<int> get baseStatTotal => $composableBuilder(
    column: $table.baseStatTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteFingerprint => $composableBuilder(
    column: $table.remoteFingerprint,
    builder: (column) => column,
  );

  Expression<T> pokemonTypesTableRefs<T extends Object>(
    Expression<T> Function($$PokemonTypesTableTableAnnotationComposer a) f,
  ) {
    final $$PokemonTypesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonTypesTable,
          getReferencedColumn: (t) => t.pokemonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonTypesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pokemonTypesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> pokemonStatsTableRefs<T extends Object>(
    Expression<T> Function($$PokemonStatsTableTableAnnotationComposer a) f,
  ) {
    final $$PokemonStatsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonStatsTable,
          getReferencedColumn: (t) => t.pokemonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonStatsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pokemonStatsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> pokemonAbilitiesTableRefs<T extends Object>(
    Expression<T> Function($$PokemonAbilitiesTableTableAnnotationComposer a) f,
  ) {
    final $$PokemonAbilitiesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonAbilitiesTable,
          getReferencedColumn: (t) => t.pokemonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonAbilitiesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pokemonAbilitiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> pokemonMovesTableRefs<T extends Object>(
    Expression<T> Function($$PokemonMovesTableTableAnnotationComposer a) f,
  ) {
    final $$PokemonMovesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonMovesTable,
          getReferencedColumn: (t) => t.pokemonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonMovesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pokemonMovesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> pokemonGamesTableRefs<T extends Object>(
    Expression<T> Function($$PokemonGamesTableTableAnnotationComposer a) f,
  ) {
    final $$PokemonGamesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonGamesTable,
          getReferencedColumn: (t) => t.pokemonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonGamesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pokemonGamesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PokemonTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonTableTable,
          PokemonRow,
          $$PokemonTableTableFilterComposer,
          $$PokemonTableTableOrderingComposer,
          $$PokemonTableTableAnnotationComposer,
          $$PokemonTableTableCreateCompanionBuilder,
          $$PokemonTableTableUpdateCompanionBuilder,
          (PokemonRow, $$PokemonTableTableReferences),
          PokemonRow,
          PrefetchHooks Function({
            bool pokemonTypesTableRefs,
            bool pokemonStatsTableRefs,
            bool pokemonAbilitiesTableRefs,
            bool pokemonMovesTableRefs,
            bool pokemonGamesTableRefs,
          })
        > {
  $$PokemonTableTableTableManager(_$AppDatabase db, $PokemonTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> speciesId = const Value.absent(),
                Value<int?> generationId = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int?> heightDm = const Value.absent(),
                Value<int?> weightHg = const Value.absent(),
                Value<int?> baseStatTotal = const Value.absent(),
                Value<String?> remoteFingerprint = const Value.absent(),
              }) => PokemonTableCompanion(
                id: id,
                name: name,
                imageUrl: imageUrl,
                updatedAt: updatedAt,
                speciesId: speciesId,
                generationId: generationId,
                isDefault: isDefault,
                heightDm: heightDm,
                weightHg: weightHg,
                baseStatTotal: baseStatTotal,
                remoteFingerprint: remoteFingerprint,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String imageUrl,
                required DateTime updatedAt,
                Value<int?> speciesId = const Value.absent(),
                Value<int?> generationId = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int?> heightDm = const Value.absent(),
                Value<int?> weightHg = const Value.absent(),
                Value<int?> baseStatTotal = const Value.absent(),
                Value<String?> remoteFingerprint = const Value.absent(),
              }) => PokemonTableCompanion.insert(
                id: id,
                name: name,
                imageUrl: imageUrl,
                updatedAt: updatedAt,
                speciesId: speciesId,
                generationId: generationId,
                isDefault: isDefault,
                heightDm: heightDm,
                weightHg: weightHg,
                baseStatTotal: baseStatTotal,
                remoteFingerprint: remoteFingerprint,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PokemonTableTable, PokemonRow>(table),
                  $$PokemonTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pokemonTypesTableRefs = false,
                pokemonStatsTableRefs = false,
                pokemonAbilitiesTableRefs = false,
                pokemonMovesTableRefs = false,
                pokemonGamesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pokemonTypesTableRefs) db.pokemonTypesTable,
                    if (pokemonStatsTableRefs) db.pokemonStatsTable,
                    if (pokemonAbilitiesTableRefs) db.pokemonAbilitiesTable,
                    if (pokemonMovesTableRefs) db.pokemonMovesTable,
                    if (pokemonGamesTableRefs) db.pokemonGamesTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pokemonTypesTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PokemonRow,
                          $PokemonTableTable,
                          PokemonTypeRow,
                          $PokemonTypesTableTable
                        >(
                          currentTable: table,
                          referencedTable: $$PokemonTableTableReferences
                              ._pokemonTypesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PokemonTableTableReferences(
                                db,
                                table,
                                p0,
                              ).pokemonTypesTableRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pokemon_id',
                          typedResults: items,
                        ),
                      if (pokemonStatsTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PokemonRow,
                          $PokemonTableTable,
                          PokemonStatRow,
                          $PokemonStatsTableTable
                        >(
                          currentTable: table,
                          referencedTable: $$PokemonTableTableReferences
                              ._pokemonStatsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PokemonTableTableReferences(
                                db,
                                table,
                                p0,
                              ).pokemonStatsTableRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pokemon_id',
                          typedResults: items,
                        ),
                      if (pokemonAbilitiesTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PokemonRow,
                          $PokemonTableTable,
                          PokemonAbilityRow,
                          $PokemonAbilitiesTableTable
                        >(
                          currentTable: table,
                          referencedTable: $$PokemonTableTableReferences
                              ._pokemonAbilitiesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PokemonTableTableReferences(
                                db,
                                table,
                                p0,
                              ).pokemonAbilitiesTableRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pokemon_id',
                          typedResults: items,
                        ),
                      if (pokemonMovesTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PokemonRow,
                          $PokemonTableTable,
                          PokemonMoveRow,
                          $PokemonMovesTableTable
                        >(
                          currentTable: table,
                          referencedTable: $$PokemonTableTableReferences
                              ._pokemonMovesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PokemonTableTableReferences(
                                db,
                                table,
                                p0,
                              ).pokemonMovesTableRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pokemon_id',
                          typedResults: items,
                        ),
                      if (pokemonGamesTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PokemonRow,
                          $PokemonTableTable,
                          PokemonGameRow,
                          $PokemonGamesTableTable
                        >(
                          currentTable: table,
                          referencedTable: $$PokemonTableTableReferences
                              ._pokemonGamesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PokemonTableTableReferences(
                                db,
                                table,
                                p0,
                              ).pokemonGamesTableRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pokemon_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PokemonTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonTableTable,
      PokemonRow,
      $$PokemonTableTableFilterComposer,
      $$PokemonTableTableOrderingComposer,
      $$PokemonTableTableAnnotationComposer,
      $$PokemonTableTableCreateCompanionBuilder,
      $$PokemonTableTableUpdateCompanionBuilder,
      (PokemonRow, $$PokemonTableTableReferences),
      PokemonRow,
      PrefetchHooks Function({
        bool pokemonTypesTableRefs,
        bool pokemonStatsTableRefs,
        bool pokemonAbilitiesTableRefs,
        bool pokemonMovesTableRefs,
        bool pokemonGamesTableRefs,
      })
    >;
typedef $$PokemonTypesTableTableCreateCompanionBuilder =
    PokemonTypesTableCompanion Function({
      required int pokemonId,
      required int slot,
      required String typeName,
      Value<int> rowid,
    });
typedef $$PokemonTypesTableTableUpdateCompanionBuilder =
    PokemonTypesTableCompanion Function({
      Value<int> pokemonId,
      Value<int> slot,
      Value<String> typeName,
      Value<int> rowid,
    });

final class $$PokemonTypesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PokemonTypesTableTable, PokemonTypeRow> {
  $$PokemonTypesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PokemonTableTable _pokemonIdTable(_$AppDatabase db) =>
      db.pokemonTable.createAlias('pokemon_types__pokemon_id__pokemon__id');

  $$PokemonTableTableProcessedTableManager get pokemonId {
    final $_column = $_itemColumn<int>('pokemon_id')!;

    final manager = $$PokemonTableTableTableManager(
      $_db,
      $_db.pokemonTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pokemonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PokemonTypesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonTypesTableTable> {
  $$PokemonTypesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnFilters(column),
  );

  $$PokemonTableTableFilterComposer get pokemonId {
    final $$PokemonTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonTypesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonTypesTableTable> {
  $$PokemonTypesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnOrderings(column),
  );

  $$PokemonTableTableOrderingComposer get pokemonId {
    final $$PokemonTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableOrderingComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonTypesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonTypesTableTable> {
  $$PokemonTypesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get typeName =>
      $composableBuilder(column: $table.typeName, builder: (column) => column);

  $$PokemonTableTableAnnotationComposer get pokemonId {
    final $$PokemonTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonTypesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonTypesTableTable,
          PokemonTypeRow,
          $$PokemonTypesTableTableFilterComposer,
          $$PokemonTypesTableTableOrderingComposer,
          $$PokemonTypesTableTableAnnotationComposer,
          $$PokemonTypesTableTableCreateCompanionBuilder,
          $$PokemonTypesTableTableUpdateCompanionBuilder,
          (PokemonTypeRow, $$PokemonTypesTableTableReferences),
          PokemonTypeRow,
          PrefetchHooks Function({bool pokemonId})
        > {
  $$PokemonTypesTableTableTableManager(
    _$AppDatabase db,
    $PokemonTypesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonTypesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonTypesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonTypesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pokemonId = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<String> typeName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonTypesTableCompanion(
                pokemonId: pokemonId,
                slot: slot,
                typeName: typeName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pokemonId,
                required int slot,
                required String typeName,
                Value<int> rowid = const Value.absent(),
              }) => PokemonTypesTableCompanion.insert(
                pokemonId: pokemonId,
                slot: slot,
                typeName: typeName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PokemonTypesTableTable, PokemonTypeRow>(table),
                  $$PokemonTypesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pokemonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pokemonId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pokemonId,
                        referencedTable: $$PokemonTypesTableTableReferences
                            ._pokemonIdTable(db),
                        referencedColumn: $$PokemonTypesTableTableReferences
                            ._pokemonIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PokemonTypesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonTypesTableTable,
      PokemonTypeRow,
      $$PokemonTypesTableTableFilterComposer,
      $$PokemonTypesTableTableOrderingComposer,
      $$PokemonTypesTableTableAnnotationComposer,
      $$PokemonTypesTableTableCreateCompanionBuilder,
      $$PokemonTypesTableTableUpdateCompanionBuilder,
      (PokemonTypeRow, $$PokemonTypesTableTableReferences),
      PokemonTypeRow,
      PrefetchHooks Function({bool pokemonId})
    >;
typedef $$PokemonStatsTableTableCreateCompanionBuilder =
    PokemonStatsTableCompanion Function({
      required int pokemonId,
      required String statName,
      required int baseStat,
      Value<int> rowid,
    });
typedef $$PokemonStatsTableTableUpdateCompanionBuilder =
    PokemonStatsTableCompanion Function({
      Value<int> pokemonId,
      Value<String> statName,
      Value<int> baseStat,
      Value<int> rowid,
    });

final class $$PokemonStatsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PokemonStatsTableTable, PokemonStatRow> {
  $$PokemonStatsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PokemonTableTable _pokemonIdTable(_$AppDatabase db) =>
      db.pokemonTable.createAlias('pokemon_stats__pokemon_id__pokemon__id');

  $$PokemonTableTableProcessedTableManager get pokemonId {
    final $_column = $_itemColumn<int>('pokemon_id')!;

    final manager = $$PokemonTableTableTableManager(
      $_db,
      $_db.pokemonTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pokemonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PokemonStatsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonStatsTableTable> {
  $$PokemonStatsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get statName => $composableBuilder(
    column: $table.statName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseStat => $composableBuilder(
    column: $table.baseStat,
    builder: (column) => ColumnFilters(column),
  );

  $$PokemonTableTableFilterComposer get pokemonId {
    final $$PokemonTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonStatsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonStatsTableTable> {
  $$PokemonStatsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get statName => $composableBuilder(
    column: $table.statName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseStat => $composableBuilder(
    column: $table.baseStat,
    builder: (column) => ColumnOrderings(column),
  );

  $$PokemonTableTableOrderingComposer get pokemonId {
    final $$PokemonTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableOrderingComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonStatsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonStatsTableTable> {
  $$PokemonStatsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get statName =>
      $composableBuilder(column: $table.statName, builder: (column) => column);

  GeneratedColumn<int> get baseStat =>
      $composableBuilder(column: $table.baseStat, builder: (column) => column);

  $$PokemonTableTableAnnotationComposer get pokemonId {
    final $$PokemonTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonStatsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonStatsTableTable,
          PokemonStatRow,
          $$PokemonStatsTableTableFilterComposer,
          $$PokemonStatsTableTableOrderingComposer,
          $$PokemonStatsTableTableAnnotationComposer,
          $$PokemonStatsTableTableCreateCompanionBuilder,
          $$PokemonStatsTableTableUpdateCompanionBuilder,
          (PokemonStatRow, $$PokemonStatsTableTableReferences),
          PokemonStatRow,
          PrefetchHooks Function({bool pokemonId})
        > {
  $$PokemonStatsTableTableTableManager(
    _$AppDatabase db,
    $PokemonStatsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonStatsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonStatsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonStatsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pokemonId = const Value.absent(),
                Value<String> statName = const Value.absent(),
                Value<int> baseStat = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonStatsTableCompanion(
                pokemonId: pokemonId,
                statName: statName,
                baseStat: baseStat,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pokemonId,
                required String statName,
                required int baseStat,
                Value<int> rowid = const Value.absent(),
              }) => PokemonStatsTableCompanion.insert(
                pokemonId: pokemonId,
                statName: statName,
                baseStat: baseStat,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PokemonStatsTableTable, PokemonStatRow>(table),
                  $$PokemonStatsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pokemonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pokemonId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pokemonId,
                        referencedTable: $$PokemonStatsTableTableReferences
                            ._pokemonIdTable(db),
                        referencedColumn: $$PokemonStatsTableTableReferences
                            ._pokemonIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PokemonStatsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonStatsTableTable,
      PokemonStatRow,
      $$PokemonStatsTableTableFilterComposer,
      $$PokemonStatsTableTableOrderingComposer,
      $$PokemonStatsTableTableAnnotationComposer,
      $$PokemonStatsTableTableCreateCompanionBuilder,
      $$PokemonStatsTableTableUpdateCompanionBuilder,
      (PokemonStatRow, $$PokemonStatsTableTableReferences),
      PokemonStatRow,
      PrefetchHooks Function({bool pokemonId})
    >;
typedef $$SpeciesTableTableCreateCompanionBuilder =
    SpeciesTableCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> generationId,
      Value<int?> evolutionChainId,
    });
typedef $$SpeciesTableTableUpdateCompanionBuilder =
    SpeciesTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> generationId,
      Value<int?> evolutionChainId,
    });

final class $$SpeciesTableTableReferences
    extends BaseReferences<_$AppDatabase, $SpeciesTableTable, SpeciesRow> {
  $$SpeciesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $SpeciesEggGroupsTableTable,
    List<SpeciesEggGroupRow>
  >
  _speciesEggGroupsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.speciesEggGroupsTable,
        aliasName: 'species__id__species_egg_groups__species_id',
      );

  $$SpeciesEggGroupsTableTableProcessedTableManager
  get speciesEggGroupsTableRefs {
    final manager = $$SpeciesEggGroupsTableTableTableManager(
      $_db,
      $_db.speciesEggGroupsTable,
    ).filter((f) => f.speciesId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _speciesEggGroupsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SpeciesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesTableTable> {
  $$SpeciesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generationId => $composableBuilder(
    column: $table.generationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get evolutionChainId => $composableBuilder(
    column: $table.evolutionChainId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> speciesEggGroupsTableRefs(
    Expression<bool> Function($$SpeciesEggGroupsTableTableFilterComposer f) f,
  ) {
    final $$SpeciesEggGroupsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.speciesEggGroupsTable,
          getReferencedColumn: (t) => t.speciesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SpeciesEggGroupsTableTableFilterComposer(
                $db: $db,
                $table: $db.speciesEggGroupsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SpeciesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesTableTable> {
  $$SpeciesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generationId => $composableBuilder(
    column: $table.generationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get evolutionChainId => $composableBuilder(
    column: $table.evolutionChainId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesTableTable> {
  $$SpeciesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get generationId => $composableBuilder(
    column: $table.generationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get evolutionChainId => $composableBuilder(
    column: $table.evolutionChainId,
    builder: (column) => column,
  );

  Expression<T> speciesEggGroupsTableRefs<T extends Object>(
    Expression<T> Function($$SpeciesEggGroupsTableTableAnnotationComposer a) f,
  ) {
    final $$SpeciesEggGroupsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.speciesEggGroupsTable,
          getReferencedColumn: (t) => t.speciesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SpeciesEggGroupsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.speciesEggGroupsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SpeciesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesTableTable,
          SpeciesRow,
          $$SpeciesTableTableFilterComposer,
          $$SpeciesTableTableOrderingComposer,
          $$SpeciesTableTableAnnotationComposer,
          $$SpeciesTableTableCreateCompanionBuilder,
          $$SpeciesTableTableUpdateCompanionBuilder,
          (SpeciesRow, $$SpeciesTableTableReferences),
          SpeciesRow,
          PrefetchHooks Function({bool speciesEggGroupsTableRefs})
        > {
  $$SpeciesTableTableTableManager(_$AppDatabase db, $SpeciesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> generationId = const Value.absent(),
                Value<int?> evolutionChainId = const Value.absent(),
              }) => SpeciesTableCompanion(
                id: id,
                name: name,
                generationId: generationId,
                evolutionChainId: evolutionChainId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> generationId = const Value.absent(),
                Value<int?> evolutionChainId = const Value.absent(),
              }) => SpeciesTableCompanion.insert(
                id: id,
                name: name,
                generationId: generationId,
                evolutionChainId: evolutionChainId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpeciesTableTable, SpeciesRow>(table),
                  $$SpeciesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({speciesEggGroupsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (speciesEggGroupsTableRefs) db.speciesEggGroupsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (speciesEggGroupsTableRefs)
                    await $_getPrefetchedDataByColumns<
                      SpeciesRow,
                      $SpeciesTableTable,
                      SpeciesEggGroupRow,
                      $SpeciesEggGroupsTableTable
                    >(
                      currentTable: table,
                      referencedTable: $$SpeciesTableTableReferences
                          ._speciesEggGroupsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SpeciesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).speciesEggGroupsTableRefs,
                      currentColumn: 'id',
                      referencedColumn: 'species_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SpeciesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesTableTable,
      SpeciesRow,
      $$SpeciesTableTableFilterComposer,
      $$SpeciesTableTableOrderingComposer,
      $$SpeciesTableTableAnnotationComposer,
      $$SpeciesTableTableCreateCompanionBuilder,
      $$SpeciesTableTableUpdateCompanionBuilder,
      (SpeciesRow, $$SpeciesTableTableReferences),
      SpeciesRow,
      PrefetchHooks Function({bool speciesEggGroupsTableRefs})
    >;
typedef $$SpeciesEggGroupsTableTableCreateCompanionBuilder =
    SpeciesEggGroupsTableCompanion Function({
      required int speciesId,
      required String eggGroup,
      Value<int> rowid,
    });
typedef $$SpeciesEggGroupsTableTableUpdateCompanionBuilder =
    SpeciesEggGroupsTableCompanion Function({
      Value<int> speciesId,
      Value<String> eggGroup,
      Value<int> rowid,
    });

final class $$SpeciesEggGroupsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SpeciesEggGroupsTableTable,
          SpeciesEggGroupRow
        > {
  $$SpeciesEggGroupsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SpeciesTableTable _speciesIdTable(_$AppDatabase db) => db.speciesTable
      .createAlias('species_egg_groups__species_id__species__id');

  $$SpeciesTableTableProcessedTableManager get speciesId {
    final $_column = $_itemColumn<int>('species_id')!;

    final manager = $$SpeciesTableTableTableManager(
      $_db,
      $_db.speciesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_speciesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SpeciesEggGroupsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesEggGroupsTableTable> {
  $$SpeciesEggGroupsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eggGroup => $composableBuilder(
    column: $table.eggGroup,
    builder: (column) => ColumnFilters(column),
  );

  $$SpeciesTableTableFilterComposer get speciesId {
    final $$SpeciesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpeciesTableTableFilterComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpeciesEggGroupsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesEggGroupsTableTable> {
  $$SpeciesEggGroupsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eggGroup => $composableBuilder(
    column: $table.eggGroup,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpeciesTableTableOrderingComposer get speciesId {
    final $$SpeciesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpeciesTableTableOrderingComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpeciesEggGroupsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesEggGroupsTableTable> {
  $$SpeciesEggGroupsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eggGroup =>
      $composableBuilder(column: $table.eggGroup, builder: (column) => column);

  $$SpeciesTableTableAnnotationComposer get speciesId {
    final $$SpeciesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpeciesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpeciesEggGroupsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesEggGroupsTableTable,
          SpeciesEggGroupRow,
          $$SpeciesEggGroupsTableTableFilterComposer,
          $$SpeciesEggGroupsTableTableOrderingComposer,
          $$SpeciesEggGroupsTableTableAnnotationComposer,
          $$SpeciesEggGroupsTableTableCreateCompanionBuilder,
          $$SpeciesEggGroupsTableTableUpdateCompanionBuilder,
          (SpeciesEggGroupRow, $$SpeciesEggGroupsTableTableReferences),
          SpeciesEggGroupRow,
          PrefetchHooks Function({bool speciesId})
        > {
  $$SpeciesEggGroupsTableTableTableManager(
    _$AppDatabase db,
    $SpeciesEggGroupsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesEggGroupsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SpeciesEggGroupsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SpeciesEggGroupsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> speciesId = const Value.absent(),
                Value<String> eggGroup = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpeciesEggGroupsTableCompanion(
                speciesId: speciesId,
                eggGroup: eggGroup,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int speciesId,
                required String eggGroup,
                Value<int> rowid = const Value.absent(),
              }) => SpeciesEggGroupsTableCompanion.insert(
                speciesId: speciesId,
                eggGroup: eggGroup,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpeciesEggGroupsTableTable, SpeciesEggGroupRow>(
                    table,
                  ),
                  $$SpeciesEggGroupsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({speciesId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (speciesId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.speciesId,
                        referencedTable: $$SpeciesEggGroupsTableTableReferences
                            ._speciesIdTable(db),
                        referencedColumn: $$SpeciesEggGroupsTableTableReferences
                            ._speciesIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SpeciesEggGroupsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesEggGroupsTableTable,
      SpeciesEggGroupRow,
      $$SpeciesEggGroupsTableTableFilterComposer,
      $$SpeciesEggGroupsTableTableOrderingComposer,
      $$SpeciesEggGroupsTableTableAnnotationComposer,
      $$SpeciesEggGroupsTableTableCreateCompanionBuilder,
      $$SpeciesEggGroupsTableTableUpdateCompanionBuilder,
      (SpeciesEggGroupRow, $$SpeciesEggGroupsTableTableReferences),
      SpeciesEggGroupRow,
      PrefetchHooks Function({bool speciesId})
    >;
typedef $$AbilitiesTableTableCreateCompanionBuilder =
    AbilitiesTableCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> nameEs,
      Value<String?> shortEffectEs,
      Value<String?> shortEffectEn,
    });
typedef $$AbilitiesTableTableUpdateCompanionBuilder =
    AbilitiesTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> nameEs,
      Value<String?> shortEffectEs,
      Value<String?> shortEffectEn,
    });

class $$AbilitiesTableTableFilterComposer
    extends Composer<_$AppDatabase, $AbilitiesTableTable> {
  $$AbilitiesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortEffectEs => $composableBuilder(
    column: $table.shortEffectEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortEffectEn => $composableBuilder(
    column: $table.shortEffectEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AbilitiesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AbilitiesTableTable> {
  $$AbilitiesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortEffectEs => $composableBuilder(
    column: $table.shortEffectEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortEffectEn => $composableBuilder(
    column: $table.shortEffectEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AbilitiesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AbilitiesTableTable> {
  $$AbilitiesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameEs =>
      $composableBuilder(column: $table.nameEs, builder: (column) => column);

  GeneratedColumn<String> get shortEffectEs => $composableBuilder(
    column: $table.shortEffectEs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shortEffectEn => $composableBuilder(
    column: $table.shortEffectEn,
    builder: (column) => column,
  );
}

class $$AbilitiesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AbilitiesTableTable,
          AbilityRow,
          $$AbilitiesTableTableFilterComposer,
          $$AbilitiesTableTableOrderingComposer,
          $$AbilitiesTableTableAnnotationComposer,
          $$AbilitiesTableTableCreateCompanionBuilder,
          $$AbilitiesTableTableUpdateCompanionBuilder,
          (
            AbilityRow,
            BaseReferences<_$AppDatabase, $AbilitiesTableTable, AbilityRow>,
          ),
          AbilityRow,
          PrefetchHooks Function()
        > {
  $$AbilitiesTableTableTableManager(
    _$AppDatabase db,
    $AbilitiesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AbilitiesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AbilitiesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AbilitiesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nameEs = const Value.absent(),
                Value<String?> shortEffectEs = const Value.absent(),
                Value<String?> shortEffectEn = const Value.absent(),
              }) => AbilitiesTableCompanion(
                id: id,
                name: name,
                nameEs: nameEs,
                shortEffectEs: shortEffectEs,
                shortEffectEn: shortEffectEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> nameEs = const Value.absent(),
                Value<String?> shortEffectEs = const Value.absent(),
                Value<String?> shortEffectEn = const Value.absent(),
              }) => AbilitiesTableCompanion.insert(
                id: id,
                name: name,
                nameEs: nameEs,
                shortEffectEs: shortEffectEs,
                shortEffectEn: shortEffectEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AbilitiesTableTable, AbilityRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AbilitiesTableTable,
                    AbilityRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AbilitiesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AbilitiesTableTable,
      AbilityRow,
      $$AbilitiesTableTableFilterComposer,
      $$AbilitiesTableTableOrderingComposer,
      $$AbilitiesTableTableAnnotationComposer,
      $$AbilitiesTableTableCreateCompanionBuilder,
      $$AbilitiesTableTableUpdateCompanionBuilder,
      (
        AbilityRow,
        BaseReferences<_$AppDatabase, $AbilitiesTableTable, AbilityRow>,
      ),
      AbilityRow,
      PrefetchHooks Function()
    >;
typedef $$PokemonAbilitiesTableTableCreateCompanionBuilder =
    PokemonAbilitiesTableCompanion Function({
      required int pokemonId,
      required int abilityId,
      required int slot,
      required bool isHidden,
      Value<int> rowid,
    });
typedef $$PokemonAbilitiesTableTableUpdateCompanionBuilder =
    PokemonAbilitiesTableCompanion Function({
      Value<int> pokemonId,
      Value<int> abilityId,
      Value<int> slot,
      Value<bool> isHidden,
      Value<int> rowid,
    });

final class $$PokemonAbilitiesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PokemonAbilitiesTableTable,
          PokemonAbilityRow
        > {
  $$PokemonAbilitiesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PokemonTableTable _pokemonIdTable(_$AppDatabase db) =>
      db.pokemonTable.createAlias('pokemon_abilities__pokemon_id__pokemon__id');

  $$PokemonTableTableProcessedTableManager get pokemonId {
    final $_column = $_itemColumn<int>('pokemon_id')!;

    final manager = $$PokemonTableTableTableManager(
      $_db,
      $_db.pokemonTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pokemonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PokemonAbilitiesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonAbilitiesTableTable> {
  $$PokemonAbilitiesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get abilityId => $composableBuilder(
    column: $table.abilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  $$PokemonTableTableFilterComposer get pokemonId {
    final $$PokemonTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonAbilitiesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonAbilitiesTableTable> {
  $$PokemonAbilitiesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get abilityId => $composableBuilder(
    column: $table.abilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  $$PokemonTableTableOrderingComposer get pokemonId {
    final $$PokemonTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableOrderingComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonAbilitiesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonAbilitiesTableTable> {
  $$PokemonAbilitiesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get abilityId =>
      $composableBuilder(column: $table.abilityId, builder: (column) => column);

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  $$PokemonTableTableAnnotationComposer get pokemonId {
    final $$PokemonTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonAbilitiesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonAbilitiesTableTable,
          PokemonAbilityRow,
          $$PokemonAbilitiesTableTableFilterComposer,
          $$PokemonAbilitiesTableTableOrderingComposer,
          $$PokemonAbilitiesTableTableAnnotationComposer,
          $$PokemonAbilitiesTableTableCreateCompanionBuilder,
          $$PokemonAbilitiesTableTableUpdateCompanionBuilder,
          (PokemonAbilityRow, $$PokemonAbilitiesTableTableReferences),
          PokemonAbilityRow,
          PrefetchHooks Function({bool pokemonId})
        > {
  $$PokemonAbilitiesTableTableTableManager(
    _$AppDatabase db,
    $PokemonAbilitiesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonAbilitiesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PokemonAbilitiesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PokemonAbilitiesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pokemonId = const Value.absent(),
                Value<int> abilityId = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonAbilitiesTableCompanion(
                pokemonId: pokemonId,
                abilityId: abilityId,
                slot: slot,
                isHidden: isHidden,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pokemonId,
                required int abilityId,
                required int slot,
                required bool isHidden,
                Value<int> rowid = const Value.absent(),
              }) => PokemonAbilitiesTableCompanion.insert(
                pokemonId: pokemonId,
                abilityId: abilityId,
                slot: slot,
                isHidden: isHidden,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PokemonAbilitiesTableTable, PokemonAbilityRow>(
                    table,
                  ),
                  $$PokemonAbilitiesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pokemonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pokemonId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pokemonId,
                        referencedTable: $$PokemonAbilitiesTableTableReferences
                            ._pokemonIdTable(db),
                        referencedColumn: $$PokemonAbilitiesTableTableReferences
                            ._pokemonIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PokemonAbilitiesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonAbilitiesTableTable,
      PokemonAbilityRow,
      $$PokemonAbilitiesTableTableFilterComposer,
      $$PokemonAbilitiesTableTableOrderingComposer,
      $$PokemonAbilitiesTableTableAnnotationComposer,
      $$PokemonAbilitiesTableTableCreateCompanionBuilder,
      $$PokemonAbilitiesTableTableUpdateCompanionBuilder,
      (PokemonAbilityRow, $$PokemonAbilitiesTableTableReferences),
      PokemonAbilityRow,
      PrefetchHooks Function({bool pokemonId})
    >;
typedef $$MovesTableTableCreateCompanionBuilder = MovesTableCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> nameEs,
  Value<String?> typeName,
});
typedef $$MovesTableTableUpdateCompanionBuilder = MovesTableCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> nameEs,
  Value<String?> typeName,
});

class $$MovesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MovesTableTable> {
  $$MovesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MovesTableTable> {
  $$MovesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEs => $composableBuilder(
    column: $table.nameEs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovesTableTable> {
  $$MovesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameEs =>
      $composableBuilder(column: $table.nameEs, builder: (column) => column);

  GeneratedColumn<String> get typeName =>
      $composableBuilder(column: $table.typeName, builder: (column) => column);
}

class $$MovesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovesTableTable,
          MoveRow,
          $$MovesTableTableFilterComposer,
          $$MovesTableTableOrderingComposer,
          $$MovesTableTableAnnotationComposer,
          $$MovesTableTableCreateCompanionBuilder,
          $$MovesTableTableUpdateCompanionBuilder,
          (MoveRow, BaseReferences<_$AppDatabase, $MovesTableTable, MoveRow>),
          MoveRow,
          PrefetchHooks Function()
        > {
  $$MovesTableTableTableManager(_$AppDatabase db, $MovesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nameEs = const Value.absent(),
                Value<String?> typeName = const Value.absent(),
              }) => MovesTableCompanion(
                id: id,
                name: name,
                nameEs: nameEs,
                typeName: typeName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> nameEs = const Value.absent(),
                Value<String?> typeName = const Value.absent(),
              }) => MovesTableCompanion.insert(
                id: id,
                name: name,
                nameEs: nameEs,
                typeName: typeName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MovesTableTable, MoveRow>(table),
                  BaseReferences<_$AppDatabase, $MovesTableTable, MoveRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovesTableTable,
      MoveRow,
      $$MovesTableTableFilterComposer,
      $$MovesTableTableOrderingComposer,
      $$MovesTableTableAnnotationComposer,
      $$MovesTableTableCreateCompanionBuilder,
      $$MovesTableTableUpdateCompanionBuilder,
      (MoveRow, BaseReferences<_$AppDatabase, $MovesTableTable, MoveRow>),
      MoveRow,
      PrefetchHooks Function()
    >;
typedef $$PokemonMovesTableTableCreateCompanionBuilder =
    PokemonMovesTableCompanion Function({
      required int pokemonId,
      required int moveId,
      required String versionGroup,
      required String learnMethod,
      required int level,
      Value<int> rowid,
    });
typedef $$PokemonMovesTableTableUpdateCompanionBuilder =
    PokemonMovesTableCompanion Function({
      Value<int> pokemonId,
      Value<int> moveId,
      Value<String> versionGroup,
      Value<String> learnMethod,
      Value<int> level,
      Value<int> rowid,
    });

final class $$PokemonMovesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PokemonMovesTableTable, PokemonMoveRow> {
  $$PokemonMovesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PokemonTableTable _pokemonIdTable(_$AppDatabase db) =>
      db.pokemonTable.createAlias('pokemon_moves__pokemon_id__pokemon__id');

  $$PokemonTableTableProcessedTableManager get pokemonId {
    final $_column = $_itemColumn<int>('pokemon_id')!;

    final manager = $$PokemonTableTableTableManager(
      $_db,
      $_db.pokemonTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pokemonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PokemonMovesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonMovesTableTable> {
  $$PokemonMovesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get moveId => $composableBuilder(
    column: $table.moveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionGroup => $composableBuilder(
    column: $table.versionGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learnMethod => $composableBuilder(
    column: $table.learnMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  $$PokemonTableTableFilterComposer get pokemonId {
    final $$PokemonTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonMovesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonMovesTableTable> {
  $$PokemonMovesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get moveId => $composableBuilder(
    column: $table.moveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionGroup => $composableBuilder(
    column: $table.versionGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learnMethod => $composableBuilder(
    column: $table.learnMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  $$PokemonTableTableOrderingComposer get pokemonId {
    final $$PokemonTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableOrderingComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonMovesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonMovesTableTable> {
  $$PokemonMovesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get moveId =>
      $composableBuilder(column: $table.moveId, builder: (column) => column);

  GeneratedColumn<String> get versionGroup => $composableBuilder(
    column: $table.versionGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learnMethod => $composableBuilder(
    column: $table.learnMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  $$PokemonTableTableAnnotationComposer get pokemonId {
    final $$PokemonTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonMovesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonMovesTableTable,
          PokemonMoveRow,
          $$PokemonMovesTableTableFilterComposer,
          $$PokemonMovesTableTableOrderingComposer,
          $$PokemonMovesTableTableAnnotationComposer,
          $$PokemonMovesTableTableCreateCompanionBuilder,
          $$PokemonMovesTableTableUpdateCompanionBuilder,
          (PokemonMoveRow, $$PokemonMovesTableTableReferences),
          PokemonMoveRow,
          PrefetchHooks Function({bool pokemonId})
        > {
  $$PokemonMovesTableTableTableManager(
    _$AppDatabase db,
    $PokemonMovesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonMovesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonMovesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonMovesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pokemonId = const Value.absent(),
                Value<int> moveId = const Value.absent(),
                Value<String> versionGroup = const Value.absent(),
                Value<String> learnMethod = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonMovesTableCompanion(
                pokemonId: pokemonId,
                moveId: moveId,
                versionGroup: versionGroup,
                learnMethod: learnMethod,
                level: level,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pokemonId,
                required int moveId,
                required String versionGroup,
                required String learnMethod,
                required int level,
                Value<int> rowid = const Value.absent(),
              }) => PokemonMovesTableCompanion.insert(
                pokemonId: pokemonId,
                moveId: moveId,
                versionGroup: versionGroup,
                learnMethod: learnMethod,
                level: level,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PokemonMovesTableTable, PokemonMoveRow>(table),
                  $$PokemonMovesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pokemonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pokemonId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pokemonId,
                        referencedTable: $$PokemonMovesTableTableReferences
                            ._pokemonIdTable(db),
                        referencedColumn: $$PokemonMovesTableTableReferences
                            ._pokemonIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PokemonMovesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonMovesTableTable,
      PokemonMoveRow,
      $$PokemonMovesTableTableFilterComposer,
      $$PokemonMovesTableTableOrderingComposer,
      $$PokemonMovesTableTableAnnotationComposer,
      $$PokemonMovesTableTableCreateCompanionBuilder,
      $$PokemonMovesTableTableUpdateCompanionBuilder,
      (PokemonMoveRow, $$PokemonMovesTableTableReferences),
      PokemonMoveRow,
      PrefetchHooks Function({bool pokemonId})
    >;
typedef $$EvolutionsTableTableCreateCompanionBuilder =
    EvolutionsTableCompanion Function({
      Value<int> id,
      required int toSpeciesId,
      Value<int?> fromSpeciesId,
      required int chainId,
      Value<String?> trigger,
      Value<int?> minLevel,
      Value<String?> item,
      Value<int?> minHappiness,
      Value<String?> timeOfDay,
      Value<String?> location,
      Value<String?> knownMoveType,
    });
typedef $$EvolutionsTableTableUpdateCompanionBuilder =
    EvolutionsTableCompanion Function({
      Value<int> id,
      Value<int> toSpeciesId,
      Value<int?> fromSpeciesId,
      Value<int> chainId,
      Value<String?> trigger,
      Value<int?> minLevel,
      Value<String?> item,
      Value<int?> minHappiness,
      Value<String?> timeOfDay,
      Value<String?> location,
      Value<String?> knownMoveType,
    });

class $$EvolutionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $EvolutionsTableTable> {
  $$EvolutionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toSpeciesId => $composableBuilder(
    column: $table.toSpeciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromSpeciesId => $composableBuilder(
    column: $table.fromSpeciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chainId => $composableBuilder(
    column: $table.chainId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minLevel => $composableBuilder(
    column: $table.minLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minHappiness => $composableBuilder(
    column: $table.minHappiness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeOfDay => $composableBuilder(
    column: $table.timeOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get knownMoveType => $composableBuilder(
    column: $table.knownMoveType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EvolutionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EvolutionsTableTable> {
  $$EvolutionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toSpeciesId => $composableBuilder(
    column: $table.toSpeciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromSpeciesId => $composableBuilder(
    column: $table.fromSpeciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chainId => $composableBuilder(
    column: $table.chainId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minLevel => $composableBuilder(
    column: $table.minLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minHappiness => $composableBuilder(
    column: $table.minHappiness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeOfDay => $composableBuilder(
    column: $table.timeOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get knownMoveType => $composableBuilder(
    column: $table.knownMoveType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EvolutionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvolutionsTableTable> {
  $$EvolutionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get toSpeciesId => $composableBuilder(
    column: $table.toSpeciesId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fromSpeciesId => $composableBuilder(
    column: $table.fromSpeciesId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chainId =>
      $composableBuilder(column: $table.chainId, builder: (column) => column);

  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<int> get minLevel =>
      $composableBuilder(column: $table.minLevel, builder: (column) => column);

  GeneratedColumn<String> get item =>
      $composableBuilder(column: $table.item, builder: (column) => column);

  GeneratedColumn<int> get minHappiness => $composableBuilder(
    column: $table.minHappiness,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeOfDay =>
      $composableBuilder(column: $table.timeOfDay, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get knownMoveType => $composableBuilder(
    column: $table.knownMoveType,
    builder: (column) => column,
  );
}

class $$EvolutionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvolutionsTableTable,
          EvolutionRow,
          $$EvolutionsTableTableFilterComposer,
          $$EvolutionsTableTableOrderingComposer,
          $$EvolutionsTableTableAnnotationComposer,
          $$EvolutionsTableTableCreateCompanionBuilder,
          $$EvolutionsTableTableUpdateCompanionBuilder,
          (
            EvolutionRow,
            BaseReferences<_$AppDatabase, $EvolutionsTableTable, EvolutionRow>,
          ),
          EvolutionRow,
          PrefetchHooks Function()
        > {
  $$EvolutionsTableTableTableManager(
    _$AppDatabase db,
    $EvolutionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvolutionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvolutionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvolutionsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> toSpeciesId = const Value.absent(),
                Value<int?> fromSpeciesId = const Value.absent(),
                Value<int> chainId = const Value.absent(),
                Value<String?> trigger = const Value.absent(),
                Value<int?> minLevel = const Value.absent(),
                Value<String?> item = const Value.absent(),
                Value<int?> minHappiness = const Value.absent(),
                Value<String?> timeOfDay = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> knownMoveType = const Value.absent(),
              }) => EvolutionsTableCompanion(
                id: id,
                toSpeciesId: toSpeciesId,
                fromSpeciesId: fromSpeciesId,
                chainId: chainId,
                trigger: trigger,
                minLevel: minLevel,
                item: item,
                minHappiness: minHappiness,
                timeOfDay: timeOfDay,
                location: location,
                knownMoveType: knownMoveType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int toSpeciesId,
                Value<int?> fromSpeciesId = const Value.absent(),
                required int chainId,
                Value<String?> trigger = const Value.absent(),
                Value<int?> minLevel = const Value.absent(),
                Value<String?> item = const Value.absent(),
                Value<int?> minHappiness = const Value.absent(),
                Value<String?> timeOfDay = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> knownMoveType = const Value.absent(),
              }) => EvolutionsTableCompanion.insert(
                id: id,
                toSpeciesId: toSpeciesId,
                fromSpeciesId: fromSpeciesId,
                chainId: chainId,
                trigger: trigger,
                minLevel: minLevel,
                item: item,
                minHappiness: minHappiness,
                timeOfDay: timeOfDay,
                location: location,
                knownMoveType: knownMoveType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EvolutionsTableTable, EvolutionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EvolutionsTableTable,
                    EvolutionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EvolutionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvolutionsTableTable,
      EvolutionRow,
      $$EvolutionsTableTableFilterComposer,
      $$EvolutionsTableTableOrderingComposer,
      $$EvolutionsTableTableAnnotationComposer,
      $$EvolutionsTableTableCreateCompanionBuilder,
      $$EvolutionsTableTableUpdateCompanionBuilder,
      (
        EvolutionRow,
        BaseReferences<_$AppDatabase, $EvolutionsTableTable, EvolutionRow>,
      ),
      EvolutionRow,
      PrefetchHooks Function()
    >;
typedef $$PokemonGamesTableTableCreateCompanionBuilder =
    PokemonGamesTableCompanion Function({
      required int pokemonId,
      required String versionName,
      Value<int> rowid,
    });
typedef $$PokemonGamesTableTableUpdateCompanionBuilder =
    PokemonGamesTableCompanion Function({
      Value<int> pokemonId,
      Value<String> versionName,
      Value<int> rowid,
    });

final class $$PokemonGamesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PokemonGamesTableTable, PokemonGameRow> {
  $$PokemonGamesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PokemonTableTable _pokemonIdTable(_$AppDatabase db) =>
      db.pokemonTable.createAlias('pokemon_games__pokemon_id__pokemon__id');

  $$PokemonTableTableProcessedTableManager get pokemonId {
    final $_column = $_itemColumn<int>('pokemon_id')!;

    final manager = $$PokemonTableTableTableManager(
      $_db,
      $_db.pokemonTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pokemonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PokemonGamesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonGamesTableTable> {
  $$PokemonGamesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => ColumnFilters(column),
  );

  $$PokemonTableTableFilterComposer get pokemonId {
    final $$PokemonTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonGamesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonGamesTableTable> {
  $$PokemonGamesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => ColumnOrderings(column),
  );

  $$PokemonTableTableOrderingComposer get pokemonId {
    final $$PokemonTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableOrderingComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonGamesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonGamesTableTable> {
  $$PokemonGamesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => column,
  );

  $$PokemonTableTableAnnotationComposer get pokemonId {
    final $$PokemonTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonGamesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonGamesTableTable,
          PokemonGameRow,
          $$PokemonGamesTableTableFilterComposer,
          $$PokemonGamesTableTableOrderingComposer,
          $$PokemonGamesTableTableAnnotationComposer,
          $$PokemonGamesTableTableCreateCompanionBuilder,
          $$PokemonGamesTableTableUpdateCompanionBuilder,
          (PokemonGameRow, $$PokemonGamesTableTableReferences),
          PokemonGameRow,
          PrefetchHooks Function({bool pokemonId})
        > {
  $$PokemonGamesTableTableTableManager(
    _$AppDatabase db,
    $PokemonGamesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonGamesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonGamesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonGamesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pokemonId = const Value.absent(),
                Value<String> versionName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonGamesTableCompanion(
                pokemonId: pokemonId,
                versionName: versionName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pokemonId,
                required String versionName,
                Value<int> rowid = const Value.absent(),
              }) => PokemonGamesTableCompanion.insert(
                pokemonId: pokemonId,
                versionName: versionName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PokemonGamesTableTable, PokemonGameRow>(table),
                  $$PokemonGamesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pokemonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pokemonId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pokemonId,
                        referencedTable: $$PokemonGamesTableTableReferences
                            ._pokemonIdTable(db),
                        referencedColumn: $$PokemonGamesTableTableReferences
                            ._pokemonIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PokemonGamesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonGamesTableTable,
      PokemonGameRow,
      $$PokemonGamesTableTableFilterComposer,
      $$PokemonGamesTableTableOrderingComposer,
      $$PokemonGamesTableTableAnnotationComposer,
      $$PokemonGamesTableTableCreateCompanionBuilder,
      $$PokemonGamesTableTableUpdateCompanionBuilder,
      (PokemonGameRow, $$PokemonGamesTableTableReferences),
      PokemonGameRow,
      PrefetchHooks Function({bool pokemonId})
    >;
typedef $$TypeEfficacyTableTableCreateCompanionBuilder =
    TypeEfficacyTableCompanion Function({
      required String attackingType,
      required String defendingType,
      required int damageFactor,
      Value<int> rowid,
    });
typedef $$TypeEfficacyTableTableUpdateCompanionBuilder =
    TypeEfficacyTableCompanion Function({
      Value<String> attackingType,
      Value<String> defendingType,
      Value<int> damageFactor,
      Value<int> rowid,
    });

class $$TypeEfficacyTableTableFilterComposer
    extends Composer<_$AppDatabase, $TypeEfficacyTableTable> {
  $$TypeEfficacyTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attackingType => $composableBuilder(
    column: $table.attackingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defendingType => $composableBuilder(
    column: $table.defendingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get damageFactor => $composableBuilder(
    column: $table.damageFactor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TypeEfficacyTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TypeEfficacyTableTable> {
  $$TypeEfficacyTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attackingType => $composableBuilder(
    column: $table.attackingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defendingType => $composableBuilder(
    column: $table.defendingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get damageFactor => $composableBuilder(
    column: $table.damageFactor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TypeEfficacyTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TypeEfficacyTableTable> {
  $$TypeEfficacyTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attackingType => $composableBuilder(
    column: $table.attackingType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defendingType => $composableBuilder(
    column: $table.defendingType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get damageFactor => $composableBuilder(
    column: $table.damageFactor,
    builder: (column) => column,
  );
}

class $$TypeEfficacyTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TypeEfficacyTableTable,
          TypeEfficacyRow,
          $$TypeEfficacyTableTableFilterComposer,
          $$TypeEfficacyTableTableOrderingComposer,
          $$TypeEfficacyTableTableAnnotationComposer,
          $$TypeEfficacyTableTableCreateCompanionBuilder,
          $$TypeEfficacyTableTableUpdateCompanionBuilder,
          (
            TypeEfficacyRow,
            BaseReferences<
              _$AppDatabase,
              $TypeEfficacyTableTable,
              TypeEfficacyRow
            >,
          ),
          TypeEfficacyRow,
          PrefetchHooks Function()
        > {
  $$TypeEfficacyTableTableTableManager(
    _$AppDatabase db,
    $TypeEfficacyTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TypeEfficacyTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TypeEfficacyTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TypeEfficacyTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> attackingType = const Value.absent(),
                Value<String> defendingType = const Value.absent(),
                Value<int> damageFactor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TypeEfficacyTableCompanion(
                attackingType: attackingType,
                defendingType: defendingType,
                damageFactor: damageFactor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attackingType,
                required String defendingType,
                required int damageFactor,
                Value<int> rowid = const Value.absent(),
              }) => TypeEfficacyTableCompanion.insert(
                attackingType: attackingType,
                defendingType: defendingType,
                damageFactor: damageFactor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TypeEfficacyTableTable, TypeEfficacyRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TypeEfficacyTableTable,
                    TypeEfficacyRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TypeEfficacyTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TypeEfficacyTableTable,
      TypeEfficacyRow,
      $$TypeEfficacyTableTableFilterComposer,
      $$TypeEfficacyTableTableOrderingComposer,
      $$TypeEfficacyTableTableAnnotationComposer,
      $$TypeEfficacyTableTableCreateCompanionBuilder,
      $$TypeEfficacyTableTableUpdateCompanionBuilder,
      (
        TypeEfficacyRow,
        BaseReferences<_$AppDatabase, $TypeEfficacyTableTable, TypeEfficacyRow>,
      ),
      TypeEfficacyRow,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableTableCreateCompanionBuilder =
    FavoritesTableCompanion Function({
      Value<int> pokemonId,
      required DateTime createdAt,
    });
typedef $$FavoritesTableTableUpdateCompanionBuilder =
    FavoritesTableCompanion Function({
      Value<int> pokemonId,
      Value<DateTime> createdAt,
    });

class $$FavoritesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pokemonId => $composableBuilder(
    column: $table.pokemonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pokemonId => $composableBuilder(
    column: $table.pokemonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pokemonId =>
      $composableBuilder(column: $table.pokemonId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoritesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTableTable,
          FavoriteRow,
          $$FavoritesTableTableFilterComposer,
          $$FavoritesTableTableOrderingComposer,
          $$FavoritesTableTableAnnotationComposer,
          $$FavoritesTableTableCreateCompanionBuilder,
          $$FavoritesTableTableUpdateCompanionBuilder,
          (
            FavoriteRow,
            BaseReferences<_$AppDatabase, $FavoritesTableTable, FavoriteRow>,
          ),
          FavoriteRow,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableTableManager(
    _$AppDatabase db,
    $FavoritesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> pokemonId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FavoritesTableCompanion(
                pokemonId: pokemonId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> pokemonId = const Value.absent(),
                required DateTime createdAt,
              }) => FavoritesTableCompanion.insert(
                pokemonId: pokemonId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTableTable, FavoriteRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FavoritesTableTable,
                    FavoriteRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTableTable,
      FavoriteRow,
      $$FavoritesTableTableFilterComposer,
      $$FavoritesTableTableOrderingComposer,
      $$FavoritesTableTableAnnotationComposer,
      $$FavoritesTableTableCreateCompanionBuilder,
      $$FavoritesTableTableUpdateCompanionBuilder,
      (
        FavoriteRow,
        BaseReferences<_$AppDatabase, $FavoritesTableTable, FavoriteRow>,
      ),
      FavoriteRow,
      PrefetchHooks Function()
    >;
typedef $$TriviaResultsTableTableCreateCompanionBuilder =
    TriviaResultsTableCompanion Function({
      Value<int> id,
      required int score,
      required int correctAnswers,
      required int totalQuestions,
      required int durationMs,
      required DateTime playedAt,
    });
typedef $$TriviaResultsTableTableUpdateCompanionBuilder =
    TriviaResultsTableCompanion Function({
      Value<int> id,
      Value<int> score,
      Value<int> correctAnswers,
      Value<int> totalQuestions,
      Value<int> durationMs,
      Value<DateTime> playedAt,
    });

final class $$TriviaResultsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TriviaResultsTableTable,
          TriviaResultRow
        > {
  $$TriviaResultsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TriviaAnswersTableTable, List<TriviaAnswerRow>>
  _triviaAnswersTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.triviaAnswersTable,
        aliasName: 'trivia_results__id__trivia_answers__result_id',
      );

  $$TriviaAnswersTableTableProcessedTableManager get triviaAnswersTableRefs {
    final manager = $$TriviaAnswersTableTableTableManager(
      $_db,
      $_db.triviaAnswersTable,
    ).filter((f) => f.resultId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _triviaAnswersTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TriviaResultsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TriviaResultsTableTable> {
  $$TriviaResultsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> triviaAnswersTableRefs(
    Expression<bool> Function($$TriviaAnswersTableTableFilterComposer f) f,
  ) {
    final $$TriviaAnswersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.triviaAnswersTable,
      getReferencedColumn: (t) => t.resultId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TriviaAnswersTableTableFilterComposer(
            $db: $db,
            $table: $db.triviaAnswersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TriviaResultsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TriviaResultsTableTable> {
  $$TriviaResultsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TriviaResultsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TriviaResultsTableTable> {
  $$TriviaResultsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  Expression<T> triviaAnswersTableRefs<T extends Object>(
    Expression<T> Function($$TriviaAnswersTableTableAnnotationComposer a) f,
  ) {
    final $$TriviaAnswersTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.triviaAnswersTable,
          getReferencedColumn: (t) => t.resultId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TriviaAnswersTableTableAnnotationComposer(
                $db: $db,
                $table: $db.triviaAnswersTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TriviaResultsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TriviaResultsTableTable,
          TriviaResultRow,
          $$TriviaResultsTableTableFilterComposer,
          $$TriviaResultsTableTableOrderingComposer,
          $$TriviaResultsTableTableAnnotationComposer,
          $$TriviaResultsTableTableCreateCompanionBuilder,
          $$TriviaResultsTableTableUpdateCompanionBuilder,
          (TriviaResultRow, $$TriviaResultsTableTableReferences),
          TriviaResultRow,
          PrefetchHooks Function({bool triviaAnswersTableRefs})
        > {
  $$TriviaResultsTableTableTableManager(
    _$AppDatabase db,
    $TriviaResultsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TriviaResultsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TriviaResultsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TriviaResultsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
              }) => TriviaResultsTableCompanion(
                id: id,
                score: score,
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                durationMs: durationMs,
                playedAt: playedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int score,
                required int correctAnswers,
                required int totalQuestions,
                required int durationMs,
                required DateTime playedAt,
              }) => TriviaResultsTableCompanion.insert(
                id: id,
                score: score,
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                durationMs: durationMs,
                playedAt: playedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TriviaResultsTableTable, TriviaResultRow>(table),
                  $$TriviaResultsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({triviaAnswersTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (triviaAnswersTableRefs) db.triviaAnswersTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (triviaAnswersTableRefs)
                    await $_getPrefetchedDataByColumns<
                      TriviaResultRow,
                      $TriviaResultsTableTable,
                      TriviaAnswerRow,
                      $TriviaAnswersTableTable
                    >(
                      currentTable: table,
                      referencedTable: $$TriviaResultsTableTableReferences
                          ._triviaAnswersTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TriviaResultsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).triviaAnswersTableRefs,
                      currentColumn: 'id',
                      referencedColumn: 'result_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TriviaResultsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TriviaResultsTableTable,
      TriviaResultRow,
      $$TriviaResultsTableTableFilterComposer,
      $$TriviaResultsTableTableOrderingComposer,
      $$TriviaResultsTableTableAnnotationComposer,
      $$TriviaResultsTableTableCreateCompanionBuilder,
      $$TriviaResultsTableTableUpdateCompanionBuilder,
      (TriviaResultRow, $$TriviaResultsTableTableReferences),
      TriviaResultRow,
      PrefetchHooks Function({bool triviaAnswersTableRefs})
    >;
typedef $$TriviaAnswersTableTableCreateCompanionBuilder =
    TriviaAnswersTableCompanion Function({
      Value<int> id,
      required int resultId,
      required int pokemonId,
      required bool correct,
      required int responseMs,
    });
typedef $$TriviaAnswersTableTableUpdateCompanionBuilder =
    TriviaAnswersTableCompanion Function({
      Value<int> id,
      Value<int> resultId,
      Value<int> pokemonId,
      Value<bool> correct,
      Value<int> responseMs,
    });

final class $$TriviaAnswersTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TriviaAnswersTableTable,
          TriviaAnswerRow
        > {
  $$TriviaAnswersTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TriviaResultsTableTable _resultIdTable(_$AppDatabase db) => db
      .triviaResultsTable
      .createAlias('trivia_answers__result_id__trivia_results__id');

  $$TriviaResultsTableTableProcessedTableManager get resultId {
    final $_column = $_itemColumn<int>('result_id')!;

    final manager = $$TriviaResultsTableTableTableManager(
      $_db,
      $_db.triviaResultsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resultIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TriviaAnswersTableTableFilterComposer
    extends Composer<_$AppDatabase, $TriviaAnswersTableTable> {
  $$TriviaAnswersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pokemonId => $composableBuilder(
    column: $table.pokemonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responseMs => $composableBuilder(
    column: $table.responseMs,
    builder: (column) => ColumnFilters(column),
  );

  $$TriviaResultsTableTableFilterComposer get resultId {
    final $$TriviaResultsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resultId,
      referencedTable: $db.triviaResultsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TriviaResultsTableTableFilterComposer(
            $db: $db,
            $table: $db.triviaResultsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TriviaAnswersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TriviaAnswersTableTable> {
  $$TriviaAnswersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pokemonId => $composableBuilder(
    column: $table.pokemonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseMs => $composableBuilder(
    column: $table.responseMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$TriviaResultsTableTableOrderingComposer get resultId {
    final $$TriviaResultsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resultId,
      referencedTable: $db.triviaResultsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TriviaResultsTableTableOrderingComposer(
            $db: $db,
            $table: $db.triviaResultsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TriviaAnswersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TriviaAnswersTableTable> {
  $$TriviaAnswersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pokemonId =>
      $composableBuilder(column: $table.pokemonId, builder: (column) => column);

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get responseMs => $composableBuilder(
    column: $table.responseMs,
    builder: (column) => column,
  );

  $$TriviaResultsTableTableAnnotationComposer get resultId {
    final $$TriviaResultsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.resultId,
          referencedTable: $db.triviaResultsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TriviaResultsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.triviaResultsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TriviaAnswersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TriviaAnswersTableTable,
          TriviaAnswerRow,
          $$TriviaAnswersTableTableFilterComposer,
          $$TriviaAnswersTableTableOrderingComposer,
          $$TriviaAnswersTableTableAnnotationComposer,
          $$TriviaAnswersTableTableCreateCompanionBuilder,
          $$TriviaAnswersTableTableUpdateCompanionBuilder,
          (TriviaAnswerRow, $$TriviaAnswersTableTableReferences),
          TriviaAnswerRow,
          PrefetchHooks Function({bool resultId})
        > {
  $$TriviaAnswersTableTableTableManager(
    _$AppDatabase db,
    $TriviaAnswersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TriviaAnswersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TriviaAnswersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TriviaAnswersTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> resultId = const Value.absent(),
                Value<int> pokemonId = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<int> responseMs = const Value.absent(),
              }) => TriviaAnswersTableCompanion(
                id: id,
                resultId: resultId,
                pokemonId: pokemonId,
                correct: correct,
                responseMs: responseMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int resultId,
                required int pokemonId,
                required bool correct,
                required int responseMs,
              }) => TriviaAnswersTableCompanion.insert(
                id: id,
                resultId: resultId,
                pokemonId: pokemonId,
                correct: correct,
                responseMs: responseMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TriviaAnswersTableTable, TriviaAnswerRow>(table),
                  $$TriviaAnswersTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({resultId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (resultId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.resultId,
                        referencedTable: $$TriviaAnswersTableTableReferences
                            ._resultIdTable(db),
                        referencedColumn: $$TriviaAnswersTableTableReferences
                            ._resultIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TriviaAnswersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TriviaAnswersTableTable,
      TriviaAnswerRow,
      $$TriviaAnswersTableTableFilterComposer,
      $$TriviaAnswersTableTableOrderingComposer,
      $$TriviaAnswersTableTableAnnotationComposer,
      $$TriviaAnswersTableTableCreateCompanionBuilder,
      $$TriviaAnswersTableTableUpdateCompanionBuilder,
      (TriviaAnswerRow, $$TriviaAnswersTableTableReferences),
      TriviaAnswerRow,
      PrefetchHooks Function({bool resultId})
    >;
typedef $$AchievementsTableTableCreateCompanionBuilder =
    AchievementsTableCompanion Function({
      required String key,
      required DateTime unlockedAt,
      Value<int> rowid,
    });
typedef $$AchievementsTableTableUpdateCompanionBuilder =
    AchievementsTableCompanion Function({
      Value<String> key,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

class $$AchievementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTableTable> {
  $$AchievementsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTableTable> {
  $$AchievementsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTableTable> {
  $$AchievementsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTableTable,
          AchievementRow,
          $$AchievementsTableTableFilterComposer,
          $$AchievementsTableTableOrderingComposer,
          $$AchievementsTableTableAnnotationComposer,
          $$AchievementsTableTableCreateCompanionBuilder,
          $$AchievementsTableTableUpdateCompanionBuilder,
          (
            AchievementRow,
            BaseReferences<
              _$AppDatabase,
              $AchievementsTableTable,
              AchievementRow
            >,
          ),
          AchievementRow,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableTableManager(
    _$AppDatabase db,
    $AchievementsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsTableCompanion(
                key: key,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => AchievementsTableCompanion.insert(
                key: key,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AchievementsTableTable, AchievementRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AchievementsTableTable,
                    AchievementRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTableTable,
      AchievementRow,
      $$AchievementsTableTableFilterComposer,
      $$AchievementsTableTableOrderingComposer,
      $$AchievementsTableTableAnnotationComposer,
      $$AchievementsTableTableCreateCompanionBuilder,
      $$AchievementsTableTableUpdateCompanionBuilder,
      (
        AchievementRow,
        BaseReferences<_$AppDatabase, $AchievementsTableTable, AchievementRow>,
      ),
      AchievementRow,
      PrefetchHooks Function()
    >;
typedef $$UserPreferencesTableTableCreateCompanionBuilder =
    UserPreferencesTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$UserPreferencesTableTableUpdateCompanionBuilder =
    UserPreferencesTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$UserPreferencesTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTableTable> {
  $$UserPreferencesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTableTable> {
  $$UserPreferencesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTableTable> {
  $$UserPreferencesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$UserPreferencesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTableTable,
          UserPreferenceRow,
          $$UserPreferencesTableTableFilterComposer,
          $$UserPreferencesTableTableOrderingComposer,
          $$UserPreferencesTableTableAnnotationComposer,
          $$UserPreferencesTableTableCreateCompanionBuilder,
          $$UserPreferencesTableTableUpdateCompanionBuilder,
          (
            UserPreferenceRow,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTableTable,
              UserPreferenceRow
            >,
          ),
          UserPreferenceRow,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesTableCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserPreferencesTableTable, UserPreferenceRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $UserPreferencesTableTable,
                    UserPreferenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTableTable,
      UserPreferenceRow,
      $$UserPreferencesTableTableFilterComposer,
      $$UserPreferencesTableTableOrderingComposer,
      $$UserPreferencesTableTableAnnotationComposer,
      $$UserPreferencesTableTableCreateCompanionBuilder,
      $$UserPreferencesTableTableUpdateCompanionBuilder,
      (
        UserPreferenceRow,
        BaseReferences<
          _$AppDatabase,
          $UserPreferencesTableTable,
          UserPreferenceRow
        >,
      ),
      UserPreferenceRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableTableCreateCompanionBuilder =
    SyncMetadataTableCompanion Function({
      required String key,
      Value<int> nextOffset,
      Value<int?> totalCount,
      Value<bool> isComplete,
      Value<DateTime?> lastSyncedAt,
      Value<String?> lastError,
      Value<String> status,
      Value<int> attempt,
      Value<DateTime?> nextRetryAt,
      Value<DateTime?> lastVerifiedAt,
      Value<String?> lastErrorKind,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableTableUpdateCompanionBuilder =
    SyncMetadataTableCompanion Function({
      Value<String> key,
      Value<int> nextOffset,
      Value<int?> totalCount,
      Value<bool> isComplete,
      Value<DateTime?> lastSyncedAt,
      Value<String?> lastError,
      Value<String> status,
      Value<int> attempt,
      Value<DateTime?> nextRetryAt,
      Value<DateTime?> lastVerifiedAt,
      Value<String?> lastErrorKind,
      Value<int> rowid,
    });

class $$SyncMetadataTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextOffset => $composableBuilder(
    column: $table.nextOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorKind => $composableBuilder(
    column: $table.lastErrorKind,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextOffset => $composableBuilder(
    column: $table.nextOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorKind => $composableBuilder(
    column: $table.lastErrorKind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get nextOffset => $composableBuilder(
    column: $table.nextOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorKind => $composableBuilder(
    column: $table.lastErrorKind,
    builder: (column) => column,
  );
}

class $$SyncMetadataTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTableTable,
          SyncMetadataRow,
          $$SyncMetadataTableTableFilterComposer,
          $$SyncMetadataTableTableOrderingComposer,
          $$SyncMetadataTableTableAnnotationComposer,
          $$SyncMetadataTableTableCreateCompanionBuilder,
          $$SyncMetadataTableTableUpdateCompanionBuilder,
          (
            SyncMetadataRow,
            BaseReferences<
              _$AppDatabase,
              $SyncMetadataTableTable,
              SyncMetadataRow
            >,
          ),
          SyncMetadataRow,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableTableManager(
    _$AppDatabase db,
    $SyncMetadataTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> nextOffset = const Value.absent(),
                Value<int?> totalCount = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<String?> lastErrorKind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataTableCompanion(
                key: key,
                nextOffset: nextOffset,
                totalCount: totalCount,
                isComplete: isComplete,
                lastSyncedAt: lastSyncedAt,
                lastError: lastError,
                status: status,
                attempt: attempt,
                nextRetryAt: nextRetryAt,
                lastVerifiedAt: lastVerifiedAt,
                lastErrorKind: lastErrorKind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<int> nextOffset = const Value.absent(),
                Value<int?> totalCount = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<String?> lastErrorKind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataTableCompanion.insert(
                key: key,
                nextOffset: nextOffset,
                totalCount: totalCount,
                isComplete: isComplete,
                lastSyncedAt: lastSyncedAt,
                lastError: lastError,
                status: status,
                attempt: attempt,
                nextRetryAt: nextRetryAt,
                lastVerifiedAt: lastVerifiedAt,
                lastErrorKind: lastErrorKind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMetadataTableTable, SyncMetadataRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncMetadataTableTable,
                    SyncMetadataRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTableTable,
      SyncMetadataRow,
      $$SyncMetadataTableTableFilterComposer,
      $$SyncMetadataTableTableOrderingComposer,
      $$SyncMetadataTableTableAnnotationComposer,
      $$SyncMetadataTableTableCreateCompanionBuilder,
      $$SyncMetadataTableTableUpdateCompanionBuilder,
      (
        SyncMetadataRow,
        BaseReferences<_$AppDatabase, $SyncMetadataTableTable, SyncMetadataRow>,
      ),
      SyncMetadataRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PokemonTableTableTableManager get pokemonTable =>
      $$PokemonTableTableTableManager(_db, _db.pokemonTable);
  $$PokemonTypesTableTableTableManager get pokemonTypesTable =>
      $$PokemonTypesTableTableTableManager(_db, _db.pokemonTypesTable);
  $$PokemonStatsTableTableTableManager get pokemonStatsTable =>
      $$PokemonStatsTableTableTableManager(_db, _db.pokemonStatsTable);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db, _db.speciesTable);
  $$SpeciesEggGroupsTableTableTableManager get speciesEggGroupsTable =>
      $$SpeciesEggGroupsTableTableTableManager(_db, _db.speciesEggGroupsTable);
  $$AbilitiesTableTableTableManager get abilitiesTable =>
      $$AbilitiesTableTableTableManager(_db, _db.abilitiesTable);
  $$PokemonAbilitiesTableTableTableManager get pokemonAbilitiesTable =>
      $$PokemonAbilitiesTableTableTableManager(_db, _db.pokemonAbilitiesTable);
  $$MovesTableTableTableManager get movesTable =>
      $$MovesTableTableTableManager(_db, _db.movesTable);
  $$PokemonMovesTableTableTableManager get pokemonMovesTable =>
      $$PokemonMovesTableTableTableManager(_db, _db.pokemonMovesTable);
  $$EvolutionsTableTableTableManager get evolutionsTable =>
      $$EvolutionsTableTableTableManager(_db, _db.evolutionsTable);
  $$PokemonGamesTableTableTableManager get pokemonGamesTable =>
      $$PokemonGamesTableTableTableManager(_db, _db.pokemonGamesTable);
  $$TypeEfficacyTableTableTableManager get typeEfficacyTable =>
      $$TypeEfficacyTableTableTableManager(_db, _db.typeEfficacyTable);
  $$FavoritesTableTableTableManager get favoritesTable =>
      $$FavoritesTableTableTableManager(_db, _db.favoritesTable);
  $$TriviaResultsTableTableTableManager get triviaResultsTable =>
      $$TriviaResultsTableTableTableManager(_db, _db.triviaResultsTable);
  $$TriviaAnswersTableTableTableManager get triviaAnswersTable =>
      $$TriviaAnswersTableTableTableManager(_db, _db.triviaAnswersTable);
  $$AchievementsTableTableTableManager get achievementsTable =>
      $$AchievementsTableTableTableManager(_db, _db.achievementsTable);
  $$UserPreferencesTableTableTableManager get userPreferencesTable =>
      $$UserPreferencesTableTableTableManager(_db, _db.userPreferencesTable);
  $$SyncMetadataTableTableTableManager get syncMetadataTable =>
      $$SyncMetadataTableTableTableManager(_db, _db.syncMetadataTable);
}
