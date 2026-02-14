// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bait.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BaitBrand _$BaitBrandFromJson(Map<String, dynamic> json) {
  return _BaitBrand.fromJson(json);
}

/// @nodoc
mixin _$BaitBrand {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BaitBrand to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaitBrand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaitBrandCopyWith<BaitBrand> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaitBrandCopyWith<$Res> {
  factory $BaitBrandCopyWith(BaitBrand value, $Res Function(BaitBrand) then) =
      _$BaitBrandCopyWithImpl<$Res, BaitBrand>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? logoUrl,
      String? website,
      String? description,
      DateTime? createdAt});
}

/// @nodoc
class _$BaitBrandCopyWithImpl<$Res, $Val extends BaitBrand>
    implements $BaitBrandCopyWith<$Res> {
  _$BaitBrandCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaitBrand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logoUrl = freezed,
    Object? website = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BaitBrandImplCopyWith<$Res>
    implements $BaitBrandCopyWith<$Res> {
  factory _$$BaitBrandImplCopyWith(
          _$BaitBrandImpl value, $Res Function(_$BaitBrandImpl) then) =
      __$$BaitBrandImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? logoUrl,
      String? website,
      String? description,
      DateTime? createdAt});
}

/// @nodoc
class __$$BaitBrandImplCopyWithImpl<$Res>
    extends _$BaitBrandCopyWithImpl<$Res, _$BaitBrandImpl>
    implements _$$BaitBrandImplCopyWith<$Res> {
  __$$BaitBrandImplCopyWithImpl(
      _$BaitBrandImpl _value, $Res Function(_$BaitBrandImpl) _then)
      : super(_value, _then);

  /// Create a copy of BaitBrand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logoUrl = freezed,
    Object? website = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$BaitBrandImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BaitBrandImpl implements _BaitBrand {
  const _$BaitBrandImpl(
      {required this.id,
      required this.name,
      this.logoUrl,
      this.website,
      this.description,
      this.createdAt});

  factory _$BaitBrandImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaitBrandImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? logoUrl;
  @override
  final String? website;
  @override
  final String? description;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'BaitBrand(id: $id, name: $name, logoUrl: $logoUrl, website: $website, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaitBrandImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, logoUrl, website, description, createdAt);

  /// Create a copy of BaitBrand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaitBrandImplCopyWith<_$BaitBrandImpl> get copyWith =>
      __$$BaitBrandImplCopyWithImpl<_$BaitBrandImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaitBrandImplToJson(
      this,
    );
  }
}

abstract class _BaitBrand implements BaitBrand {
  const factory _BaitBrand(
      {required final String id,
      required final String name,
      final String? logoUrl,
      final String? website,
      final String? description,
      final DateTime? createdAt}) = _$BaitBrandImpl;

  factory _BaitBrand.fromJson(Map<String, dynamic> json) =
      _$BaitBrandImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get logoUrl;
  @override
  String? get website;
  @override
  String? get description;
  @override
  DateTime? get createdAt;

  /// Create a copy of BaitBrand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaitBrandImplCopyWith<_$BaitBrandImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Bait _$BaitFromJson(Map<String, dynamic> json) {
  return _Bait.fromJson(json);
}

