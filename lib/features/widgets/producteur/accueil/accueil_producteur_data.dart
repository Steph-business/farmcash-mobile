import '../../../../models/ai_content.dart';
import '../../../../models/annonce_achat.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/cooperative.dart';
import '../../../../models/negociation.dart';
import '../../../../models/portefeuille.dart';
import '../../../../models/publication_coop.dart';

/// Bundle de données chargées en parallèle pour l'accueil producteur.
///
/// Construit par `accueilDataProducteurProvider` dans la page d'accueil.
/// Consommé par les widgets de composition (`ContenuAccueil`) pour
/// alimenter chaque section sans déclencher de fetch supplémentaire.
class AccueilProducteurData {
  final Portefeuille? wallet;
  final List<AnnonceVente> annonces;
  final List<Candidature> offresIncoming;
  final AiInsights? insights;
  final List<AnnonceAchat> acheteursQuiCherchent;
  final Cooperative? coopInfo;
  final List<PublicationCoop> coopPublications;

  const AccueilProducteurData({
    required this.wallet,
    required this.annonces,
    required this.offresIncoming,
    required this.insights,
    required this.acheteursQuiCherchent,
    required this.coopInfo,
    required this.coopPublications,
  });

  bool get isEmpty =>
      annonces.isEmpty &&
      offresIncoming.isEmpty &&
      acheteursQuiCherchent.isEmpty &&
      coopInfo == null &&
      (insights?.tendances.isEmpty ?? true);
}
