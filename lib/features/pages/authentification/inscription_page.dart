import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/cooperative.dart';
import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../storage/secure_storage.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/authentification/cgu_checkbox.dart';
import '../../widgets/authentification/champ_telephone.dart';
import '../../widgets/authentification/champs_inscription_buyer.dart';
import '../../widgets/authentification/champs_inscription_cooperative.dart';
import '../../widgets/authentification/champs_inscription_farmer.dart';
import '../../widgets/authentification/auth_premium_bg.dart';
import '../../widgets/authentification/champs_inscription_transporter.dart';
import '../../widgets/authentification/cta_auth_premium.dart';
import '../../widgets/authentification/label_champ_inscription.dart';
import '../../widgets/authentification/logo_farmcash.dart';
import '../../widgets/authentification/selecteur_langue.dart';
import '../../widgets/communs/bouton_secondaire.dart';
import '../../widgets/communs/vue_erreur.dart';

/// Inscription — formulaire par rôle (FARMER / BUYER / COOPERATIVE / TRANSPORTER).
///
/// Reçoit le rôle via query param `?role=FARMER|BUYER|COOPERATIVE|TRANSPORTER`.
/// À la soumission : crée le compte via `AuthService.register(...)` puis
/// redirige vers l'écran OTP avec `phone` E.164 et `purpose=register`.
class InscriptionPage extends ConsumerStatefulWidget {
  const InscriptionPage({this.roleApiValue, super.key});

  final String? roleApiValue;