/// @nodoc
mixin _$Bait {
  String get id => throw _privateConstructorUsedError;
  String? get brandId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get modelNumber => throw _privateConstructorUsedError;
  BaitCategory get category => throw _privateConstructorUsedError;
  String? get subcategory => throw _privateConstructorUsedError;
  List<String> get availableColors => throw _privateConstructorUsedError;
  List<String> get availableSizes => throw _privateConstructorUsedError;
  double? get weightRangeMin => throw _privateConstructorUsedError;
  double? get weightRangeMax => throw _privateConstructorUsedError;
  String? get primaryImageUrl => throw _privateConstructorUsedError;
  List<String> get additionalImages => throw _privateConstructorUsedError;
  String? get productDescription => throw _privateConstructorUsedError;
  String? get manufacturerNotes => throw _privateConstructorUsedError;
  bool get isCrappieSpecific => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  double? get retailPriceUsd => throw _privateConstructorUsedError;
  AvailabilityStatus get availabilityStatus =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Populated from joins
  BaitBrand? get brand => throw _privateConstructorUsedError;

  /// Serializes this Bait to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Bait
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaitCopyWith<Bait> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaitCopyWith<$Res> {
  factory $BaitCopyWith(Bait value, $Res Function(Bait) then) =
      _$BaitCopyWithImpl<$Res, Bait>;
  @useResult
  $Res call(
      {String id,
      String? brandId,
      String name,
      String? modelNumber,
      BaitCategory category,
      String? subcategory,
      List<String> availableColors,
      List<String> availableSizes,
      double? weightRangeMin,
      double? weightRangeMax,
      String? primaryImageUrl,
      List<String> additionalImages,
      String? productDescription,
      String? manufacturerNotes,
      bool isCrappieSpecific,
      bool isVerified,
      double? retailPriceUsd,
      AvailabilityStatus availabilityStatus,
      DateTime? createdAt,
      DateTime? updatedAt,
      BaitBrand? brand});

  $BaitBrandCopyWith<$Res>? get brand;
}

/// @nodoc
class _$BaitCopyWithImpl<$Res, $Val extends Bait>
    implements $BaitCopyWith<$Res> {
  _$BaitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bait
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brandId = freezed,
    Object? name = null,
    Object? modelNumber = freezed,
    Object? category = null,
    Object? subcategory = freezed,
    Object? availableColors = null,
    Object? availableSizes = null,
    Object? weightRangeMin = freezed,
    Object? weightRangeMax = freezed,
    Object? primaryImageUrl = freezed,
    Object? additionalImages = null,
    Object? productDescription = freezed,
    Object? manufacturerNotes = freezed,
    Object? isCrappieSpecific = null,
    Object? isVerified = null,
    Object? retailPriceUsd = freezed,
    Object? availabilityStatus = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? brand = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brandId: freezed == brandId
          ? _value.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      modelNumber: freezed == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as BaitCategory,
      subcategory: freezed == subcategory
          ? _value.subcategory
          : subcategory // ignore: cast_nullable_to_non_nullable
              as String?,
      availableColors: null == availableColors
          ? _value.availableColors
          : availableColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      availableSizes: null == availableSizes
          ? _value.availableSizes
          : availableSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weightRangeMin: freezed == weightRangeMin
          ? _value.weightRangeMin
          : weightRangeMin // ignore: cast_nullable_to_non_nullable
              as double?,
      weightRangeMax: freezed == weightRangeMax
          ? _value.weightRangeMax
          : weightRangeMax // ignore: cast_nullable_to_non_nullable
              as double?,
      primaryImageUrl: freezed == primaryImageUrl
          ? _value.primaryImageUrl
          : primaryImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalImages: null == additionalImages
          ? _value.additionalImages
          : additionalImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      productDescription: freezed == productDescription
          ? _value.productDescription
          : productDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      manufacturerNotes: freezed == manufacturerNotes
          ? _value.manufacturerNotes
          : manufacturerNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      isCrappieSpecific: null == isCrappieSpecific
          ? _value.isCrappieSpecific
          : isCrappieSpecific // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      retailPriceUsd: freezed == retailPriceUsd
          ? _value.retailPriceUsd
          : retailPriceUsd // ignore: cast_nullable_to_non_nullable
              as double?,
      availabilityStatus: null == availabilityStatus
          ? _value.availabilityStatus
          : availabilityStatus // ignore: cast_nullable_to_non_nullable
              as AvailabilityStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as BaitBrand?,
    ) as $Val);
  }

  /// Create a copy of Bait
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BaitBrandCopyWith<$Res>? get brand {
    if (_value.brand == null) {
      return null;
    }

    return $BaitBrandCopyWith<$Res>(_value.brand!, (value) {
      return _then(_value.copyWith(brand: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BaitImplCopyWith<$Res> implements $BaitCopyWith<$Res> {
  factory _$$BaitImplCopyWith(
          _$BaitImpl value, $Res Function(_$BaitImpl) then) =
      __$$BaitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? brandId,
      String name,
      String? modelNumber,
      BaitCategory category,
      String? subcategory,
      List<String> availableColors,
      List<String> availableSizes,
      double? weightRangeMin,
      double? weightRangeMax,
      String? primaryImageUrl,
      List<String> additionalImages,
      String? productDescription,
      String? manufacturerNotes,
      bool isCrappieSpecific,
      bool isVerified,
      double? retailPriceUsd,
      AvailabilityStatus availabilityStatus,
      DateTime? createdAt,
      DateTime? updatedAt,
      BaitBrand? brand});

  @override
  $BaitBrandCopyWith<$Res>? get brand;
}

/// @nodoc
class __$$BaitImplCopyWithImpl<$Res>
    extends _$BaitCopyWithImpl<$Res, _$BaitImpl>
    implements _$$BaitImplCopyWith<$Res> {
  __$$BaitImplCopyWithImpl(_$BaitImpl _value, $Res Function(_$BaitImpl) _then)
      : super(_value, _then);

  /// Create a copy of Bait
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brandId = freezed,
    Object? name = null,
    Object? modelNumber = freezed,
    Object? category = null,
    Object? subcategory = freezed,
    Object? availableColors = null,
    Object? availableSizes = null,
    Object? weightRangeMin = freezed,
    Object? weightRangeMax = freezed,
    Object? primaryImageUrl = freezed,
    Object? additionalImages = null,
    Object? productDescription = freezed,
    Object? manufacturerNotes = freezed,
    Object? isCrappieSpecific = null,
    Object? isVerified = null,
    Object? retailPriceUsd = freezed,
    Object? availabilityStatus = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? brand = freezed,
  }) {
    return _then(_$BaitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brandId: freezed == brandId
          ? _value.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      modelNumber: freezed == modelNumber
          ? _value.modelNumber
          : modelNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as BaitCategory,
      subcategory: freezed == subcategory
          ? _value.subcategory
          : subcategory // ignore: cast_nullable_to_non_nullable
              as String?,
      availableColors: null == availableColors
          ? _value._availableColors
          : availableColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      availableSizes: null == availableSizes
          ? _value._availableSizes
          : availableSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weightRangeMin: freezed == weightRangeMin
          ? _value.weightRangeMin
          : weightRangeMin // ignore: cast_nullable_to_non_nullable
              as double?,
      weightRangeMax: freezed == weightRangeMax
          ? _value.weightRangeMax
          : weightRangeMax // ignore: cast_nullable_to_non_nullable
              as double?,
      primaryImageUrl: freezed == primaryImageUrl
          ? _value.primaryImageUrl
          : primaryImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalImages: null == additionalImages
          ? _value._additionalImages
          : additionalImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      productDescription: freezed == productDescription
          ? _value.productDescription
          : productDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      manufacturerNotes: freezed == manufacturerNotes
          ? _value.manufacturerNotes
          : manufacturerNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      isCrappieSpecific: null == isCrappieSpecific
          ? _value.isCrappieSpecific
          : isCrappieSpecific // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      retailPriceUsd: freezed == retailPriceUsd
          ? _value.retailPriceUsd
          : retailPriceUsd // ignore: cast_nullable_to_non_nullable
              as double?,
      availabilityStatus: null == availabilityStatus
          ? _value.availabilityStatus
          : availabilityStatus // ignore: cast_nullable_to_non_nullable
              as AvailabilityStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as BaitBrand?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BaitImpl implements _Bait {
  const _$BaitImpl(
      {required this.id,
      this.brandId,
      required this.name,
      this.modelNumber,
      required this.category,
      this.subcategory,
      final List<String> availableColors = const [],
      final List<String> availableSizes = const [],
      this.weightRangeMin,
      this.weightRangeMax,
      this.primaryImageUrl,
      final List<String> additionalImages = const [],
      this.productDescription,
      this.manufacturerNotes,
      this.isCrappieSpecific = true,
      this.isVerified = false,
      this.retailPriceUsd,
      this.availabilityStatus = AvailabilityStatus.available,
      this.createdAt,
      this.updatedAt,
      this.brand})
      : _availableColors = availableColors,
        _availableSizes = availableSizes,
        _additionalImages = additionalImages;

  factory _$BaitImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaitImplFromJson(json);

  @override
  final String id;
  @override
  final String? brandId;
  @override
  final String name;
  @override
  final String? modelNumber;
  @override
  final BaitCategory category;
  @override
  final String? subcategory;
  final List<String> _availableColors;
  @override
  @JsonKey()
  List<String> get availableColors {
    if (_availableColors is EqualUnmodifiableListView) return _availableColors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableColors);
  }

  final List<String> _availableSizes;
  @override
  @JsonKey()
  List<String> get availableSizes {
    if (_availableSizes is EqualUnmodifiableListView) return _availableSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableSizes);
  }

  @override
  final double? weightRangeMin;
  @override
  final double? weightRangeMax;
  @override
  final String? primaryImageUrl;
  final List<String> _additionalImages;
  @override
  @JsonKey()
  List<String> get additionalImages {
    if (_additionalImages is EqualUnmodifiableListView)
      return _additionalImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_additionalImages);
  }

  @override
  final String? productDescription;
  @override
  final String? manufacturerNotes;
  @override
  @JsonKey()
  final bool isCrappieSpecific;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  final double? retailPriceUsd;
  @override
  @JsonKey()
  final AvailabilityStatus availabilityStatus;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
// Populated from joins
  @override
  final BaitBrand? brand;

  @override
  String toString() {
    return 'Bait(id: $id, brandId: $brandId, name: $name, modelNumber: $modelNumber, category: $category, subcategory: $subcategory, availableColors: $availableColors, availableSizes: $availableSizes, weightRangeMin: $weightRangeMin, weightRangeMax: $weightRangeMax, primaryImageUrl: $primaryImageUrl, additionalImages: $additionalImages, productDescription: $productDescription, manufacturerNotes: $manufacturerNotes, isCrappieSpecific: $isCrappieSpecific, isVerified: $isVerified, retailPriceUsd: $retailPriceUsd, availabilityStatus: $availabilityStatus, createdAt: $createdAt, updatedAt: $updatedAt, brand: $brand)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brandId, brandId) || other.brandId == brandId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.modelNumber, modelNumber) ||
                other.modelNumber == modelNumber) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory) &&
            const DeepCollectionEquality()
                .equals(other._availableColors, _availableColors) &&
            const DeepCollectionEquality()
                .equals(other._availableSizes, _availableSizes) &&
            (identical(other.weightRangeMin, weightRangeMin) ||
                other.weightRangeMin == weightRangeMin) &&
            (identical(other.weightRangeMax, weightRangeMax) ||
                other.weightRangeMax == weightRangeMax) &&
            (identical(other.primaryImageUrl, primaryImageUrl) ||
                other.primaryImageUrl == primaryImageUrl) &&
            const DeepCollectionEquality()
                .equals(other._additionalImages, _additionalImages) &&
            (identical(other.productDescription, productDescription) ||
                other.productDescription == productDescription) &&
            (identical(other.manufacturerNotes, manufacturerNotes) ||
                other.manufacturerNotes == manufacturerNotes) &&
            (identical(other.isCrappieSpecific, isCrappieSpecific) ||
                other.isCrappieSpecific == isCrappieSpecific) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.retailPriceUsd, retailPriceUsd) ||
                other.retailPriceUsd == retailPriceUsd) &&
            (identical(other.availabilityStatus, availabilityStatus) ||
                other.availabilityStatus == availabilityStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.brand, brand) || other.brand == brand));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        brandId,
        name,
        modelNumber,
        category,
        subcategory,
        const DeepCollectionEquality().hash(_availableColors),
        const DeepCollectionEquality().hash(_availableSizes),
        weightRangeMin,
        weightRangeMax,
        primaryImageUrl,
        const DeepCollectionEquality().hash(_additionalImages),
        productDescription,
        manufacturerNotes,
        isCrappieSpecific,
        isVerified,
        retailPriceUsd,
        availabilityStatus,
        createdAt,
        updatedAt,
        brand
      ]);

  /// Create a copy of Bait
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaitImplCopyWith<_$BaitImpl> get copyWith =>
      __$$BaitImplCopyWithImpl<_$BaitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaitImplToJson(
      this,
    );
  }
}

