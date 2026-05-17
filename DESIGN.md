# 🎨 FarmCash — Guide de design (à donner à Claude)

> **Comment l'utiliser** : colle le bloc "PROMPT À COPIER" ci‑dessous en début de chaque
> demande de maquette / page Flutter. Les sections suivantes servent de référence
> détaillée si on doit creuser un point.

---

## ⚡ PROMPT À COPIER

```
Tu vas dessiner une interface pour FarmCash (marketplace agricole CI).

Style global : SOBRE, CLASSIQUE, ATTRAYANT.
Esprit : app fintech / banque mobile (Stripe, Revolut, banques CI modernes).
PAS de "look AI", PAS de marketing visuel, PAS de fantaisie.

À FAIRE :
- Fond blanc, beaucoup d'air, peu d'éléments par écran
- Vert primaire #2E7D32 utilisé AVEC PARCIMONIE (focus, bouton primaire, liens)
- Champs blancs, bordure 1px #D1D5DB → bordure verte au focus (sans halo)
- Boutons plats radius 10px, sans ombre
- Inter pour le corps (14-15px), Poppins pour titres et marque uniquement
- Labels au-dessus des champs (pas en floating)
- Logo flat : petite icône feuille + texte "FarmCash" sur une ligne
- Action secondaire en LIEN TEXTE (ex: "Pas encore de compte ? Créer un compte"),
  PAS en bouton outlined
- 1 phrase courte d'instruction maximum, jamais de copy marketing
- Switch langue discret "FR ▾", pas en pilule colorée

À ÉVITER :
- Gradient sur le logo
- Badge coloré (point orange, étoile) sur le logo
- Halos colorés autour des inputs au focus
- Ombres prononcées sous les boutons / cards
- Emojis dans les titres (👋 🌱 ✨ etc.)
- Iconographie "AI" (sparkles, étoiles, ondes, robot)
- Pilule colorée pour le switch langue
- Boutons outlined verts en action secondaire
- Sous-titres / taglines marketing sur écrans utilitaires
- Radius > 12px (12 max, sinon trop ornemental)
- Plus d'une icône décorative par écran (chaque icône doit être fonctionnelle)
- Plus de 2 couleurs visibles sur un écran simple

Police : Inter (corps), Poppins (titres/marque uniquement).
Radius standard : 10px (inputs, boutons), 12px max (cards).
Hauteur composants : 50px (inputs, boutons), 56px (rares cas premium).

Livre la maquette en HTML+CSS dans le frame téléphone 390×844
(comme la maquette login déjà validée dans mockups/login.html).
```

---

## 🎯 Philosophie

| ✅ Direction | ❌ À éviter |
|---|---|
| Fintech sobre, banque mobile | "App AI" avec sparkles |
| Stripe, Revolut, Wave, banques CI | Dribbble glassy / neumorphism |
| Le vert se mérite — il signale | Le vert décore partout |
| Less is more | Marketing visuel chargé |
| Iconographie fonctionnelle | Iconographie décorative |

---

## 🎨 Palette stricte

```
Primaire        #2E7D32   bouton primaire, lien, focus, statut actif
Primaire hover  #256528   :hover et :pressed
Texte           #111827   titres, labels, valeurs
Texte secondaire#6B7280   sous-titres, helper, switch langue
Texte subtil    #9CA3AF   placeholder, légal, captions
Bordure         #E5E7EB   séparateurs, divider
Bordure forte   #D1D5DB   inputs au repos
Fond doux       #F9FAFB   zones secondaires (rare)
Erreur          #C62828   validation, alert destructive
Succès          #1B7F3A   ≠ primaire, pour distinguer "vert marque" et "vert OK"
```

**Règle d'or** : sur un écran simple, max **2 couleurs visibles** (vert + un gris).
Ajouter une 3ᵉ couleur uniquement si c'est un statut ou une alerte fonctionnelle.

---

## 📝 Typographie

| Usage | Police | Taille | Weight | Letter-spacing |
|---|---|---|---|---|
| Titre page (H1) | Poppins | 24–28px | 700 | −0.5px |
| Titre section (H2) | Poppins | 18–20px | 600 | −0.3px |
| Marque "FarmCash" | Poppins | 18–20px | 700 | −0.3px |
| Corps | Inter | 14–15px | 400 | 0 |
| Label de champ | Inter | 13px | 500 | 0 |
| Bouton | Inter | 15px | 600 | 0 |
| Lien | Inter | 13–14px | 500–600 | 0 |
| Légal / caption | Inter | 11–12px | 400 | 0 |

---

## 🧱 Composants standards

### Input
```
hauteur          50px
radius           10px
background       #FFFFFF
border           1px solid #D1D5DB
border (focus)   1px solid #2E7D32   ← juste la bordure change, PAS de halo
padding          0 14px
label            placé au-dessus, 13px / 500
placeholder      #9CA3AF, 400
```

### Bouton primaire
```
hauteur          50px
radius           10px
background       #2E7D32 (#256528 au hover)
color            #FFFFFF
font             Inter 15px / 600
ombre            NONE
```

### Bouton secondaire / lien
- **Préférence** : lien texte vert dans une ligne (`Pas de compte ? Créer un compte`)
- Si vraiment un bouton : bordure 1px #D1D5DB, texte vert, fond blanc, **pas** de bordure verte

### Card
```
radius           12px (max)
background       #FFFFFF
border           1px solid #E5E7EB   ← bordure plutôt qu'ombre
ombre            0 1px 2px rgba(0,0,0,0.04) MAX
padding          16px ou 20px
```

### Switch langue
- Format : `FR ▾` en gris secondaire, sans bordure
- Pas de drapeau, pas de pilule colorée
- Position : coin haut droit, discret

---

## 📐 Espacements (8pt grid)

```
4   gap minimal (icône + texte)
8   espacement compact (intra-composant)
12  espacement moyen (label → input)
16  espacement standard (entre champs)
24  espacement large (entre blocs)
32  espacement très large (entre sections)
```

**Padding page** : 24–32px horizontal.

---

## 🚫 Liste noire (à ne JAMAIS produire)

- Logo dans un carré coloré avec gradient
- Badge/dot d'accent (orange, rouge) sur le logo
- Halo coloré (box-shadow) autour d'un input au focus
- Ombre portée prononcée sur un bouton (>2px de blur)
- Glassmorphism, neumorphism, blur de fond
- Emojis dans les titres de page
- Sparkles ✨, étoiles ⭐, robot 🤖, magic wand 🪄
- Tagline "votre assistant intelligent" ou similaire
- Boutons radius 16+ (style "candy")
- Pilule colorée avec drapeau pour switch langue
- Card avec border-radius 24+
- Dégradé sur fond de page

---

## ✅ Référence canonique

La maquette `mockups/login.html` (dernière version, après ajustement)
est la **source de vérité visuelle**. Toute nouvelle maquette doit
s'aligner sur ce niveau de sobriété.

Si tu hésites entre 2 options : **prends toujours la plus sobre**.