  @override
  ConsumerState<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends ConsumerState<InscriptionPage> {
  // ── Champs communs ────────────────────────────────────────────────────
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // ── FARMER ────────────────────────────────────────────────────────────
  String? _farmerRegion;
  final _farmerSuperficieCtrl = TextEditingController();
  final _farmerExpCtrl = TextEditingController();
  final _farmerCulturesCtrl = TextEditingController();
  Cooperative? _farmerCoop;

  // ── BUYER ─────────────────────────────────────────────────────────────
  final _buyerCompanyCtrl = TextEditingController();
  final _buyerRccmCtrl = TextEditingController();
  final _buyerCapaciteCtrl = TextEditingController();
  final _buyerZonesCtrl = TextEditingController();

  // ── COOPERATIVE ───────────────────────────────────────────────────────
  final _coopNomCtrl = TextEditingController();
  final _coopAgrementCtrl = TextEditingController();
  String? _coopRegion;
  final _coopVilleCtrl = TextEditingController();
  final _coopMembresCtrl = TextEditingController();

  // ── TRANSPORTER ───────────────────────────────────────────────────────
  // Backend : POST /auth/profile/transporteur (DTO ProfilTransporteurDto).
  // Enum TypeVehicule : MOTO, TRICYCLE, PICKUP, FOURGON, CAMION,
  // CAMION_FRIGO, REMORQUE. Tous les champs sont optionnels au DTO mais
  // le service backend refuse la création si numero_permis,
  // immatriculation, type_vehicule ET capacite_max_kg ne sont pas tous
  // fournis au premier appel — on les requiert donc côté formulaire.
  String? _transporterTypeVehicule;
  final _transporterPermisCtrl = TextEditingController();
  final _transporterImmatCtrl = TextEditingController();
  final _transporterCapaciteCtrl = TextEditingController();
  final _transporterMarqueCtrl = TextEditingController();
  final _transporterEntrepriseCtrl = TextEditingController();

  // ── État global ───────────────────────────────────────────────────────
  bool _accepteCgu = false;
  bool _loading = false;
  String? _errorMessage;

  /// Clé SecureStorage pour transmettre le profil étendu collecté à
  /// l'inscription vers [DefinirPinPage] qui le poussera au backend une
  /// fois le PIN défini (et donc un JWT valide disponible).
  static const _kPendingProfileKey = 'fc_pending_role_profile';

  @override
  void initState() {
    super.initState();
    final listeners = <TextEditingController>[
      _fullNameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _farmerSuperficieCtrl,
      _farmerExpCtrl,
      _farmerCulturesCtrl,
      _buyerCompanyCtrl,
      _buyerRccmCtrl,
      _buyerCapaciteCtrl,
      _buyerZonesCtrl,
      _coopNomCtrl,
      _coopAgrementCtrl,
      _coopVilleCtrl,
      _coopMembresCtrl,
      _transporterPermisCtrl,
      _transporterImmatCtrl,
      _transporterCapaciteCtrl,
      _transporterMarqueCtrl,
      _transporterEntrepriseCtrl,
    ];
    for (final c in listeners) {
      c.addListener(_onAnyChange);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _farmerSuperficieCtrl.dispose();
    _farmerExpCtrl.dispose();
    _farmerCulturesCtrl.dispose();
    _buyerCompanyCtrl.dispose();
    _buyerRccmCtrl.dispose();
    _buyerCapaciteCtrl.dispose();
    _buyerZonesCtrl.dispose();
    _coopNomCtrl.dispose();
    _coopAgrementCtrl.dispose();
    _coopVilleCtrl.dispose();
    _coopMembresCtrl.dispose();
    _transporterPermisCtrl.dispose();
    _transporterImmatCtrl.dispose();
    _transporterCapaciteCtrl.dispose();
    _transporterMarqueCtrl.dispose();
    _transporterEntrepriseCtrl.dispose();
    super.dispose();
  }

  void _onAnyChange() {
    if (!mounted) return;
    setState(() {});
  }

  // ── Helpers rôle ───────────────────────────────────────────────────────

  UserRole? get _userRole {
    final raw = widget.roleApiValue;
    if (raw == null || raw.isEmpty) return null;
    final upper = raw.toUpperCase();
    for (final r in UserRole.values) {
      if (r.apiValue == upper) return r;
    }
    return null;
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return 'Producteur';
      case UserRole.buyer:
        return 'Acheteur';
      case UserRole.cooperative:
        return 'Coopérative';
      case UserRole.transporter:
        return 'Transporteur';
      case UserRole.exporter:
      case UserRole.admin:
      case UserRole.unknown:
        return role.apiValue;
    }
  }

  // ── Validation ─────────────────────────────────────────────────────────

  bool _validEmail(String value) {
    if (value.isEmpty) return true; // optionnel
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(value);
  }

  bool get _baseValid {
    final fullName = _fullNameCtrl.text.trim();
    if (fullName.length < 2) return false;
    if (ChampTelephone.validate(_phoneCtrl.text) != null) return false;
    if (!_validEmail(_emailCtrl.text.trim())) return false;
    if (!_accepteCgu) return false;
    return true;
  }

  bool _roleValid(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        // Superficie et région deviennent optionnelles pour cette itération
        // (région demande un UUID non disponible sans endpoint dédié).
        return true;
      case UserRole.buyer:
        return true;
      case UserRole.cooperative:
        if (_coopNomCtrl.text.trim().isEmpty) return false;
        if (_coopAgrementCtrl.text.trim().isEmpty) return false;
        return true;
      case UserRole.transporter:
        // Le backend exige les 4 champs au premier upsert : permis,
        // immatriculation, type véhicule et capacité max.
        if (_transporterPermisCtrl.text.trim().isEmpty) return false;
        if (_transporterImmatCtrl.text.trim().isEmpty) return false;
        if (_transporterTypeVehicule == null) return false;
        final cap = double.tryParse(
          _transporterCapaciteCtrl.text.replaceAll(',', '.'),
        );
        if (cap == null || cap <= 0) return false;
        return true;
      case UserRole.exporter:
      case UserRole.admin:
      case UserRole.unknown:
        return false;
    }
  }

  bool get _canSubmit {
    final role = _userRole;
    if (role == null) return false;
    return !_loading && _baseValid && _roleValid(role);
  }

  // ── Soumission ────────────────────────────────────────────────────────