abstract class _Bait implements Bait {
  const factory _Bait(
      {required final String id,
      final String? brandId,
      required final String name,
      final String? modelNumber,
      required final BaitCategory category,
      final String? subcategory,
      final List<String> availableColors,
      final List<String> availableSizes,
      final double? weightRangeMin,
      final double? weightRangeMax,
      final String? primaryImageUrl,
      final List<String> additionalImages,
      final String? productDescription,
      final String? manufacturerNotes,
      final bool isCrappieSpecific,
      final bool isVerified,
      final double? retailPriceUsd,
      final AvailabilityStatus availabilityStatus,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final BaitBrand? brand}) = _$BaitImpl;

  factory _Bait.fromJson(Map<String, dynamic> json) = _$BaitImpl.fromJson;

  @override
  String get id;
  @override
  String? get brandId;
  @override
  String get name;
  @override
  String? get modelNumber;
  @override
  BaitCategory get category;
  @override
  String? get subcategory;
  @override
  List<String> get availableColors;
  @override
  List<String> get availableSizes;
  @override
  double? get weightRangeMin;
  @override
  double? get weightRangeMax;
  @override
  String? get primaryImageUrl;
  @override
  List<String> get additionalImages;
  @override
  String? get productDescription;
  @override
  String? get manufacturerNotes;
  @override
  bool get isCrappieSpecific;
  @override
  bool get isVerified;
  @override
  double? get retailPriceUsd;
  @override
  AvailabilityStatus get availabilityStatus;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Populated from joins
  @override
  BaitBrand? get brand;

