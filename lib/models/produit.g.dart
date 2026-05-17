// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProduitImpl _$$ProduitImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ProduitImpl',
      json,
      ($checkedConvert) {
        final val = _$ProduitImpl(
          id: $checkedConvert('id', (v) => v as String),
          slug: $checkedConvert('slug', (v) => v as String),
          nom: $checkedConvert('nom', (v) => v as String),
          sousCategorieId: $checkedConvert(
            'sous_categorie_id',
            (v) => v as String?,
          ),
          description: $checkedConvert('description', (v) => v as String?),
          prixMarcheMin: $checkedConvert(
            'prix_marche_min',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          prixMarcheMax: $checkedConvert(
            'prix_marche_max',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          estSaisonnier: $checkedConvert(
            'est_saisonnier',
            (v) => v as bool? ?? false,
          ),
          estExportable: $checkedConvert(
            'est_exportable',
            (v) => v as bool? ?? false,
          ),
          iconUrl: $checkedConvert('icon_url', (v) => v as String?),
          imageUrl: $checkedConvert('image_url', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'sousCategorieId': 'sous_categorie_id',
        'prixMarcheMin': 'prix_marche_min',
        'prixMarcheMax': 'prix_marche_max',
        'estSaisonnier': 'est_saisonnier',
        'estExportable': 'est_exportable',
        'iconUrl': 'icon_url',
        'imageUrl': 'image_url',
      },
    );

Map<String, dynamic> _$$ProduitImplToJson(
  _$ProduitImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'nom': instance.nom,
  if (instance.sousCategorieId case final value?) 'sous_categorie_id': value,
  if (instance.description case final value?) 'description': value,
  if (const FlexDoubleN().toJson(instance.prixMarcheMin) case final value?)
    'prix_marche_min': value,
  if (const FlexDoubleN().toJson(instance.prixMarcheMax) case final value?)
    'prix_marche_max': value,
  'est_saisonnier': instance.estSaisonnier,
  'est_exportable': instance.estExportable,
  if (instance.iconUrl case final value?) 'icon_url': value,
  if (instance.imageUrl case final value?) 'image_url': value,
};

_$CategorieImpl _$$CategorieImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$CategorieImpl',
      json,
      ($checkedConvert) {
        final val = _$CategorieImpl(
          id: $checkedConvert('id', (v) => v as String),
          slug: $checkedConvert('slug', (v) => v as String),
          nom: $checkedConvert('nom', (v) => v as String),
          iconUrl: $checkedConvert('icon_url', (v) => v as String?),
          sousCategories: $checkedConvert(
            'sous_categories',
            (v) =>
                (v as List<dynamic>?)
                    ?.map(
                      (e) => SousCategorie.fromJson(e as Map<String, dynamic>),
                    )
                    .toList() ??
                const <SousCategorie>[],
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'iconUrl': 'icon_url',
        'sousCategories': 'sous_categories',
      },
    );

Map<String, dynamic> _$$CategorieImplToJson(_$CategorieImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'nom': instance.nom,
      if (instance.iconUrl case final value?) 'icon_url': value,
      'sous_categories': instance.sousCategories,
    };

_$SousCategorieImpl _$$SousCategorieImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$SousCategorieImpl', json, ($checkedConvert) {
      final val = _$SousCategorieImpl(
        id: $checkedConvert('id', (v) => v as String),
        categorieId: $checkedConvert('categorie_id', (v) => v as String),
        slug: $checkedConvert('slug', (v) => v as String),
        nom: $checkedConvert('nom', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'categorieId': 'categorie_id'});

Map<String, dynamic> _$$SousCategorieImplToJson(_$SousCategorieImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categorie_id': instance.categorieId,
      'slug': instance.slug,
      'nom': instance.nom,
    };
