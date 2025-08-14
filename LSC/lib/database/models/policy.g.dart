// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPolicyCollection on Isar {
  IsarCollection<Policy> get policys => this.collection();
}

const PolicySchema = CollectionSchema(
  name: r'Policy',
  id: 4200805262479490847,
  properties: {
    r'applicableLayer': PropertySchema(
      id: 0,
      name: r'applicableLayer',
      type: IsarType.long,
    ),
    r'createdByAdminId': PropertySchema(
      id: 1,
      name: r'createdByAdminId',
      type: IsarType.string,
    ),
    r'localId': PropertySchema(
      id: 2,
      name: r'localId',
      type: IsarType.string,
    ),
    r'policyId': PropertySchema(
      id: 3,
      name: r'policyId',
      type: IsarType.string,
    ),
    r'policyJson': PropertySchema(
      id: 4,
      name: r'policyJson',
      type: IsarType.string,
    ),
    r'policyName': PropertySchema(
      id: 5,
      name: r'policyName',
      type: IsarType.string,
    )
  },
  estimateSize: _policyEstimateSize,
  serialize: _policySerialize,
  deserialize: _policyDeserialize,
  deserializeProp: _policyDeserializeProp,
  idName: r'id',
  indexes: {
    r'policyId': IndexSchema(
      id: 5070643496271002886,
      name: r'policyId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'policyId',
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _policyGetId,
  getLinks: _policyGetLinks,
  attach: _policyAttach,
  version: '3.1.0+1',
);

int _policyEstimateSize(
  Policy object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.createdByAdminId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.localId.length * 3;
  {
    final value = object.policyId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.policyJson.length * 3;
  bytesCount += 3 + object.policyName.length * 3;
  return bytesCount;
}

void _policySerialize(
  Policy object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.applicableLayer);
  writer.writeString(offsets[1], object.createdByAdminId);
  writer.writeString(offsets[2], object.localId);
  writer.writeString(offsets[3], object.policyId);
  writer.writeString(offsets[4], object.policyJson);
  writer.writeString(offsets[5], object.policyName);
}

Policy _policyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Policy();
  object.applicableLayer = reader.readLong(offsets[0]);
  object.createdByAdminId = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.localId = reader.readString(offsets[2]);
  object.policyId = reader.readStringOrNull(offsets[3]);
  object.policyJson = reader.readString(offsets[4]);
  object.policyName = reader.readString(offsets[5]);
  return object;
}

P _policyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _policyGetId(Policy object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _policyGetLinks(Policy object) {
  return [];
}

void _policyAttach(IsarCollection<dynamic> col, Id id, Policy object) {
  object.id = id;
}

extension PolicyByIndex on IsarCollection<Policy> {
  Future<Policy?> getByPolicyId(String? policyId) {
    return getByIndex(r'policyId', [policyId]);
  }

  Policy? getByPolicyIdSync(String? policyId) {
    return getByIndexSync(r'policyId', [policyId]);
  }

  Future<bool> deleteByPolicyId(String? policyId) {
    return deleteByIndex(r'policyId', [policyId]);
  }

  bool deleteByPolicyIdSync(String? policyId) {
    return deleteByIndexSync(r'policyId', [policyId]);
  }

  Future<List<Policy?>> getAllByPolicyId(List<String?> policyIdValues) {
    final values = policyIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'policyId', values);
  }

  List<Policy?> getAllByPolicyIdSync(List<String?> policyIdValues) {
    final values = policyIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'policyId', values);
  }

  Future<int> deleteAllByPolicyId(List<String?> policyIdValues) {
    final values = policyIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'policyId', values);
  }

  int deleteAllByPolicyIdSync(List<String?> policyIdValues) {
    final values = policyIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'policyId', values);
  }

  Future<Id> putByPolicyId(Policy object) {
    return putByIndex(r'policyId', object);
  }

  Id putByPolicyIdSync(Policy object, {bool saveLinks = true}) {
    return putByIndexSync(r'policyId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPolicyId(List<Policy> objects) {
    return putAllByIndex(r'policyId', objects);
  }

  List<Id> putAllByPolicyIdSync(List<Policy> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'policyId', objects, saveLinks: saveLinks);
  }
}