  /// Create a copy of Bait
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaitImplCopyWith<_$BaitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BaitReport _$BaitReportFromJson(Map<String, dynamic> json) {
  return _BaitReport.fromJson(json);
}

/// @nodoc
mixin _$BaitReport {
  String get id => throw _privateConstructorUsedError;
  String get baitId => throw _privateConstructorUsedError;
  String? get lakeId => throw _privateConstructorUsedError;
  String? get attractorId => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get colorUsed => throw _privateConstructorUsedError;
  String get sizeUsed => throw _privateConstructorUsedError;
  double? get weightUsed => throw _privateConstructorUsedError;
  int get fishCaught => throw _privateConstructorUsedError;
  String get fishSpecies => throw _privateConstructorUsedError;
  double? get largestFishLength => throw _privateConstructorUsedError;
  double? get largestFishWeight => throw _privateConstructorUsedError;
  double? get waterTemp => throw _privateConstructorUsedError;
  WaterClarity? get waterClarity => throw _privateConstructorUsedError;
  String? get weatherConditions => throw _privateConstructorUsedError;
  FishingTimeOfDay? get timeOfDay => throw _privateConstructorUsedError;
  Season? get season => throw _privateConstructorUsedError;
  String? get techniqueUsed => throw _privateConstructorUsedError;
  double? get depthFished => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  bool get isVerifiedCatch => throw _privateConstructorUsedError;
  DateTime get reportDate => throw _privateConstructorUsedError;
  int get confidenceScore => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // Populated from joins
  Bait? get bait => throw _privateConstructorUsedError;

  /// Serializes this BaitReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaitReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaitReportCopyWith<BaitReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaitReportCopyWith<$Res> {
  factory $BaitReportCopyWith(
          BaitReport value, $Res Function(BaitReport) then) =
      _$BaitReportCopyWithImpl<$Res, BaitReport>;
  @useResult
  $Res call(
      {String id,
      String baitId,
      String? lakeId,
      String? attractorId,
      double latitude,
      double longitude,
      String colorUsed,
      String sizeUsed,
      double? weightUsed,
      int fishCaught,
      String fishSpecies,
      double? largestFishLength,
      double? largestFishWeight,
      double? waterTemp,
      WaterClarity? waterClarity,
      String? weatherConditions,
      FishingTimeOfDay? timeOfDay,
      Season? season,
      String? techniqueUsed,
      double? depthFished,
      String? userId,
      bool isVerifiedCatch,
      DateTime reportDate,
      int confidenceScore,
      String? notes,
      DateTime? createdAt,
      Bait? bait});

  $BaitCopyWith<$Res>? get bait;
}

/// @nodoc
class _$BaitReportCopyWithImpl<$Res, $Val extends BaitReport>
    implements $BaitReportCopyWith<$Res> {
  _$BaitReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaitReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? baitId = null,
    Object? lakeId = freezed,
    Object? attractorId = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? colorUsed = null,
    Object? sizeUsed = null,
    Object? weightUsed = freezed,
    Object? fishCaught = null,
    Object? fishSpecies = null,
    Object? largestFishLength = freezed,
    Object? largestFishWeight = freezed,
    Object? waterTemp = freezed,
    Object? waterClarity = freezed,
    Object? weatherConditions = freezed,
    Object? timeOfDay = freezed,
    Object? season = freezed,
    Object? techniqueUsed = freezed,
    Object? depthFished = freezed,
    Object? userId = freezed,
    Object? isVerifiedCatch = null,
    Object? reportDate = null,
    Object? confidenceScore = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? bait = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      baitId: null == baitId
          ? _value.baitId
          : baitId // ignore: cast_nullable_to_non_nullable
              as String,
      lakeId: freezed == lakeId
          ? _value.lakeId
          : lakeId // ignore: cast_nullable_to_non_nullable
              as String?,
      attractorId: freezed == attractorId
          ? _value.attractorId
          : attractorId // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      colorUsed: null == colorUsed
          ? _value.colorUsed
          : colorUsed // ignore: cast_nullable_to_non_nullable
              as String,
      sizeUsed: null == sizeUsed
          ? _value.sizeUsed
          : sizeUsed // ignore: cast_nullable_to_non_nullable
              as String,
      weightUsed: freezed == weightUsed
          ? _value.weightUsed
          : weightUsed // ignore: cast_nullable_to_non_nullable
              as double?,
      fishCaught: null == fishCaught
          ? _value.fishCaught
          : fishCaught // ignore: cast_nullable_to_non_nullable
              as int,
      fishSpecies: null == fishSpecies
          ? _value.fishSpecies
          : fishSpecies // ignore: cast_nullable_to_non_nullable
              as String,
      largestFishLength: freezed == largestFishLength
          ? _value.largestFishLength
          : largestFishLength // ignore: cast_nullable_to_non_nullable
              as double?,
      largestFishWeight: freezed == largestFishWeight
          ? _value.largestFishWeight
          : largestFishWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      waterTemp: freezed == waterTemp
          ? _value.waterTemp
          : waterTemp // ignore: cast_nullable_to_non_nullable
              as double?,
      waterClarity: freezed == waterClarity
          ? _value.waterClarity
          : waterClarity // ignore: cast_nullable_to_non_nullable
              as WaterClarity?,
      weatherConditions: freezed == weatherConditions
          ? _value.weatherConditions
          : weatherConditions // ignore: cast_nullable_to_non_nullable
              as String?,
      timeOfDay: freezed == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as FishingTimeOfDay?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as Season?,
      techniqueUsed: freezed == techniqueUsed
          ? _value.techniqueUsed
          : techniqueUsed // ignore: cast_nullable_to_non_nullable
              as String?,
      depthFished: freezed == depthFished
          ? _value.depthFished
          : depthFished // ignore: cast_nullable_to_non_nullable
              as double?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerifiedCatch: null == isVerifiedCatch
          ? _value.isVerifiedCatch
          : isVerifiedCatch // ignore: cast_nullable_to_non_nullable
              as bool,
      reportDate: null == reportDate
          ? _value.reportDate
          : reportDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bait: freezed == bait
          ? _value.bait
          : bait // ignore: cast_nullable_to_non_nullable
              as Bait?,
    ) as $Val);
  }

  /// Create a copy of BaitReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BaitCopyWith<$Res>? get bait {
    if (_value.bait == null) {
      return null;
    }

    return $BaitCopyWith<$Res>(_value.bait!, (value) {
      return _then(_value.copyWith(bait: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BaitReportImplCopyWith<$Res>
    implements $BaitReportCopyWith<$Res> {
  factory _$$BaitReportImplCopyWith(
          _$BaitReportImpl value, $Res Function(_$BaitReportImpl) then) =
      __$$BaitReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String baitId,
      String? lakeId,
      String? attractorId,
      double latitude,
      double longitude,
      String colorUsed,
      String sizeUsed,
      double? weightUsed,
      int fishCaught,
      String fishSpecies,
      double? largestFishLength,
      double? largestFishWeight,
      double? waterTemp,
      WaterClarity? waterClarity,
      String? weatherConditions,
      FishingTimeOfDay? timeOfDay,
      Season? season,
      String? techniqueUsed,
      double? depthFished,
      String? userId,
      bool isVerifiedCatch,
      DateTime reportDate,
      int confidenceScore,
      String? notes,
      DateTime? createdAt,
      Bait? bait});

  @override
  $BaitCopyWith<$Res>? get bait;
}

/// @nodoc
class __$$BaitReportImplCopyWithImpl<$Res>
    extends _$BaitReportCopyWithImpl<$Res, _$BaitReportImpl>
    implements _$$BaitReportImplCopyWith<$Res> {
  __$$BaitReportImplCopyWithImpl(
      _$BaitReportImpl _value, $Res Function(_$BaitReportImpl) _then)
      : super(_value, _then);

  /// Create a copy of BaitReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? baitId = null,
    Object? lakeId = freezed,
    Object? attractorId = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? colorUsed = null,
    Object? sizeUsed = null,
    Object? weightUsed = freezed,
    Object? fishCaught = null,
    Object? fishSpecies = null,
    Object? largestFishLength = freezed,
    Object? largestFishWeight = freezed,
    Object? waterTemp = freezed,
    Object? waterClarity = freezed,
    Object? weatherConditions = freezed,
    Object? timeOfDay = freezed,
    Object? season = freezed,
    Object? techniqueUsed = freezed,
    Object? depthFished = freezed,
    Object? userId = freezed,
    Object? isVerifiedCatch = null,
    Object? reportDate = null,
    Object? confidenceScore = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? bait = freezed,
  }) {
    return _then(_$BaitReportImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      baitId: null == baitId
          ? _value.baitId
          : baitId // ignore: cast_nullable_to_non_nullable
              as String,
      lakeId: freezed == lakeId
          ? _value.lakeId
          : lakeId // ignore: cast_nullable_to_non_nullable
              as String?,
      attractorId: freezed == attractorId
          ? _value.attractorId
          : attractorId // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      colorUsed: null == colorUsed
          ? _value.colorUsed
          : colorUsed // ignore: cast_nullable_to_non_nullable
              as String,
      sizeUsed: null == sizeUsed
          ? _value.sizeUsed
          : sizeUsed // ignore: cast_nullable_to_non_nullable
              as String,
      weightUsed: freezed == weightUsed
          ? _value.weightUsed
          : weightUsed // ignore: cast_nullable_to_non_nullable
              as double?,
      fishCaught: null == fishCaught
          ? _value.fishCaught
          : fishCaught // ignore: cast_nullable_to_non_nullable
              as int,
      fishSpecies: null == fishSpecies
          ? _value.fishSpecies
          : fishSpecies // ignore: cast_nullable_to_non_nullable
              as String,
      largestFishLength: freezed == largestFishLength
          ? _value.largestFishLength
          : largestFishLength // ignore: cast_nullable_to_non_nullable
              as double?,
      largestFishWeight: freezed == largestFishWeight
          ? _value.largestFishWeight
          : largestFishWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      waterTemp: freezed == waterTemp
          ? _value.waterTemp
          : waterTemp // ignore: cast_nullable_to_non_nullable
              as double?,
      waterClarity: freezed == waterClarity
          ? _value.waterClarity
          : waterClarity // ignore: cast_nullable_to_non_nullable
              as WaterClarity?,
      weatherConditions: freezed == weatherConditions
          ? _value.weatherConditions
          : weatherConditions // ignore: cast_nullable_to_non_nullable
              as String?,
      timeOfDay: freezed == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as FishingTimeOfDay?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as Season?,
      techniqueUsed: freezed == techniqueUsed
          ? _value.techniqueUsed
          : techniqueUsed // ignore: cast_nullable_to_non_nullable
              as String?,
      depthFished: freezed == depthFished
          ? _value.depthFished
          : depthFished // ignore: cast_nullable_to_non_nullable
              as double?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerifiedCatch: null == isVerifiedCatch
          ? _value.isVerifiedCatch
          : isVerifiedCatch // ignore: cast_nullable_to_non_nullable
              as bool,
      reportDate: null == reportDate
          ? _value.reportDate
          : reportDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bait: freezed == bait
          ? _value.bait
          : bait // ignore: cast_nullable_to_non_nullable
              as Bait?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BaitReportImpl implements _BaitReport {
  const _$BaitReportImpl(
      {required this.id,
      required this.baitId,
      this.lakeId,
      this.attractorId,
      required this.latitude,
      required this.longitude,
      required this.colorUsed,
      required this.sizeUsed,
      this.weightUsed,
      this.fishCaught = 0,
      this.fishSpecies = 'crappie',
      this.largestFishLength,
      this.largestFishWeight,
      this.waterTemp,
      this.waterClarity,
      this.weatherConditions,
      this.timeOfDay,
      this.season,
      this.techniqueUsed,
      this.depthFished,
      this.userId,
      this.isVerifiedCatch = false,
      required this.reportDate,
      this.confidenceScore = 3,
      this.notes,
      this.createdAt,
      this.bait});

  factory _$BaitReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaitReportImplFromJson(json);

  @override
  final String id;
  @override
  final String baitId;
  @override
  final String? lakeId;
  @override
  final String? attractorId;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String colorUsed;
  @override
  final String sizeUsed;
  @override
  final double? weightUsed;
  @override
  @JsonKey()
  final int fishCaught;
  @override
  @JsonKey()
  final String fishSpecies;
  @override
  final double? largestFishLength;
  @override
  final double? largestFishWeight;
  @override
  final double? waterTemp;
  @override
  final WaterClarity? waterClarity;
  @override
  final String? weatherConditions;
  @override
  final FishingTimeOfDay? timeOfDay;
  @override
  final Season? season;
  @override
  final String? techniqueUsed;
  @override
  final double? depthFished;
  @override
  final String? userId;
  @override
  @JsonKey()
  final bool isVerifiedCatch;
  @override
  final DateTime reportDate;
  @override
  @JsonKey()
  final int confidenceScore;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;
// Populated from joins
  @override
  final Bait? bait;

  @override
  String toString() {
    return 'BaitReport(id: $id, baitId: $baitId, lakeId: $lakeId, attractorId: $attractorId, latitude: $latitude, longitude: $longitude, colorUsed: $colorUsed, sizeUsed: $sizeUsed, weightUsed: $weightUsed, fishCaught: $fishCaught, fishSpecies: $fishSpecies, largestFishLength: $largestFishLength, largestFishWeight: $largestFishWeight, waterTemp: $waterTemp, waterClarity: $waterClarity, weatherConditions: $weatherConditions, timeOfDay: $timeOfDay, season: $season, techniqueUsed: $techniqueUsed, depthFished: $depthFished, userId: $userId, isVerifiedCatch: $isVerifiedCatch, reportDate: $reportDate, confidenceScore: $confidenceScore, notes: $notes, createdAt: $createdAt, bait: $bait)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaitReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.baitId, baitId) || other.baitId == baitId) &&
            (identical(other.lakeId, lakeId) || other.lakeId == lakeId) &&
            (identical(other.attractorId, attractorId) ||
                other.attractorId == attractorId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.colorUsed, colorUsed) ||
                other.colorUsed == colorUsed) &&
            (identical(other.sizeUsed, sizeUsed) ||
                other.sizeUsed == sizeUsed) &&
            (identical(other.weightUsed, weightUsed) ||
                other.weightUsed == weightUsed) &&
            (identical(other.fishCaught, fishCaught) ||
                other.fishCaught == fishCaught) &&
            (identical(other.fishSpecies, fishSpecies) ||
                other.fishSpecies == fishSpecies) &&
            (identical(other.largestFishLength, largestFishLength) ||
                other.largestFishLength == largestFishLength) &&
            (identical(other.largestFishWeight, largestFishWeight) ||
                other.largestFishWeight == largestFishWeight) &&
            (identical(other.waterTemp, waterTemp) ||
                other.waterTemp == waterTemp) &&
            (identical(other.waterClarity, waterClarity) ||
                other.waterClarity == waterClarity) &&
            (identical(other.weatherConditions, weatherConditions) ||
                other.weatherConditions == weatherConditions) &&
            (identical(other.timeOfDay, timeOfDay) ||
                other.timeOfDay == timeOfDay) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.techniqueUsed, techniqueUsed) ||
                other.techniqueUsed == techniqueUsed) &&
            (identical(other.depthFished, depthFished) ||
                other.depthFished == depthFished) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isVerifiedCatch, isVerifiedCatch) ||
                other.isVerifiedCatch == isVerifiedCatch) &&
            (identical(other.reportDate, reportDate) ||
                other.reportDate == reportDate) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.bait, bait) || other.bait == bait));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        baitId,
        lakeId,
        attractorId,
        latitude,
        longitude,
        colorUsed,
        sizeUsed,
        weightUsed,
        fishCaught,
        fishSpecies,
        largestFishLength,
        largestFishWeight,
        waterTemp,
        waterClarity,
        weatherConditions,
        timeOfDay,
        season,
        techniqueUsed,
        depthFished,
        userId,
        isVerifiedCatch,
        reportDate,
        confidenceScore,
        notes,
        createdAt,
        bait
      ]);

  /// Create a copy of BaitReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaitReportImplCopyWith<_$BaitReportImpl> get copyWith =>
      __$$BaitReportImplCopyWithImpl<_$BaitReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaitReportImplToJson(
      this,
    );
  }
}

