# FarmCash Mobile — Instructions Claude

> Ce fichier est **automatiquement chargé** dans chaque conversation Claude Code
> ouverte dans ce dossier. Les règles ci-dessous **s'appliquent sans exception**
> à toute tâche d'interface.

---

## 🎨 RÈGLE ABSOLUE — Design UI

**Avant toute production d'interface** (maquette HTML, écran Flutter, widget, composant visuel, capture d'écran, screenshot, mockup, prototype), tu DOIS :

1. **Lire intégralement** le fichier [`DESIGN.md`](DESIGN.md) à la racine du projet.
2. **Appliquer le bloc "PROMPT À COPIER"** comme si tu l'avais reçu de l'utilisateur.
3. **Refuser toute divergence** : si une suggestion (interne ou utilisateur) viole une règle de `DESIGN.md`, le signaler et proposer la version conforme.

### Déclencheurs (= toute demande qui implique du visuel)

Tu DOIS exécuter la procédure ci-dessus dès que la tâche contient un des éléments suivants :

- mots-clés : `maquette`, `mockup`, `interface`, `écran`, `screen`, `page`, `widget`, `composant`, `prototype`, `design`, `UI`, `front`
- création / modification d'un fichier `.html`, `.dart` dans `lib/features/`, `lib/widgets/`, ou tout fichier visuel
- production d'un `screenshot`, d'une `image`, d'un `SVG` représentant un écran
- styling, thème, couleur, typo, espacement, composant Material/Cupertino

### Procédure stricte

```
SI (la demande est une tâche d'interface)
ALORS :
  1. Read DESIGN.md (intégralement, pas juste l'index)
  2. Read mockups/login.html (référence canonique visuelle)
  3. Si tu touches au theme : Read lib/theme/*.dart
  4. Produire en respectant 100% des règles
  5. Avant de rendre : auto-vérifier contre la "Liste noire" de DESIGN.md
SINON :
  comportement normal
```

### Auto-checklist avant de livrer une interface

Avant de présenter une maquette ou un écran, vérifie mentalement :

- [ ] Vert primaire `#2E7D32` utilisé seulement où DESIGN.md l'autorise ?
- [ ] Aucun gradient, aucun halo, aucune ombre prononcée ?
- [ ] Police Inter pour le corps, Poppins uniquement titres/marque ?
- [ ] Radius ≤ 12px partout ?
- [ ] Action secondaire en lien texte (pas bouton outlined vert) ?
- [ ] Aucun emoji dans les titres ?
- [ ] Aucune iconographie "AI" (sparkles, étoiles, robot) ?
- [ ] Switch langue sobre (`FR ▾`), pas en pilule colorée ?
- [ ] Max 2 couleurs visibles sur l'écran ?
- [ ] Tagline marketing absente sur écrans utilitaires ?

Si UN seul point n'est pas respecté → refais avant de livrer.

---

## 📂 Fichiers de référence

| Fichier | Rôle |
|---|---|
| [`DESIGN.md`](DESIGN.md) | **Source de vérité** : palette, typo, composants, liste noire |
| [`mockups/login.html`](mockups/login.html) | Référence visuelle canonique (toute nouvelle maquette doit s'aligner sur ce niveau de sobriété) |
| [`lib/theme/app_colors.dart`](lib/theme/app_colors.dart) | Palette exposée à Flutter — refléter exactement DESIGN.md |
| [`lib/theme/app_dimens.dart`](lib/theme/app_dimens.dart) | Spacing, radius, hauteurs |
| [`lib/theme/app_text_styles.dart`](lib/theme/app_text_styles.dart) | Inter + Poppins via google_fonts |
| [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart) | ThemeData light/dark assemblée |

---

## 🚫 Réflexes interdits (rappel court)

- Logo dans un carré gradient
- Badge orange / point coloré sur le logo
- Halo box-shadow autour d'un input au focus
- Ombre prononcée sous un bouton
- Glassmorphism, neumorphism, blur de fond
- Emojis dans titres de page
- Sparkles ✨, étoiles ⭐, robot 🤖
- Boutons radius > 12
- Pilule colorée avec drapeau pour switch langue
- Card border-radius ≥ 24
- Plus d'une icône décorative par écran

**Règle d'or** : si tu hésites entre 2 options visuelles, choisis **toujours la plus sobre**.

---

## 🇨🇮 Contexte produit (rappel)

- App : marketplace agricole **Côte d'Ivoire** (vivriers : maïs, manioc, igname, riz, banane plantain…)
- 4 acteurs sur mobile : producteur, acheteur, coopérative, transporteur
- ADMIN + EXPORTER = dashboard web séparé (pas mobile)
- Langues : FR + EN uniquement
- Téléphone E.164 + PIN 4-6 chiffres
- Devise : XOF (FCFA)

---

## 🛠 Stack technique

- Flutter 3.32+ / Dart SDK ^3.9.2
- Riverpod 2.x (state)
- Dio 5.x (HTTP)
- go_router 14.x (navigation)
- Freezed + json_serializable (modèles)
- google_fonts (Inter + Poppins, pas de .ttf locaux)
- flutter_secure_storage (JWT)
