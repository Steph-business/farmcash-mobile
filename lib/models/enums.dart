/// Enums miroirs du schéma Prisma backend.
///
/// Convention sérialisation : la valeur JSON est exactement la valeur Postgres
/// (UPPER_CASE) — utilisée par json_serializable via `@JsonEnum(valueField: 'apiValue')`.
///
/// Pour gérer un enum inconnu sans crasher, chaque field utilisant un enum
/// dans un Freezed model doit porter :
/// ```dart
/// @JsonKey(unknownEnumValue: UserRole.unknown)
/// ```
library;

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'apiValue')
enum UserRole {
  farmer('FARMER'),
  buyer('BUYER'),
  transporter('TRANSPORTER'),
  exporter('EXPORTER'),
  cooperative('COOPERATIVE'),
  admin('ADMIN'),
  unknown('UNKNOWN');

  const UserRole(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum OrderStatus {
  sent('SENT'),
  accepted('ACCEPTED'),
  rejected('REJECTED'),
  inProgress('IN_PROGRESS'),
  delivered('DELIVERED'),
  completed('COMPLETED'),
  disputed('DISPUTED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const OrderStatus(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum ProductStatus {
  draft('DRAFT'),
  active('ACTIVE'),
  paused('PAUSED'),
  sold('SOLD'),
  expired('EXPIRED'),
  unknown('UNKNOWN');

  const ProductStatus(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum ProductQuality {
  standard('STANDARD'),
  premium('PREMIUM'),
  bio('BIO'),
  equitable('EQUITABLE'),
  unknown('UNKNOWN');

  const ProductQuality(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum ShipmentStatus {
  requested('REQUESTED'),
  accepted('ACCEPTED'),
  loading('LOADING'),
  inTransit('IN_TRANSIT'),
  delivered('DELIVERED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const ShipmentStatus(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum MobileProvider {
  orangeMoney('ORANGE_MONEY'),
  mtnMomo('MTN_MOMO'),
  wave('WAVE'),
  moov('MOOV'),
  virement('VIREMENT'),
  wallet('WALLET'),
  unknown('UNKNOWN');

  const MobileProvider(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum KycStatus {
  pending('PENDING'),
  verified('VERIFIED'),
  rejected('REJECTED'),
  expired('EXPIRED'),
  unknown('UNKNOWN');

  const KycStatus(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum CoopAnnonceStatus {
  pending('PENDING'),
  validated('VALIDATED'),
  included('INCLUDED'),
  rejected('REJECTED'),
  unknown('UNKNOWN');

  const CoopAnnonceStatus(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum CoopRequestStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  rejected('REJECTED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const CoopRequestStatus(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum CoopAdvanceStatus {
  paid('PAID'),
  reimbursed('REIMBURSED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const CoopAdvanceStatus(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum BuyOfferAudience {
  public('PUBLIC'),
  allCooperatives('ALL_COOPERATIVES'),
  specificCooperative('SPECIFIC_COOPERATIVE'),
  unknown('UNKNOWN');

  const BuyOfferAudience(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum PrevisionStatus {
  open('OPEN'),
  converted('CONVERTED'),
  expired('EXPIRED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const PrevisionStatus(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum NegotiationStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  rejected('REJECTED'),
  counterOffered('COUNTER_OFFERED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const NegotiationStatus(this.apiValue);
  final String apiValue;
}

/// Miroir de `OtpPurpose` côté backend (auth/dto/otp.dto.ts).
/// Utilisé pour `/auth/send-otp` et `/auth/verify-otp`.
@JsonEnum(valueField: 'apiValue')
enum OtpPurpose {
  login('LOGIN'),
  register('REGISTER'),
  resetPin('RESET_PIN');

  const OtpPurpose(this.apiValue);
  final String apiValue;
}

@JsonEnum(valueField: 'apiValue')
enum CoopMemberRole {
  membre('MEMBRE'),
  gerant('GERANT'),
  tresorier('TRESORIER'),
  president('PRESIDENT'),
  unknown('UNKNOWN');

  const CoopMemberRole(this.apiValue);
  final String apiValue;
}