abstract class _BaitReport implements BaitReport {
  const factory _BaitReport(
      {required final String id,
      required final String baitId,
      final String? lakeId,
      final String? attractorId,
      required final double latitude,
      required final double longitude,
      required final String colorUsed,
      required final String sizeUsed,
      final double? weightUsed,
      final int fishCaught,
      final String fishSpecies,
      final double? largestFishLength,
      final double? largestFishWeight,
      final double? waterTemp,
      final WaterClarity? waterClarity,
      final String? weatherConditions,
      final FishingTimeOfDay? timeOfDay,
      final Season? season,
      final String? techniqueUsed,
      final double? depthFished,
      final String? userId,
      final bool isVerifiedCatch,
      required final DateTime reportDate,
      final int confidenceScore,
      final String? notes,
      final DateTime? createdAt,
      final Bait? bait}) = _$BaitReportImpl;

  factory _BaitReport.fromJson(Map<String, dynamic> json) =
      _$BaitReportImpl.fromJson;

  @override
  String get id;
  @override
  String get baitId;
  @override
  String? get lakeId;
  @override
  String? get attractorId;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String get colorUsed;
  @override
  String get sizeUsed;
  @override
  double? get weightUsed;
  @override
  int get fishCaught;
  @override
  String get fishSpecies;
  @override
  double? get largestFishLength;
  @override
  double? get largestFishWeight;
  @override
  double? get waterTemp;
  @override
  WaterClarity? get waterClarity;
  @override
  String? get weatherConditions;
  @override
  FishingTimeOfDay? get timeOfDay;
  @override
  Season? get season;
  @override
  String? get techniqueUsed;
  @override
  double? get depthFished;
  @override
  String? get userId;
  @override
  bool get isVerifiedCatch;
  @override
  DateTime get reportDate;
  @override
  int get confidenceScore;
  @override
  String? get notes;
  @override
  DateTime? get createdAt; // Populated from joins
  @override
  Bait? get bait;

