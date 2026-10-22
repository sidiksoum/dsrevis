# 📖 Guide Administrateur: Contenu Riche pour les Cours

## 🎯 Résumé

À partir de maintenant, l'app **D.S REVIS** supporte l'affichage de contenu **riche et formaté** directement depuis Firebase:

- ✅ **Texte formaté**: gras, italique, barré
- ✅ **Titres et sous-titres** (H1 à H6)
- ✅ **Listes** (à puces et numérotées)
- ✅ **Citations** formatées
- ✅ **Formules mathématiques** (LaTeX)
- ✅ **Liens hypertexte** cliquables
- ✅ **Code** (inline et blocs)
- ✅ **Tableaux**

---

## 🚀 Démarrage Rapide

### Format Markdown de base

```markdown
# Mon Titre Principal
## Mon Sous-titre
Texte normal avec **gras**, *italique* et ***gras+italique***.

- Liste 1
- Liste 2

> Citation importante

[Lien](https://exemple.com)

Formule: $E = mc^2$
```

---

## 📐 Formules Mathématiques (LaTeX)

### Inline (dans le texte)

La concentration est: `$70-100 \text{ mg/dL}$`

**Résultat**: La concentration est: 70-100 mg/dL

### Block (multi-ligne)

```markdown
$$
f(x) = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$
```

### Formules utiles pour les sciences

| Besoin | Syntaxe | Exemple |
|--------|---------|---------|
| Fraction | `\frac{a}{b}` | $\frac{a}{b}$ |
| Racine | `\sqrt{x}` | $\sqrt{x}$ |
| Exposant | `x^2` | $x^2$ |
| Indice | `x_i` | $x_i$ |
| Somme | `\sum_{i=1}^{n}` | $\sum_{i=1}^{n}$ |
| Intégrale | `\int_{a}^{b}` | $\int_{a}^{b}$ |
| Grec | `\alpha \beta \gamma` | $\alpha \beta \gamma$ |

---

## 📝 Exemples Complets

### Exemple 1: Cours de Chimie

```markdown
# Équation de Henderson-Hasselbalch

## Définition

L'équation de **Henderson-Hasselbalch** permet de calculer le pH d'une solution tampon:

$$
pH = pKa + \log\left(\frac{[A^-]}{[HA]}\right)
$$

## Variables

- $pH$ : potentiel hydrogène (0-14)
- $pKa$ : constante d'acidité du couple acide-base
- $[A^-]$ : concentration de la base conjuguée (mol/L)
- $[HA]$ : concentration de l'acide faible (mol/L)

## Exemple de calcul

Soit un système avec:
- $pKa = 4.75$
- $[A^-] = 0.1$ M
- $[HA] = 0.05$ M

$$
pH = 4.75 + \log\left(\frac{0.1}{0.05}\right) = 4.75 + \log(2) = 4.75 + 0.30 = 5.05
$$

> L'équation est valide pour les solutions tampons de pH proche du pKa.

[Plus d'infos](https://fr.wikipedia.org/wiki/Équation_de_Henderson-Hasselbalch)
```

### Exemple 2: Cours de Biologie

```markdown
# Cycle Cellulaire

## Phases principales

Le cycle cellulaire comprend quatre phases:

1. **Phase G1**: Croissance cellulaire et préparation
2. **Phase S**: Réplication de l'ADN
   - Double le volume de l'ADN
   - Duplication des centrosomes
3. **Phase G2**: Préparation pour la mitose
4. **Phase M**: Mitose et cytokinèse

## Durée typique

| Phase | Durée |
|-------|-------|
| G1 | 8-12 heures |
| S | 6-8 heures |
| G2 | 3-4 heures |
| M | 1-2 heures |

> La durée varie selon le type cellulaire et les conditions!

## Points clés

- Les points de contrôle vérifient la bonne progression
- Les erreurs déclenchent l'apoptose
- La cycline contrôle les transitions de phase

Pour en savoir plus: [Khan Academy](https://www.khanacademy.org)
```

### Exemple 3: Cours de Physiologie

```markdown
# Régulation du pH Sanguin

## Système tampon bicarbonate

Le pH sanguin est régulé par:

$$
H^+ + HCO_3^- \rightleftharpoons H_2CO_3 \rightleftharpoons H_2O + CO_2
$$

## Valeurs normales

- **pH**: $7.35-7.45$
- **$HCO_3^-$**: $22-26$ mEq/L
- **$pCO_2$**: $35-45$ mmHg

## Mécanismes de compensation

### Acidose respiratoire
- Cause: $pCO_2 > 45$ mmHg
- Compensation: Augmenter la ventilation
- Effet: Éliminer plus de $CO_2$

### Alcalose métabolique
- Cause: $HCO_3^- > 26$ mEq/L
- Compensation: Diminuer la ventilation
- Effet: Retenir le $CO_2$

> L'équilibre acido-basique est critique pour la survie!

[Ressource médicale](https://example.com)
```

---

## ⚠️ Points Importants

### ✅ À faire

- ✓ Utiliser `# ` (espace) avant les titres
- ✓ Laisser une ligne vide entre sections
- ✓ Tester vos formules LaTeX avant publication
- ✓ Vérifier que les liens commencent par `https://`
- ✓ Utiliser `**texte**` pour le gras (pas `_texte_`)

### ❌ À éviter

- ✗ Oublier les espaces: `#Titre` ❌ (utiliser `# Titre` ✓)
- ✗ Formules incomplètes: `$x^2` ❌ (utiliser `$x^2$` ✓)
- ✗ Liens sans protocole: `[lien](google.com)` ❌ (utiliser `[lien](https://google.com)` ✓)
- ✗ Formules block sans ligne vide:
  ```
  Texte
  $$formule$$  ❌ (ajouter ligne vide)
  Autre texte
  ```

---

## 🧪 Tester Votre Contenu

### Méthode 1: Utiliser l'écran de prévisualisation

L'app inclut une page de prévisualisation (admin/content_preview_screen) où vous pouvez:
1. Écrire votre Markdown
2. Voir le rendu en temps réel
3. Copier pour Firestore

### Méthode 2: Tester localement

1. Modifiez le texte d'exemple dans Firebase
2. Lancez l'app
3. Naviguez vers un cours
4. Vérifiez l'affichage

---

## 📊 Référence LaTeX Complète

### Symboles courants

```
Alphabets: \alpha \beta \gamma \delta \epsilon
Symb math: \pm \times \div \infty \approx \neq
Logique:   \forall \exists \in \notin
Flèches:   \rightarrow \leftarrow \leftrightarrow
```

### Structures

```
Fractions:       \frac{num}{den}
Racines:         \sqrt{x} \sqrt[n]{x}
Exposants:       x^{2} x^{n}
Indices:         x_{i} a_{ij}
Fractions imbriquées: \frac{a}{\frac{b}{c}}
```

### Delimiters

```
Parenthèses:    \left( ... \right)
Crochets:       \left[ ... \right]
Accolades:      \left\{ ... \right\}
Valeur absolue: \left| x \right|
```

---

## 📞 Support

Si vous avez des questions sur la syntaxe ou des problèmes d'affichage, consultez:
- Le fichier `GUIDE_FORMAT_CONTENU.dart` dans le projet
- La page de prévisualisation (ContentPreviewScreen)
- La documentation Markdown: https://www.markdownguide.org/
- La documentation LaTeX: https://www.latex-project.org/

---

**Version**: 1.0  
**Dernière mise à jour**: 2026-07-10
