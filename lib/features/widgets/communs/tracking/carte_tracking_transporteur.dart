import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'mini_carte_trajet.dart';

/// Carte transporteur affichée sur le détail commande dès que le
/// transporteur est en route (`status == inProgress`). Donne en un
/// coup d'œil : trajet visuel + identité du transporteur + véhicule +
/// CTA vers le tracking complet.
///
/// Côté acheteur : "où est mon colis maintenant ?"
/// Côté producteur : "qui a pris ma marchandise et où elle est ?"
///
/// Données alimentées depuis `GET /logistics/shipments/by-commande/:id`
/// (cf. `Livraison.transporter` + getters dérivés). Les pages détail
/// commande passent des fallbacks honnêtes (« Transporteur assigné »,
/// « — ») quand un champ manque côté backend.
class CarteTrackingTransporteur extends StatelessWidget {
  /// Construit la carte tracking.
  ///
  /// Les callbacks `onAppeler` / `onDiscuter` / `onVoirDetails` sont
  /// **nullable** — si tu passes `null`, le bouton correspondant est
  /// caché. Idem pour `typeVehicule` / `plaque` / `nomChauffeur` :
  /// quand la donnée est absente côté backend, on passe `null` et la
  /// ligne disparaît (plutôt que d'afficher « Information à venir » ou
  /// « — » qui ne disent rien à l'utilisateur).
  const CarteTrackingTransporteur({
    super.key,
    required this.nomTransporteur,
    required this.note,
    required this.nbAvis,
    this.typeVehicule,
    this.plaque,
    this.nomChauffeur,
    this.photoUrl,
    this.onAppeler,
    this.onDiscuter,
    this.onVoirDetails,
  });

  /// Nom de l'entreprise transporteur (ex : "Transport+ CI").
  final String nomTransporteur;

  /// Note moyenne (ex : 4.8).
  final double note;

  /// Nombre d'avis (ex : 128).
  final int nbAvis;

  /// Type de véhicule (ex : "Camion 10 tonnes"). `null` → ligne cachée.
  final String? typeVehicule;

  /// Immatriculation (ex : "AB 1234 CI"). `null` → ligne cachée.
  final String? plaque;

  /// Nom du chauffeur (ex : "Yao Kouassi"). `null` → ligne cachée.
  final String? nomChauffeur;

  /// URL photo du chauffeur. Si null → avatar initiale.
  final String? photoUrl;

  /// Tap sur le bouton téléphone. `null` → bouton caché.
  final VoidCallback? onAppeler;

  /// Tap sur le bouton chat. `null` → bouton caché.
  final VoidCallback? onDiscuter;

  /// Tap sur le bouton "Voir détails du transport". `null` → bouton caché.
  final VoidCallback? onVoirDetails;

  /// `true` si au moins une des 3 lignes d'info véhicule sera affichée
  /// (typeVehicule, plaque, nomChauffeur distinct du transporteur).
  /// Sert à conditionner le `vGap16` au-dessus du bloc d'info véhicule.
  bool get _aAuMoinsUneLigneInfo {
    final hasType = typeVehicule != null && typeVehicule!.trim().isNotEmpty;
    final hasPlaque = plaque != null && plaque!.trim().isNotEmpty;
    final hasChauffeur = nomChauffeur != null &&
        nomChauffeur!.trim().isNotEmpty &&
        nomChauffeur!.trim() != nomTransporteur.trim();
    return hasType || hasPlaque || hasChauffeur;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mini-carte décorative en haut
          const MiniCarteTrajet(),

          // Bloc info transporteur
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transporteur assigné',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                AppDimens.vGap12,
                // Ligne : avatar + nom/note + boutons appel/chat (si
                // les callbacks sont fournis — sinon on les omet).
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _AvatarChauffeur(
                      // Fallback sur le nom du transporteur quand on
                      // n'a pas de chauffeur distinct (cas standard
                      // transporteur indépendant).
                      nom: nomChauffeur ?? nomTransporteur,
                      photoUrl: photoUrl,
                    ),
                    AppDimens.hGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            nomTransporteur,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Note + nb avis : seulement si on a au moins
                          // un avis. Sinon afficher « ★ 0.0 (0 avis) »
                          // donne une fausse impression négative pour un
                          // nouveau transporteur qui n'a pas été noté.
                          if (nbAvis > 0) ...[
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 13,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  note.toStringAsFixed(1),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '($nbAvis avis)',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 2),
                            Text(
                              'Pas encore évalué',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onAppeler != null) ...[
                      _BoutonRond(
                        icone: Icons.phone,
                        onTap: onAppeler!,
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (onDiscuter != null)
                      _BoutonRond(
                        icone: Icons.chat_bubble_outline,
                        onTap: onDiscuter!,
                      ),
                  ],
                ),
                // Bloc d'info véhicule. Chaque ligne n'apparaît que si
                // la donnée est renseignée. Si rien n'est dispo, on saute
                // tout le bloc plutôt que d'afficher 3 lignes de « — »
                // qui ne disent rien à l'acheteur low-tech.
                if (_aAuMoinsUneLigneInfo) AppDimens.vGap16,
                if (typeVehicule != null && typeVehicule!.trim().isNotEmpty)
                  _LigneInfo(label: 'Véhicule', valeur: typeVehicule!),
                if (plaque != null && plaque!.trim().isNotEmpty) ...[
                  if (typeVehicule != null && typeVehicule!.trim().isNotEmpty)
                    AppDimens.vGap8,
                  _LigneInfo(label: 'Plaque', valeur: plaque!),
                ],
                if (nomChauffeur != null &&
                    nomChauffeur!.trim().isNotEmpty &&
                    nomChauffeur!.trim() != nomTransporteur.trim()) ...[
                  if ((typeVehicule != null &&
                          typeVehicule!.trim().isNotEmpty) ||
                      (plaque != null && plaque!.trim().isNotEmpty))
                    AppDimens.vGap8,
                  _LigneInfo(label: 'Chauffeur', valeur: nomChauffeur!),
                ],
                // CTA « Voir détails du transport » — seulement si
                // explicitement fourni. Pour les pages détail commande,
                // on l'omet parce que le lien « Voir la position du
                // transporteur » au-dessus de la carte ouvre la MÊME
                // page tracking : pas besoin de dédoubler.
                if (onVoirDetails != null) ...[
                  AppDimens.vGap16,
                  OutlinedButton(
                    onPressed: onVoirDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: AppTextStyles.button.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Voir détails du transport'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneInfo extends StatelessWidget {
  const _LigneInfo({required this.label, required this.valeur});

  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          valeur,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _BoutonRond extends StatelessWidget {
  const _BoutonRond({required this.icone, required this.onTap});

  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Icon(icone, size: 18, color: AppColors.onPrimary),
      ),
    );
  }
}

class _AvatarChauffeur extends StatelessWidget {
  const _AvatarChauffeur({required this.nom, required this.photoUrl});

  final String nom;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return ClipOval(
      child: Container(
        width: 48,
        height: 48,
        color: AppColors.primary,
        alignment: Alignment.center,
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
                errorBuilder: (_, _, _) => _Initiale(nom: nom),
              )
            : _Initiale(nom: nom),
      ),
    );
  }
}

class _Initiale extends StatelessWidget {
  const _Initiale({required this.nom});
  final String nom;

  @override
  Widget build(BuildContext context) {
    final n = nom.trim();
    final lettre = n.isEmpty ? '?' : n.characters.first.toUpperCase();
    return Container(
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Text(
        lettre,
        style: AppTextStyles.titleMedium.copyWith(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}