  /// Create a copy of BaitReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaitReportImplCopyWith<_$BaitReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BaitEffectiveness _$BaitEffectivenessFromJson(Map<String, dynamic> json) {
  return _BaitEffectiveness.fromJson(json);
}

/// @nodoc
mixin _$BaitEffectiveness {
  String get baitId => throw _privateConstructorUsedError;
  String get baitName => throw _privateConstructorUsedError;
  String? get brandName => throw _privateConstructorUsedError;
  BaitCategory get category => throw _privateConstructorUsedError;
  String get colorUsed => throw _privateConstructorUsedError;
  String get sizeUsed => throw _privateConstructorUsedError;
  int get totalReports => throw _privateConstructorUsedError;
  int get totalFish => throw _privateConstructorUsedError;
  double get avgFishPerTrip => throw _privateConstructorUsedError;
  double? get biggestFishLength => throw _privateConstructorUsedError;
  double? get biggestFishWeight => throw _privateConstructorUsedError;
  double get avgConfidence => throw _privateConstructorUsedError;
  int get lakesReported => throw _privateConstructorUsedError;

  /// Serializes this BaitEffectiveness to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaitEffectiveness
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaitEffectivenessCopyWith<BaitEffectiveness> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaitEffectivenessCopyWith<$Res> {
  factory $BaitEffectivenessCopyWith(
          BaitEffectiveness value, $Res Function(BaitEffectiveness) then) =
      _$BaitEffectivenessCopyWithImpl<$Res, BaitEffectiveness>;
  @useResult
  $Res call(
      {String baitId,
      String baitName,
      String? brandName,
      BaitCategory category,
      String colorUsed,
      String sizeUsed,
      int totalReports,
      int totalFish,
      double avgFishPerTrip,
      double? biggestFishLength,
      double? biggestFishWeight,
      double avgConfidence,
      int lakesReported});
}

/// @nodoc
class _$BaitEffectivenessCopyWithImpl<$Res, $Val extends BaitEffectiveness>
    implements $BaitEffectivenessCopyWith<$Res> {
  _$BaitEffectivenessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaitEffectiveness
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baitId = null,
    Object? baitName = null,
    Object? brandName = freezed,
    Object? category = null,
    Object? colorUsed = null,
    Object? sizeUsed = null,
    Object? totalReports = null,
    Object? totalFish = null,
    Object? avgFishPerTrip = null,
    Object? biggestFishLength = freezed,
    Object? biggestFishWeight = freezed,
    Object? avgConfidence = null,
    Object? lakesReported = null,
  }) {
    return _then(_value.copyWith(
      baitId: null == baitId
          ? _value.baitId
          : baitId // ignore: cast_nullable_to_non_nullable
              as String,
      baitName: null == baitName
          ? _value.baitName
          : baitName // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: freezed == brandName
          ? _value.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as BaitCategory,
      colorUsed: null == colorUsed
          ? _value.colorUsed
          : colorUsed // ignore: cast_nullable_to_non_nullable
              as String,
      sizeUsed: null == sizeUsed
          ? _value.sizeUsed
          : sizeUsed // ignore: cast_nullable_to_non_nullable
              as String,
      totalReports: null == totalReports
          ? _value.totalReports
          : totalReports // ignore: cast_nullable_to_non_nullable
              as int,
      totalFish: null == totalFish
          ? _value.totalFish
          : totalFish // ignore: cast_nullable_to_non_nullable
              as int,
      avgFishPerTrip: null == avgFishPerTrip
          ? _value.avgFishPerTrip
          : avgFishPerTrip // ignore: cast_nullable_to_non_nullable
              as double,
      biggestFishLength: freezed == biggestFishLength
          ? _value.biggestFishLength
          : biggestFishLength // ignore: cast_nullable_to_non_nullable
              as double?,
      biggestFishWeight: freezed == biggestFishWeight
          ? _value.biggestFishWeight
          : biggestFishWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      avgConfidence: null == avgConfidence
          ? _value.avgConfidence
          : avgConfidence // ignore: cast_nullable_to_non_nullable
              as double,
      lakesReported: null == lakesReported
          ? _value.lakesReported
          : lakesReported // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BaitEffectivenessImplCopyWith<$Res>
    implements $BaitEffectivenessCopyWith<$Res> {
  factory _$$BaitEffectivenessImplCopyWith(_$BaitEffectivenessImpl value,
          $Res Function(_$BaitEffectivenessImpl) then) =
      __$$BaitEffectivenessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String baitId,
      String baitName,
      String? brandName,
      BaitCategory category,
      String colorUsed,
      String sizeUsed,
      int totalReports,
      int totalFish,
      double avgFishPerTrip,
      double? biggestFishLength,
      double? biggestFishWeight,
      double avgConfidence,
      int lakesReported});
}

/// @nodoc
class __$$BaitEffectivenessImplCopyWithImpl<$Res>
    extends _$BaitEffectivenessCopyWithImpl<$Res, _$BaitEffectivenessImpl>
    implements _$$BaitEffectivenessImplCopyWith<$Res> {
  __$$BaitEffectivenessImplCopyWithImpl(_$BaitEffectivenessImpl _value,
      $Res Function(_$BaitEffectivenessImpl) _then)
      : super(_value, _then);

  /// Create a copy of BaitEffectiveness
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baitId = null,
    Object? baitName = null,
    Object? brandName = freezed,
    Object? category = null,
    Object? colorUsed = null,
    Object? sizeUsed = null,
    Object? totalReports = null,
    Object? totalFish = null,
    Object? avgFishPerTrip = null,
    Object? biggestFishLength = freezed,
    Object? biggestFishWeight = freezed,
    Object? avgConfidence = null,
    Object? lakesReported = null,
  }) {
    return _then(_$BaitEffectivenessImpl(
      baitId: null == baitId
          ? _value.baitId
          : baitId // ignore: cast_nullable_to_non_nullable
              as String,
      baitName: null == baitName
          ? _value.baitName
          : baitName // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: freezed == brandName
          ? _value.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as BaitCategory,
      colorUsed: null == colorUsed
          ? _value.colorUsed
          : colorUsed // ignore: cast_nullable_to_non_nullable
              as String,
      sizeUsed: null == sizeUsed
          ? _value.sizeUsed
          : sizeUsed // ignore: cast_nullable_to_non_nullable
              as String,
      totalReports: null == totalReports
          ? _value.totalReports
          : totalReports // ignore: cast_nullable_to_non_nullable
              as int,
      totalFish: null == totalFish
          ? _value.totalFish
          : totalFish // ignore: cast_nullable_to_non_nullable
              as int,
      avgFishPerTrip: null == avgFishPerTrip
          ? _value.avgFishPerTrip
          : avgFishPerTrip // ignore: cast_nullable_to_non_nullable
              as double,
      biggestFishLength: freezed == biggestFishLength
          ? _value.biggestFishLength
          : biggestFishLength // ignore: cast_nullable_to_non_nullable
              as double?,
      biggestFishWeight: freezed == biggestFishWeight
          ? _value.biggestFishWeight
          : biggestFishWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      avgConfidence: null == avgConfidence
          ? _value.avgConfidence
          : avgConfidence // ignore: cast_nullable_to_non_nullable
              as double,
      lakesReported: null == lakesReported
          ? _value.lakesReported
          : lakesReported // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BaitEffectivenessImpl implements _BaitEffectiveness {
  const _$BaitEffectivenessImpl(
      {required this.baitId,
      required this.baitName,
      this.brandName,
      required this.category,
      required this.colorUsed,
      required this.sizeUsed,
      required this.totalReports,
      required this.totalFish,
      required this.avgFishPerTrip,
      this.biggestFishLength,
      this.biggestFishWeight,
      required this.avgConfidence,
      required this.lakesReported});

  factory _$BaitEffectivenessImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaitEffectivenessImplFromJson(json);

  @override
  final String baitId;
  @override
  final String baitName;
  @override
  final String? brandName;
  @override
  final BaitCategory category;
  @override
  final String colorUsed;
  @override
  final String sizeUsed;
  @override
  final int totalReports;
  @override
  final int totalFish;
  @override
  final double avgFishPerTrip;
  @override
  final double? biggestFishLength;
  @override
  final double? biggestFishWeight;
  @override
  final double avgConfidence;
  @override
  final int lakesReported;

  @override
  String toString() {
    return 'BaitEffectiveness(baitId: $baitId, baitName: $baitName, brandName: $brandName, category: $category, colorUsed: $colorUsed, sizeUsed: $sizeUsed, totalReports: $totalReports, totalFish: $totalFish, avgFishPerTrip: $avgFishPerTrip, biggestFishLength: $biggestFishLength, biggestFishWeight: $biggestFishWeight, avgConfidence: $avgConfidence, lakesReported: $lakesReported)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaitEffectivenessImpl &&
            (identical(other.baitId, baitId) || other.baitId == baitId) &&
            (identical(other.baitName, baitName) ||
                other.baitName == baitName) &&
            (identical(other.brandName, brandName) ||
                other.brandName == brandName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.colorUsed, colorUsed) ||
                other.colorUsed == colorUsed) &&
            (identical(other.sizeUsed, sizeUsed) ||
                other.sizeUsed == sizeUsed) &&
            (identical(other.totalReports, totalReports) ||
                other.totalReports == totalReports) &&
            (identical(other.totalFish, totalFish) ||
                other.totalFish == totalFish) &&
            (identical(other.avgFishPerTrip, avgFishPerTrip) ||
                other.avgFishPerTrip == avgFishPerTrip) &&
            (identical(other.biggestFishLength, biggestFishLength) ||
                other.biggestFishLength == biggestFishLength) &&
            (identical(other.biggestFishWeight, biggestFishWeight) ||
                other.biggestFishWeight == biggestFishWeight) &&
            (identical(other.avgConfidence, avgConfidence) ||
                other.avgConfidence == avgConfidence) &&
            (identical(other.lakesReported, lakesReported) ||
                other.lakesReported == lakesReported));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      baitId,
      baitName,
      brandName,
      category,
      colorUsed,
      sizeUsed,
      totalReports,
      totalFish,
      avgFishPerTrip,
      biggestFishLength,
      biggestFishWeight,
      avgConfidence,
      lakesReported);

  /// Create a copy of BaitEffectiveness
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaitEffectivenessImplCopyWith<_$BaitEffectivenessImpl> get copyWith =>
      __$$BaitEffectivenessImplCopyWithImpl<_$BaitEffectivenessImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaitEffectivenessImplToJson(
      this,
    );
  }
}