  /// Construit le payload profil étendu qui sera poussé APRÈS définition du
  /// PIN, via `POST /auth/profile/{role}`.
  ///
  /// On exclut volontairement `region_id` / `ville_id` / `coop_id` car le
  /// backend attend des UUIDs et le mobile ne dispose pas encore d'un
  /// sélecteur alimenté par `GET /reference/regions`. Le `default_cooperative_id`
  /// (FARMER) est lui envoyé à l'inscription via un autre canal.
  ///
  /// Les champs liste (`cultures_principales`, `zones_achat`, `produits`)
  /// sont splittés par virgule pour matcher le DTO backend `string[]`.
  Map<String, dynamic> _buildRoleProfile(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        final superficie =
            double.tryParse(_farmerSuperficieCtrl.text.replaceAll(',', '.'));
        final exp = int.tryParse(_farmerExpCtrl.text.trim());
        final cultures = _splitCsv(_farmerCulturesCtrl.text);
        return {
          if (superficie != null) 'superficie_ha': superficie,
          if (exp != null) 'nb_annees_exp': exp,
          if (cultures.isNotEmpty) 'cultures_principales': cultures,
        };
      case UserRole.buyer:
        final company = _buyerCompanyCtrl.text.trim();
        final rccm = _buyerRccmCtrl.text.trim();
        final capacite =
            double.tryParse(_buyerCapaciteCtrl.text.replaceAll(',', '.'));
        final zones = _splitCsv(_buyerZonesCtrl.text);
        return {
          if (company.isNotEmpty) 'company_name': company,
          if (rccm.isNotEmpty) 'numero_rccm': rccm,
          if (capacite != null) 'capacite_achat_kg': capacite,
          if (zones.isNotEmpty) 'zones_achat': zones,
        };
      case UserRole.cooperative:
        final nom = _coopNomCtrl.text.trim();
        final agrement = _coopAgrementCtrl.text.trim();
        return {
          if (nom.isNotEmpty) 'nom': nom,
          if (agrement.isNotEmpty) 'numero_agrement': agrement,
        };
      case UserRole.transporter:
        final permis = _transporterPermisCtrl.text.trim();
        final immat = _transporterImmatCtrl.text.trim();
        final capacite = double.tryParse(
          _transporterCapaciteCtrl.text.replaceAll(',', '.'),
        );
        final marque = _transporterMarqueCtrl.text.trim();
        final entreprise = _transporterEntrepriseCtrl.text.trim();
        return {
          if (permis.isNotEmpty) 'numero_permis': permis,
          if (immat.isNotEmpty) 'immatriculation': immat,
          if (_transporterTypeVehicule != null)
            'type_vehicule': _transporterTypeVehicule,
          if (capacite != null) 'capacite_max_kg': capacite,
          if (marque.isNotEmpty) 'marque_modele': marque,
          if (entreprise.isNotEmpty) 'nom_entreprise': entreprise,
        };
      case UserRole.exporter:
      case UserRole.admin:
      case UserRole.unknown:
        return const {};
    }
  }

  static List<String> _splitCsv(String raw) {
    return raw
        .split(RegExp(r'[,;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _soumettre() async {
    final role = _userRole;
    if (role == null || !_canSubmit) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final phoneE164 = ChampTelephone.composeE164(_phoneCtrl.text);
    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    // Le DTO `InscriptionDto` n'accepte que les champs basiques. Les
    // champs étendus (superficie, RCCM, etc.) sont stockés en SecureStorage
    // et seront poussés via `updateRoleProfile()` après `setPin` (cf.
    // definir_pin_page.dart) — c'est à ce moment-là qu'on a un JWT valide.
    final pendingProfile = _buildRoleProfile(role);

    try {
      final auth = ref.read(authServiceProvider);

      await auth.register(
        phone: phoneE164,
        role: role,
        fullName: fullName,
        email: email.isEmpty ? null : email,
        defaultCooperativeId:
            role == UserRole.farmer ? _farmerCoop?.id : null,
      );

      // Le backend NestJS ne déclenche pas d'OTP automatiquement à
      // l'inscription — il faut l'appeler explicitement avant de naviguer
      // vers la page de vérification.
      await auth.sendOtp(
        phone: phoneE164,
        purpose: OtpPurpose.register,
      );

      if (pendingProfile.isNotEmpty) {
        await ref.read(secureStorageProvider).write(
              _kPendingProfileKey,
              jsonEncode({'role': role.apiValue, 'data': pendingProfile}),
            );
      }

      if (!mounted) return;
      // Encoder le `+` en `%2B` — sinon il est interprété comme un espace
      // dans la query string et le backend rejette le téléphone reçu.
      final phoneEncoded = Uri.encodeQueryComponent(phoneE164);
      context.go('/otp?phone=$phoneEncoded&purpose=register');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Une erreur est survenue.';
        _loading = false;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final role = _userRole;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AuthPremiumBg(),
          SafeArea(
            child: Column(
              children: [
                // Barre supérieure : back rond premium + langue.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(
                          side: BorderSide(color: AppColors.border),
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              context.go(RouteNames.choixRolePath),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SelecteurLangue(),
                    ],
                  ),
                ),
                Expanded(
                  child: role == null
                      ? _buildEmptyState()
                      : _buildForm(role),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const LogoFarmcash(),
          const SizedBox(height: 28),
          Text(
            'Créer un compte',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 28,
              height: 1.2,
              letterSpacing: -0.6,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Choisis d'abord ton rôle pour continuer.",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          CtaAuthPremium(
            label: 'Choisir un rôle',
            onTap: () => context.go(RouteNames.choixRolePath),
          ),
          const SizedBox(height: 18),
          Center(
            child: LienTexte(
              prefixe: 'Déjà un compte ?',
              lien: 'Se connecter',
              onPressed: () => context.go(RouteNames.connexionPath),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(UserRole role) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const LogoFarmcash(),
          const SizedBox(height: 28),
          Text(
            'Créer un compte',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 28,
              height: 1.2,
              letterSpacing: -0.6,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Profil ${_roleLabel(role)}.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // ── Champs communs ───────────────────────────────────────────
          LabelChampInscription(
            label: 'Nom complet',
            child: TextField(
              controller: _fullNameCtrl,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              enabled: !_loading,
              decoration: const InputDecoration(hintText: 'Ex : Konan Yao'),
            ),
          ),
          AppDimens.vGap16,
          LabelChampInscription(
            label: 'Email (optionnel)',
            child: TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !_loading,
              decoration:
                  const InputDecoration(hintText: 'exemple@email.com'),
            ),
          ),
          AppDimens.vGap16,
          ChampTelephone(
            controller: _phoneCtrl,
            enabled: !_loading,
          ),

          // ── Bloc rôle ────────────────────────────────────────────────
          AppDimens.vGap24,
          Text(
            'Profil ${_roleLabel(role)}',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppDimens.vGap8,
          const Divider(
            height: 1,
            thickness: AppDimens.borderThin,
            color: AppColors.border,
          ),
          AppDimens.vGap16,
          _champsParRole(role),

          // ── CGU ──────────────────────────────────────────────────────
          AppDimens.vGap24,
          CguCheckbox(
            value: _accepteCgu,
            enabled: !_loading,
            onChanged: (v) => setState(() => _accepteCgu = v),
          ),

          if (_errorMessage != null) ...[
            AppDimens.vGap16,
            VueErreur(message: _errorMessage!),
          ],

          AppDimens.vGap24,
          CtaAuthPremium(
            label: 'Créer mon compte',
            onTap: _canSubmit ? _soumettre : null,
            loading: _loading,
            enabled: _canSubmit,
          ),
          AppDimens.vGap16,
          Center(
            child: LienTexte(
              prefixe: 'Déjà un compte ?',
              lien: 'Se connecter',
              onPressed:
                  _loading ? null : () => context.go(RouteNames.connexionPath),
            ),
          ),
          AppDimens.vGap32,
        ],
      ),
    );
  }

  Widget _champsParRole(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return ChampsInscriptionFarmer(
          regionValue: _farmerRegion,
          onRegionChanged: (v) => setState(() => _farmerRegion = v),
          superficieCtrl: _farmerSuperficieCtrl,
          expCtrl: _farmerExpCtrl,
          culturesCtrl: _farmerCulturesCtrl,
          selectedCoop: _farmerCoop,
          onCoopSelected: (coop) => setState(() => _farmerCoop = coop),
          loading: _loading,
        );
      case UserRole.buyer:
        return ChampsInscriptionBuyer(
          companyCtrl: _buyerCompanyCtrl,
          rccmCtrl: _buyerRccmCtrl,
          capaciteCtrl: _buyerCapaciteCtrl,
          zonesCtrl: _buyerZonesCtrl,
          loading: _loading,
        );
      case UserRole.cooperative:
        return ChampsInscriptionCooperative(
          nomCtrl: _coopNomCtrl,
          agrementCtrl: _coopAgrementCtrl,
          regionValue: _coopRegion,
          onRegionChanged: (v) => setState(() => _coopRegion = v),
          villeCtrl: _coopVilleCtrl,
          membresCtrl: _coopMembresCtrl,
          loading: _loading,
        );
      case UserRole.transporter:
        return ChampsInscriptionTransporter(
          permisCtrl: _transporterPermisCtrl,
          immatCtrl: _transporterImmatCtrl,
          typeVehiculeValue: _transporterTypeVehicule,
          onTypeVehiculeChanged: (v) =>
              setState(() => _transporterTypeVehicule = v),
          capaciteCtrl: _transporterCapaciteCtrl,
          marqueCtrl: _transporterMarqueCtrl,
          entrepriseCtrl: _transporterEntrepriseCtrl,
          loading: _loading,
        );
      case UserRole.exporter:
      case UserRole.admin:
      case UserRole.unknown:
        return Text(
          'Ce rôle n\'est pas disponible à l\'inscription.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        );
    }
  }
}