extension PolicyQueryWhereSort on QueryBuilder<Policy, Policy, QWhere> {
  QueryBuilder<Policy, Policy, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PolicyQueryWhere on QueryBuilder<Policy, Policy, QWhereClause> {
  QueryBuilder<Policy, Policy, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Policy, Policy, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Policy, Policy, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Policy, Policy, QAfterWhereClause> idBetween(
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

  QueryBuilder<Policy, Policy, QAfterWhereClause> policyIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'policyId',
        value: [null],
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterWhereClause> policyIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'policyId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterWhereClause> policyIdEqualTo(
      String? policyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'policyId',
        value: [policyId],
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterWhereClause> policyIdNotEqualTo(
      String? policyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'policyId',
              lower: [],
              upper: [policyId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'policyId',
              lower: [policyId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'policyId',
              lower: [policyId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'policyId',
              lower: [],
              upper: [policyId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Policy, Policy, QAfterWhereClause> localIdEqualTo(
      String localId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'localId',
        value: [localId],
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterWhereClause> localIdNotEqualTo(
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
}

extension PolicyQueryFilter on QueryBuilder<Policy, Policy, QFilterCondition> {
  QueryBuilder<Policy, Policy, QAfterFilterCondition> applicableLayerEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'applicableLayer',
        value: value,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition>
      applicableLayerGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'applicableLayer',
        value: value,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> applicableLayerLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'applicableLayer',
        value: value,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> applicableLayerBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'applicableLayer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> createdByAdminIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdByAdminId',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition>
      createdByAdminIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdByAdminId',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> createdByAdminIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition>
      createdByAdminIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdByAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> createdByAdminIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdByAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> createdByAdminIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdByAdminId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition>
      createdByAdminIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdByAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> createdByAdminIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdByAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> createdByAdminIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdByAdminId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> createdByAdminIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdByAdminId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition>
      createdByAdminIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByAdminId',
        value: '',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition>
      createdByAdminIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdByAdminId',
        value: '',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> localIdEqualTo(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> localIdGreaterThan(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> localIdLessThan(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> localIdBetween(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> localIdStartsWith(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> localIdEndsWith(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> localIdContains(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> localIdMatches(
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

  QueryBuilder<Policy, Policy, QAfterFilterCondition> localIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localId',
        value: '',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> localIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localId',
        value: '',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'policyId',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'policyId',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'policyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'policyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'policyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'policyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'policyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'policyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'policyId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyId',
        value: '',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'policyId',
        value: '',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'policyJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'policyJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'policyJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'policyJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'policyJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyJsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'policyJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'policyJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyJson',
        value: '',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'policyJson',
        value: '',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'policyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'policyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'policyName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'policyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'policyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'policyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'policyName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyName',
        value: '',
      ));
    });
  }

  QueryBuilder<Policy, Policy, QAfterFilterCondition> policyNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'policyName',
        value: '',
      ));
    });
  }
}

extension PolicyQueryObject on QueryBuilder<Policy, Policy, QFilterCondition> {}

extension PolicyQueryLinks on QueryBuilder<Policy, Policy, QFilterCondition> {}

extension PolicyQuerySortBy on QueryBuilder<Policy, Policy, QSortBy> {
  QueryBuilder<Policy, Policy, QAfterSortBy> sortByApplicableLayer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicableLayer', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByApplicableLayerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicableLayer', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByCreatedByAdminId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByAdminId', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByCreatedByAdminIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByAdminId', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByPolicyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyId', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByPolicyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyId', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByPolicyJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyJson', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByPolicyJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyJson', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByPolicyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyName', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> sortByPolicyNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyName', Sort.desc);
    });
  }
}

extension PolicyQuerySortThenBy on QueryBuilder<Policy, Policy, QSortThenBy> {
  QueryBuilder<Policy, Policy, QAfterSortBy> thenByApplicableLayer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicableLayer', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByApplicableLayerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicableLayer', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByCreatedByAdminId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByAdminId', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByCreatedByAdminIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByAdminId', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByPolicyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyId', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByPolicyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyId', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByPolicyJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyJson', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByPolicyJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyJson', Sort.desc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByPolicyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyName', Sort.asc);
    });
  }

  QueryBuilder<Policy, Policy, QAfterSortBy> thenByPolicyNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyName', Sort.desc);
    });
  }
}

extension PolicyQueryWhereDistinct on QueryBuilder<Policy, Policy, QDistinct> {
  QueryBuilder<Policy, Policy, QDistinct> distinctByApplicableLayer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'applicableLayer');
    });
  }

  QueryBuilder<Policy, Policy, QDistinct> distinctByCreatedByAdminId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByAdminId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Policy, Policy, QDistinct> distinctByLocalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Policy, Policy, QDistinct> distinctByPolicyId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'policyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Policy, Policy, QDistinct> distinctByPolicyJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'policyJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Policy, Policy, QDistinct> distinctByPolicyName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'policyName', caseSensitive: caseSensitive);
    });
  }
}

extension PolicyQueryProperty on QueryBuilder<Policy, Policy, QQueryProperty> {
  QueryBuilder<Policy, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Policy, int, QQueryOperations> applicableLayerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'applicableLayer');
    });
  }

  QueryBuilder<Policy, String?, QQueryOperations> createdByAdminIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByAdminId');
    });
  }

  QueryBuilder<Policy, String, QQueryOperations> localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }

  QueryBuilder<Policy, String?, QQueryOperations> policyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'policyId');
    });
  }

  QueryBuilder<Policy, String, QQueryOperations> policyJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'policyJson');
    });
  }

  QueryBuilder<Policy, String, QQueryOperations> policyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'policyName');
    });
  }
}