abstract class _BaitEffectiveness implements BaitEffectiveness {
  const factory _BaitEffectiveness(
      {required final String baitId,
      required final String baitName,
      final String? brandName,
      required final BaitCategory category,
      required final String colorUsed,
      required final String sizeUsed,
      required final int totalReports,
      required final int totalFish,
      required final double avgFishPerTrip,
      final double? biggestFishLength,
      final double? biggestFishWeight,
      required final double avgConfidence,
      required final int lakesReported}) = _$BaitEffectivenessImpl;

  factory _BaitEffectiveness.fromJson(Map<String, dynamic> json) =
      _$BaitEffectivenessImpl.fromJson;

  @override
  String get baitId;
  @override
  String get baitName;
  @override
  String? get brandName;
  @override
  BaitCategory get category;
  @override
  String get colorUsed;
  @override
  String get sizeUsed;
  @override
  int get totalReports;
  @override
  int get totalFish;
  @override
  double get avgFishPerTrip;
  @override
  double? get biggestFishLength;
  @override
  double? get biggestFishWeight;
  @override
  double get avgConfidence;
  @override
  int get lakesReported;

  /// Create a copy of BaitEffectiveness
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaitEffectivenessImplCopyWith<_$BaitEffectivenessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocationBaitRecommendation _$LocationBaitRecommendationFromJson(
    Map<String, dynamic> json) {
  return _LocationBaitRecommendation.fromJson(json);
}

/// @nodoc
mixin _$LocationBaitRecommendation {
  String? get lakeId => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get baitId => throw _privateConstructorUsedError;
  String get baitName => throw _privateConstructorUsedError;
  String? get brandName => throw _privateConstructorUsedError;
  String get colorUsed => throw _privateConstructorUsedError;
  String get sizeUsed => throw _privateConstructorUsedError;
  double get avgEffectiveness => throw _privateConstructorUsedError;
  int get reportCount => throw _privateConstructorUsedError;
  DateTime get mostRecentReport =>
      throw _privateConstructorUsedError; // Additional fields from function calls
  double? get distanceMiles => throw _privateConstructorUsedError;

  /// Serializes this LocationBaitRecommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationBaitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationBaitRecommendationCopyWith<LocationBaitRecommendation>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationBaitRecommendationCopyWith<$Res> {
  factory $LocationBaitRecommendationCopyWith(LocationBaitRecommendation value,
          $Res Function(LocationBaitRecommendation) then) =
      _$LocationBaitRecommendationCopyWithImpl<$Res,
          LocationBaitRecommendation>;
  @useResult
  $Res call(
      {String? lakeId,
      double latitude,
      double longitude,
      String baitId,
      String baitName,
      String? brandName,
      String colorUsed,
      String sizeUsed,
      double avgEffectiveness,
      int reportCount,
      DateTime mostRecentReport,
      double? distanceMiles});
}

/// @nodoc
class _$LocationBaitRecommendationCopyWithImpl<$Res,
        $Val extends LocationBaitRecommendation>
    implements $LocationBaitRecommendationCopyWith<$Res> {
  _$LocationBaitRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationBaitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lakeId = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? baitId = null,
    Object? baitName = null,
    Object? brandName = freezed,
    Object? colorUsed = null,
    Object? sizeUsed = null,
    Object? avgEffectiveness = null,
    Object? reportCount = null,
    Object? mostRecentReport = null,
    Object? distanceMiles = freezed,
  }) {
    return _then(_value.copyWith(
      lakeId: freezed == lakeId
          ? _value.lakeId
          : lakeId // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      baitId: null == baitId
          ? _value.baitId
          : baitId // ignore: cast_nullable_to_non_nullable
              as String,
      baitName: null == baitName
          ? _value.baitName
          : baitName // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: freezed == brandName
          ? _value.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String?,
      colorUsed: null == colorUsed
          ? _value.colorUsed
          : colorUsed // ignore: cast_nullable_to_non_nullable
              as String,
      sizeUsed: null == sizeUsed
          ? _value.sizeUsed
          : sizeUsed // ignore: cast_nullable_to_non_nullable
              as String,
      avgEffectiveness: null == avgEffectiveness
          ? _value.avgEffectiveness
          : avgEffectiveness // ignore: cast_nullable_to_non_nullable
              as double,
      reportCount: null == reportCount
          ? _value.reportCount
          : reportCount // ignore: cast_nullable_to_non_nullable
              as int,
      mostRecentReport: null == mostRecentReport
          ? _value.mostRecentReport
          : mostRecentReport // ignore: cast_nullable_to_non_nullable
              as DateTime,
      distanceMiles: freezed == distanceMiles
          ? _value.distanceMiles
          : distanceMiles // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationBaitRecommendationImplCopyWith<$Res>
    implements $LocationBaitRecommendationCopyWith<$Res> {
  factory _$$LocationBaitRecommendationImplCopyWith(
          _$LocationBaitRecommendationImpl value,
          $Res Function(_$LocationBaitRecommendationImpl) then) =
      __$$LocationBaitRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? lakeId,
      double latitude,
      double longitude,
      String baitId,
      String baitName,
      String? brandName,
      String colorUsed,
      String sizeUsed,
      double avgEffectiveness,
      int reportCount,
      DateTime mostRecentReport,
      double? distanceMiles});
}

/// @nodoc
class __$$LocationBaitRecommendationImplCopyWithImpl<$Res>
    extends _$LocationBaitRecommendationCopyWithImpl<$Res,
        _$LocationBaitRecommendationImpl>
    implements _$$LocationBaitRecommendationImplCopyWith<$Res> {
  __$$LocationBaitRecommendationImplCopyWithImpl(
      _$LocationBaitRecommendationImpl _value,
      $Res Function(_$LocationBaitRecommendationImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationBaitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lakeId = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? baitId = null,
    Object? baitName = null,
    Object? brandName = freezed,
    Object? colorUsed = null,
    Object? sizeUsed = null,
    Object? avgEffectiveness = null,
    Object? reportCount = null,
    Object? mostRecentReport = null,
    Object? distanceMiles = freezed,
  }) {
    return _then(_$LocationBaitRecommendationImpl(
      lakeId: freezed == lakeId
          ? _value.lakeId
          : lakeId // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      baitId: null == baitId
          ? _value.baitId
          : baitId // ignore: cast_nullable_to_non_nullable
              as String,
      baitName: null == baitName
          ? _value.baitName
          : baitName // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: freezed == brandName
          ? _value.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String?,
      colorUsed: null == colorUsed
          ? _value.colorUsed
          : colorUsed // ignore: cast_nullable_to_non_nullable
              as String,
      sizeUsed: null == sizeUsed
          ? _value.sizeUsed
          : sizeUsed // ignore: cast_nullable_to_non_nullable
              as String,
      avgEffectiveness: null == avgEffectiveness
          ? _value.avgEffectiveness
          : avgEffectiveness // ignore: cast_nullable_to_non_nullable
              as double,
      reportCount: null == reportCount
          ? _value.reportCount
          : reportCount // ignore: cast_nullable_to_non_nullable
              as int,
      mostRecentReport: null == mostRecentReport
          ? _value.mostRecentReport
          : mostRecentReport // ignore: cast_nullable_to_non_nullable
              as DateTime,
      distanceMiles: freezed == distanceMiles
          ? _value.distanceMiles
          : distanceMiles // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationBaitRecommendationImpl implements _LocationBaitRecommendation {
  const _$LocationBaitRecommendationImpl(
      {this.lakeId,
      required this.latitude,
      required this.longitude,
      required this.baitId,
      required this.baitName,
      this.brandName,
      required this.colorUsed,
      required this.sizeUsed,
      required this.avgEffectiveness,
      required this.reportCount,
      required this.mostRecentReport,
      this.distanceMiles});

  factory _$LocationBaitRecommendationImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$LocationBaitRecommendationImplFromJson(json);

  @override
  final String? lakeId;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String baitId;
  @override
  final String baitName;
  @override
  final String? brandName;
  @override
  final String colorUsed;
  @override
  final String sizeUsed;
  @override
  final double avgEffectiveness;
  @override
  final int reportCount;
  @override
  final DateTime mostRecentReport;
// Additional fields from function calls
  @override
  final double? distanceMiles;

  @override
  String toString() {
    return 'LocationBaitRecommendation(lakeId: $lakeId, latitude: $latitude, longitude: $longitude, baitId: $baitId, baitName: $baitName, brandName: $brandName, colorUsed: $colorUsed, sizeUsed: $sizeUsed, avgEffectiveness: $avgEffectiveness, reportCount: $reportCount, mostRecentReport: $mostRecentReport, distanceMiles: $distanceMiles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationBaitRecommendationImpl &&
            (identical(other.lakeId, lakeId) || other.lakeId == lakeId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.baitId, baitId) || other.baitId == baitId) &&
            (identical(other.baitName, baitName) ||
                other.baitName == baitName) &&
            (identical(other.brandName, brandName) ||
                other.brandName == brandName) &&
            (identical(other.colorUsed, colorUsed) ||
                other.colorUsed == colorUsed) &&
            (identical(other.sizeUsed, sizeUsed) ||
                other.sizeUsed == sizeUsed) &&
            (identical(other.avgEffectiveness, avgEffectiveness) ||
                other.avgEffectiveness == avgEffectiveness) &&
            (identical(other.reportCount, reportCount) ||
                other.reportCount == reportCount) &&
            (identical(other.mostRecentReport, mostRecentReport) ||
                other.mostRecentReport == mostRecentReport) &&
            (identical(other.distanceMiles, distanceMiles) ||
                other.distanceMiles == distanceMiles));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      lakeId,
      latitude,
      longitude,
      baitId,
      baitName,
      brandName,
      colorUsed,
      sizeUsed,
      avgEffectiveness,
      reportCount,
      mostRecentReport,
      distanceMiles);

  /// Create a copy of LocationBaitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationBaitRecommendationImplCopyWith<_$LocationBaitRecommendationImpl>
      get copyWith => __$$LocationBaitRecommendationImplCopyWithImpl<
          _$LocationBaitRecommendationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationBaitRecommendationImplToJson(
      this,
    );
  }
}

abstract class _LocationBaitRecommendation
    implements LocationBaitRecommendation {
  const factory _LocationBaitRecommendation(
      {final String? lakeId,
      required final double latitude,
      required final double longitude,
      required final String baitId,
      required final String baitName,
      final String? brandName,
      required final String colorUsed,
      required final String sizeUsed,
      required final double avgEffectiveness,
      required final int reportCount,
      required final DateTime mostRecentReport,
      final double? distanceMiles}) = _$LocationBaitRecommendationImpl;

  factory _LocationBaitRecommendation.fromJson(Map<String, dynamic> json) =
      _$LocationBaitRecommendationImpl.fromJson;

  @override
  String? get lakeId;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String get baitId;
  @override
  String get baitName;
  @override
  String? get brandName;
  @override
  String get colorUsed;
  @override
  String get sizeUsed;
  @override
  double get avgEffectiveness;
  @override
  int get reportCount;
  @override
  DateTime get mostRecentReport; // Additional fields from function calls
  @override
  double? get distanceMiles;

  /// Create a copy of LocationBaitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationBaitRecommendationImplCopyWith<_$LocationBaitRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
