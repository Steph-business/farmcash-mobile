import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../widgets/authentification/champ_telephone.dart';
import '../../widgets/authentification/selecteur_coop.dart';
import '../../widgets/authentification/selecteur_langue.dart';
import '../../widgets/communs/bouton_principal.dart';
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

  static const _regions = <String>[
    'Centre',
    'Nord',
    'Sud',
    'Est',
    'Ouest',
    'Lagunes',
    'Vallée du Bandama',
    'Montagnes',
    'Lacs',
    'Zanzan',
    'Bas-Sassandra',
    'Comoé',
    'Sassandra-Marahoué',
    'Savanes',
    'Woroba',
    'Yamoussoukro',
    'Abidjan',
  ];

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

  /// Types de véhicule du DTO backend `ProfilTransporteurDto.TypeVehicule`.
  static const _typesVehicule = <_TypeVehiculeOption>[
    _TypeVehiculeOption(apiValue: 'MOTO', label: 'Moto'),
    _TypeVehiculeOption(apiValue: 'TRICYCLE', label: 'Tricycle'),
    _TypeVehiculeOption(apiValue: 'PICKUP', label: 'Pickup'),
    _TypeVehiculeOption(apiValue: 'FOURGON', label: 'Fourgon'),
    _TypeVehiculeOption(apiValue: 'CAMION', label: 'Camion'),
    _TypeVehiculeOption(apiValue: 'CAMION_FRIGO', label: 'Camion frigorifique'),
    _TypeVehiculeOption(apiValue: 'REMORQUE', label: 'Remorque'),
  ];

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppDimens.iconL),
          onPressed: () => context.go(RouteNames.choixRolePath),
        ),
      ),
      body: SafeArea(
        top: false,
        child: role == null ? _buildEmptyState() : _buildForm(role),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDimens.vGap16,
          const Align(
            alignment: Alignment.centerRight,
            child: SelecteurLangue(),
          ),
          AppDimens.vGap24,
          const _Logo(),
          AppDimens.vGap32,
          Text('Créer un compte', style: AppTextStyles.displaySmall),
          AppDimens.vGap8,
          Text(
            'Choisis d\'abord ton rôle pour continuer.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppDimens.vGap24,
          BoutonPrincipal(
            label: 'Choisir un rôle',
            onPressed: () => context.go(RouteNames.choixRolePath),
          ),
          AppDimens.vGap24,
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
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDimens.vGap8,
          const Align(
            alignment: Alignment.centerRight,
            child: SelecteurLangue(),
          ),
          AppDimens.vGap16,
          const _Logo(),
          AppDimens.vGap32,
          Text('Créer un compte', style: AppTextStyles.displaySmall),
          AppDimens.vGap8,
          Text(
            'Profil ${_roleLabel(role)}.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppDimens.vGap24,

          // ── Champs communs ───────────────────────────────────────────
          _LabelChamp(
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
          _LabelChamp(
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
          ..._champsParRole(role),

          // ── CGU ──────────────────────────────────────────────────────
          AppDimens.vGap24,
          _CguCheckbox(
            value: _accepteCgu,
            enabled: !_loading,
            onChanged: (v) => setState(() => _accepteCgu = v),
          ),

          if (_errorMessage != null) ...[
            AppDimens.vGap16,
            VueErreur(message: _errorMessage!),
          ],

          AppDimens.vGap24,
          BoutonPrincipal(
            label: 'Créer mon compte',
            onPressed: _canSubmit ? _soumettre : null,
            isLoading: _loading,
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

  List<Widget> _champsParRole(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return [
          _LabelChamp(
            label: 'Région',
            child: _dropdownRegions(
              value: _farmerRegion,
              onChanged: (v) => setState(() => _farmerRegion = v),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Superficie cultivée (hectares)',
            child: TextField(
              controller: _farmerSuperficieCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: _decimalFormatters,
              enabled: !_loading,
              decoration: const InputDecoration(hintText: 'Ex : 5'),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Années d\'expérience (optionnel)',
            child: TextField(
              controller: _farmerExpCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !_loading,
              decoration: const InputDecoration(hintText: 'Ex : 10'),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Cultures principales (optionnel)',
            child: TextField(
              controller: _farmerCulturesCtrl,
              enabled: !_loading,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ex : Maïs, manioc, riz',
              ),
            ),
          ),
          AppDimens.vGap16,
          SelecteurCoop(
            selectedCoopId: _farmerCoop?.id,
            enabled: !_loading,
            onSelected: (coop) => setState(() => _farmerCoop = coop),
          ),
        ];
      case UserRole.buyer:
        return [
          _LabelChamp(
            label: 'Nom de l\'entreprise (optionnel)',
            child: TextField(
              controller: _buyerCompanyCtrl,
              textCapitalization: TextCapitalization.words,
              enabled: !_loading,
              decoration: const InputDecoration(hintText: 'Ex : Agro SARL'),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Numéro RCCM (optionnel)',
            child: TextField(
              controller: _buyerRccmCtrl,
              enabled: !_loading,
              decoration:
                  const InputDecoration(hintText: 'Ex : CI-ABJ-2024-B-1234'),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Capacité d\'achat (kg/mois) (optionnel)',
            child: TextField(
              controller: _buyerCapaciteCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: _decimalFormatters,
              enabled: !_loading,
              decoration: const InputDecoration(hintText: 'Ex : 2000'),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Zones d\'achat (optionnel)',
            child: TextField(
              controller: _buyerZonesCtrl,
              enabled: !_loading,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ex : Abidjan, Bouaké',
              ),
            ),
          ),
        ];
      case UserRole.cooperative:
        return [
          _LabelChamp(
            label: 'Nom de la coopérative',
            child: TextField(
              controller: _coopNomCtrl,
              textCapitalization: TextCapitalization.words,
              enabled: !_loading,
              decoration:
                  const InputDecoration(hintText: 'Ex : Coop Yamoussoukro'),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Numéro d\'agrément',
            child: TextField(
              controller: _coopAgrementCtrl,
              enabled: !_loading,
              decoration:
                  const InputDecoration(hintText: 'Ex : MINADER-2023-001'),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Région',
            child: _dropdownRegions(
              value: _coopRegion,
              onChanged: (v) => setState(() => _coopRegion = v),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Ville',
            child: TextField(
              controller: _coopVilleCtrl,
              textCapitalization: TextCapitalization.words,
              enabled: !_loading,
              decoration:
                  const InputDecoration(hintText: 'Ex : Yamoussoukro'),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Nombre de membres (optionnel)',
            child: TextField(
              controller: _coopMembresCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !_loading,
              decoration: const InputDecoration(hintText: 'Ex : 150'),
            ),
          ),
        ];
      case UserRole.transporter:
        return [
          _LabelChamp(
            label: 'Numéro de permis',
            child: TextField(
              controller: _transporterPermisCtrl,
              enabled: !_loading,
              decoration: const InputDecoration(
                hintText: 'Ex : CI-PERM-2020-456789',
              ),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Immatriculation',
            child: TextField(
              controller: _transporterImmatCtrl,
              enabled: !_loading,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'Ex : 4567 AB 01'),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Type de véhicule',
            child: DropdownButtonFormField<String>(
              initialValue: _transporterTypeVehicule,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
              hint: Text(
                'Sélectionner un type',
                style: AppTextStyles.hint,
              ),
              items: _typesVehicule
                  .map(
                    (t) => DropdownMenuItem<String>(
                      value: t.apiValue,
                      child: Text(t.label, style: AppTextStyles.bodyMedium),
                    ),
                  )
                  .toList(),
              onChanged: _loading
                  ? null
                  : (v) => setState(() => _transporterTypeVehicule = v),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Capacité maximale (kg)',
            child: TextField(
              controller: _transporterCapaciteCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: _decimalFormatters,
              enabled: !_loading,
              decoration: const InputDecoration(hintText: 'Ex : 3000'),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Marque et modèle (optionnel)',
            child: TextField(
              controller: _transporterMarqueCtrl,
              enabled: !_loading,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Ex : Isuzu N-Series 2020',
              ),
            ),
          ),
          AppDimens.vGap16,
          _LabelChamp(
            label: 'Nom d\'entreprise (optionnel)',
            child: TextField(
              controller: _transporterEntrepriseCtrl,
              enabled: !_loading,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Ex : Transport Yao Express',
              ),
            ),
          ),
        ];
      case UserRole.exporter:
      case UserRole.admin:
      case UserRole.unknown:
        return [
          Text(
            'Ce rôle n\'est pas disponible à l\'inscription.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ];
    }
  }

  Widget _dropdownRegions({
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.textSecondary,
      ),
      hint: Text(
        'Sélectionner une région',
        style: AppTextStyles.hint,
      ),
      items: _regions
          .map(
            (r) => DropdownMenuItem<String>(
              value: r,
              child: Text(r, style: AppTextStyles.bodyMedium),
            ),
          )
          .toList(),
      onChanged: _loading ? null : onChanged,
    );
  }

  static final List<TextInputFormatter> _decimalFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
  ];
}

/// Option de la liste déroulante des types de véhicule.
/// `apiValue` est la valeur exacte attendue par l'enum backend
/// `ProfilTransporteurDto.TypeVehicule`.
class _TypeVehiculeOption {
  const _TypeVehiculeOption({required this.apiValue, required this.label});

  final String apiValue;
  final String label;
}

/// Wrapper "label au-dessus + champ" — uniformise la composition des inputs.
class _LabelChamp extends StatelessWidget {
  const _LabelChamp({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        AppDimens.vGap8,
        child,
      ],
    );
  }
}

class _CguCheckbox extends StatelessWidget {
  const _CguCheckbox({
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(AppDimens.radiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Text(
                'J\'accepte les Conditions d\'utilisation.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.eco_outlined, size: 28, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          'FarmCash',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
