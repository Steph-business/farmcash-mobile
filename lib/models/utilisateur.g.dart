// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utilisateur.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UtilisateurImpl _$$UtilisateurImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$UtilisateurImpl',
      json,
      ($checkedConvert) {
        final val = _$UtilisateurImpl(
          id: $checkedConvert('id', (v) => v as String),
          phone: $checkedConvert('phone', (v) => v as String?),
          role: $checkedConvert(
            'role',
            (v) =>
                $enumDecodeNullable(
                  _$UserRoleEnumMap,
                  v,
                  unknownValue: UserRole.unknown,
                ) ??
                UserRole.unknown,
          ),
          fullName: $checkedConvert('full_name', (v) => v as String?),
          photoUrl: $checkedConvert('photo_url', (v) => v as String?),
          email: $checkedConvert('email', (v) => v as String?),
          isVerified: $checkedConvert(
            'is_verified',
            (v) => v as bool? ?? false,
          ),
          isActive: $checkedConvert('is_active', (v) => v as bool? ?? true),
          rating: $checkedConvert(
            'rating',
            (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
          ),
          walletBalance: $checkedConvert(
            'wallet_balance',
            (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
          ),
          cooperativeId: $checkedConvert('cooperative_id', (v) => v as String?),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          hasRoleProfile: $checkedConvert(
            'has_role_profile',
            (v) => v as bool? ?? true,
          ),
          essentialFieldsComplete: $checkedConvert(
            'essential_fields_complete',
            (v) => v as bool? ?? true,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'fullName': 'full_name',
        'photoUrl': 'photo_url',
        'isVerified': 'is_verified',
        'isActive': 'is_active',
        'walletBalance': 'wallet_balance',
        'cooperativeId': 'cooperative_id',
        'createdAt': 'created_at',
        'hasRoleProfile': 'has_role_profile',
        'essentialFieldsComplete': 'essential_fields_complete',
      },
    );

Map<String, dynamic> _$$UtilisateurImplToJson(_$UtilisateurImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.phone case final value?) 'phone': value,
      'role': _$UserRoleEnumMap[instance.role]!,
      if (instance.fullName case final value?) 'full_name': value,
      if (instance.photoUrl case final value?) 'photo_url': value,
      if (instance.email case final value?) 'email': value,
      'is_verified': instance.isVerified,
      'is_active': instance.isActive,
      if (const FlexDouble().toJson(instance.rating) case final value?)
        'rating': value,
      if (const FlexDouble().toJson(instance.walletBalance) case final value?)
        'wallet_balance': value,
      if (instance.cooperativeId case final value?) 'cooperative_id': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      'has_role_profile': instance.hasRoleProfile,
      'essential_fields_complete': instance.essentialFieldsComplete,
    };

const _$UserRoleEnumMap = {
  UserRole.farmer: 'FARMER',
  UserRole.buyer: 'BUYER',
  UserRole.transporter: 'TRANSPORTER',
  UserRole.exporter: 'EXPORTER',
  UserRole.cooperative: 'COOPERATIVE',
  UserRole.admin: 'ADMIN',
  UserRole.unknown: 'UNKNOWN',
};

_$AuthTokensImpl _$$AuthTokensImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$AuthTokensImpl',
      json,
      ($checkedConvert) {
        final val = _$AuthTokensImpl(
          accessToken: $checkedConvert('access_token', (v) => v as String),
          refreshToken: $checkedConvert('refresh_token', (v) => v as String),
          user: $checkedConvert(
            'user',
            (v) => v == null
                ? null
                : Utilisateur.fromJson(v as Map<String, dynamic>),
          ),
          expiresIn: $checkedConvert('expires_in', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'accessToken': 'access_token',
        'refreshToken': 'refresh_token',
        'expiresIn': 'expires_in',
      },
    );

Map<String, dynamic> _$$AuthTokensImplToJson(_$AuthTokensImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      if (instance.user case final value?) 'user': value,
      if (instance.expiresIn case final value?) 'expires_in': value,
    };
