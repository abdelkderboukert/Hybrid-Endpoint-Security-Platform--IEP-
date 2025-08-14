// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'license_key.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLicenseKeyCollection on Isar {
  IsarCollection<LicenseKey> get licenseKeys => this.collection();
}

const LicenseKeySchema = CollectionSchema(
  name: r'LicenseKey',
  id: -7404941704593619625,
  properties: {
    r'assignedAdminId': PropertySchema(
      id: 0,
      name: r'assignedAdminId',
      type: IsarType.string,
    ),
    r'dateCreated': PropertySchema(
      id: 1,
      name: r'dateCreated',
      type: IsarType.dateTime,
    ),
    r'isActive': PropertySchema(
      id: 2,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'key': PropertySchema(
      id: 3,
      name: r'key',
      type: IsarType.string,
    ),
    r'licenseKeyId': PropertySchema(
      id: 4,
      name: r'licenseKeyId',
      type: IsarType.string,
    ),
    r'localId': PropertySchema(
      id: 5,
      name: r'localId',
      type: IsarType.string,
    )
  },
  estimateSize: _licenseKeyEstimateSize,
  serialize: _licenseKeySerialize,
  deserialize: _licenseKeyDeserialize,
  deserializeProp: _licenseKeyDeserializeProp,
  idName: r'id',
  indexes: {
    r'licenseKeyId': IndexSchema(
      id: -2227670015116938948,
      name: r'licenseKeyId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'licenseKeyId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'localId': IndexSchema(
      id: 1199848425898359622,
      name: r'localId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'localId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _licenseKeyGetId,
  getLinks: _licenseKeyGetLinks,
  attach: _licenseKeyAttach,
  version: '3.1.0+1',
);

int _licenseKeyEstimateSize(
  LicenseKey object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.assignedAdminId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.key.length * 3;
  {
    final value = object.licenseKeyId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.localId.length * 3;
  return bytesCount;
}

void _licenseKeySerialize(
  LicenseKey object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.assignedAdminId);
  writer.writeDateTime(offsets[1], object.dateCreated);
  writer.writeBool(offsets[2], object.isActive);
  writer.writeString(offsets[3], object.key);
  writer.writeString(offsets[4], object.licenseKeyId);
  writer.writeString(offsets[5], object.localId);
}

LicenseKey _licenseKeyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LicenseKey();
  object.assignedAdminId = reader.readStringOrNull(offsets[0]);
  object.dateCreated = reader.readDateTime(offsets[1]);
  object.id = id;
  object.isActive = reader.readBool(offsets[2]);
  object.key = reader.readString(offsets[3]);
  object.licenseKeyId = reader.readStringOrNull(offsets[4]);
  object.localId = reader.readString(offsets[5]);
  return object;
}

P _licenseKeyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _licenseKeyGetId(LicenseKey object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _licenseKeyGetLinks(LicenseKey object) {
  return [];
}

void _licenseKeyAttach(IsarCollection<dynamic> col, Id id, LicenseKey object) {
  object.id = id;
}

extension LicenseKeyByIndex on IsarCollection<LicenseKey> {
  Future<LicenseKey?> getByLicenseKeyId(String? licenseKeyId) {
    return getByIndex(r'licenseKeyId', [licenseKeyId]);
  }

  LicenseKey? getByLicenseKeyIdSync(String? licenseKeyId) {
    return getByIndexSync(r'licenseKeyId', [licenseKeyId]);
  }

  Future<bool> deleteByLicenseKeyId(String? licenseKeyId) {
    return deleteByIndex(r'licenseKeyId', [licenseKeyId]);
  }

  bool deleteByLicenseKeyIdSync(String? licenseKeyId) {
    return deleteByIndexSync(r'licenseKeyId', [licenseKeyId]);
  }

  Future<List<LicenseKey?>> getAllByLicenseKeyId(
      List<String?> licenseKeyIdValues) {
    final values = licenseKeyIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'licenseKeyId', values);
  }

  List<LicenseKey?> getAllByLicenseKeyIdSync(List<String?> licenseKeyIdValues) {
    final values = licenseKeyIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'licenseKeyId', values);
  }

  Future<int> deleteAllByLicenseKeyId(List<String?> licenseKeyIdValues) {
    final values = licenseKeyIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'licenseKeyId', values);
  }

  int deleteAllByLicenseKeyIdSync(List<String?> licenseKeyIdValues) {
    final values = licenseKeyIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'licenseKeyId', values);
  }

  Future<Id> putByLicenseKeyId(LicenseKey object) {
    return putByIndex(r'licenseKeyId', object);
  }

  Id putByLicenseKeyIdSync(LicenseKey object, {bool saveLinks = true}) {
    return putByIndexSync(r'licenseKeyId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLicenseKeyId(List<LicenseKey> objects) {
    return putAllByIndex(r'licenseKeyId', objects);
  }

  List<Id> putAllByLicenseKeyIdSync(List<LicenseKey> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'licenseKeyId', objects, saveLinks: saveLinks);
  }

  Future<LicenseKey?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  LicenseKey? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<LicenseKey?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<LicenseKey?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(LicenseKey object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(LicenseKey object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<LicenseKey> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<LicenseKey> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension LicenseKeyQueryWhereSort
    on QueryBuilder<LicenseKey, LicenseKey, QWhere> {
  QueryBuilder<LicenseKey, LicenseKey, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LicenseKeyQueryWhere
    on QueryBuilder<LicenseKey, LicenseKey, QWhereClause> {
  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> licenseKeyIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'licenseKeyId',
        value: [null],
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause>
      licenseKeyIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'licenseKeyId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> licenseKeyIdEqualTo(
      String? licenseKeyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'licenseKeyId',
        value: [licenseKeyId],
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause>
      licenseKeyIdNotEqualTo(String? licenseKeyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'licenseKeyId',
              lower: [],
              upper: [licenseKeyId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'licenseKeyId',
              lower: [licenseKeyId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'licenseKeyId',
              lower: [licenseKeyId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'licenseKeyId',
              lower: [],
              upper: [licenseKeyId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> localIdEqualTo(
      String localId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'localId',
        value: [localId],
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> localIdNotEqualTo(
      String localId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [],
              upper: [localId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [localId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [localId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [],
              upper: [localId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> keyEqualTo(
      String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'key',
        value: [key],
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterWhereClause> keyNotEqualTo(
      String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LicenseKeyQueryFilter
    on QueryBuilder<LicenseKey, LicenseKey, QFilterCondition> {
  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedAdminId',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedAdminId',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedAdminId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedAdminId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedAdminId',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      assignedAdminIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedAdminId',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      dateCreatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      dateCreatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      dateCreatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      dateCreatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateCreated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> keyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> keyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'licenseKeyId',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'licenseKeyId',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'licenseKeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'licenseKeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'licenseKeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'licenseKeyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'licenseKeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'licenseKeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'licenseKeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'licenseKeyId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'licenseKeyId',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      licenseKeyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'licenseKeyId',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> localIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      localIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> localIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> localIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> localIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> localIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> localIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> localIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition> localIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localId',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterFilterCondition>
      localIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localId',
        value: '',
      ));
    });
  }
}

extension LicenseKeyQueryObject
    on QueryBuilder<LicenseKey, LicenseKey, QFilterCondition> {}

extension LicenseKeyQueryLinks
    on QueryBuilder<LicenseKey, LicenseKey, QFilterCondition> {}

extension LicenseKeyQuerySortBy
    on QueryBuilder<LicenseKey, LicenseKey, QSortBy> {
  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByAssignedAdminId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAdminId', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy>
      sortByAssignedAdminIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAdminId', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByDateCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByDateCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByLicenseKeyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseKeyId', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByLicenseKeyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseKeyId', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }
}

extension LicenseKeyQuerySortThenBy
    on QueryBuilder<LicenseKey, LicenseKey, QSortThenBy> {
  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByAssignedAdminId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAdminId', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy>
      thenByAssignedAdminIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAdminId', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByDateCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByDateCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByLicenseKeyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseKeyId', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByLicenseKeyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseKeyId', Sort.desc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QAfterSortBy> thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }
}

extension LicenseKeyQueryWhereDistinct
    on QueryBuilder<LicenseKey, LicenseKey, QDistinct> {
  QueryBuilder<LicenseKey, LicenseKey, QDistinct> distinctByAssignedAdminId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedAdminId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QDistinct> distinctByDateCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateCreated');
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QDistinct> distinctByLicenseKeyId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'licenseKeyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LicenseKey, LicenseKey, QDistinct> distinctByLocalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId', caseSensitive: caseSensitive);
    });
  }
}

extension LicenseKeyQueryProperty
    on QueryBuilder<LicenseKey, LicenseKey, QQueryProperty> {
  QueryBuilder<LicenseKey, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LicenseKey, String?, QQueryOperations>
      assignedAdminIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedAdminId');
    });
  }

  QueryBuilder<LicenseKey, DateTime, QQueryOperations> dateCreatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateCreated');
    });
  }

  QueryBuilder<LicenseKey, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<LicenseKey, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<LicenseKey, String?, QQueryOperations> licenseKeyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'licenseKeyId');
    });
  }

  QueryBuilder<LicenseKey, String, QQueryOperations> localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }
}
