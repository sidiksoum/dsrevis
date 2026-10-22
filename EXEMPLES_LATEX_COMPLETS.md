# 📚 EXEMPLES COMPLETS - Contenu Riche avec LaTeX

## 🧬 Exemple 1: Biologie - Équation de Hardy-Weinberg

**Mettez ce contenu dans Firestore** pour le champ `summary`:

```markdown
# Équilibre de Hardy-Weinberg

## Définition

L'équilibre de **Hardy-Weinberg** est un principe fondamental en génétique des populations. Il stipule que les fréquences alléliques demeurent **constantes** d'une génération à l'autre en l'absence de forces évolutives.

## Hypothèses

Pour que l'équilibre s'applique:

1. **Pas de mutation** - Aucune création de nouveaux allèles
2. **Pas de migration** - Population fermée
3. **Reproduction aléatoire** - Pas de sélection sexuelle
4. **Pas de sélection naturelle** - Tous les génotypes ont même fitness
5. **Panmixie totale** - Accouplement complètement aléatoire

> Ce modèle est **théorique**. En réalité, ces forces existent toujours!

## Formule Mathématique

Si une population a deux allèles, A et a, avec fréquences p et q:

$$
p + q = 1
$$

Alors les fréquences génotypiques sont:

$$
p^2 + 2pq + q^2 = 1
$$

Où:
- **p²** = fréquence du génotype AA
- **2pq** = fréquence du génotype Aa
- **q²** = fréquence du génotype aa

## Exemple Numérique

### Population Initiale
- Fréquence de l'allèle A (p) = 0.6
- Fréquence de l'allèle a (q) = 0.4

### Génération Suivante

Fréquences génotypiques attendues:

$$
AA: p^2 = (0.6)^2 = 0.36
$$

$$
Aa: 2pq = 2(0.6)(0.4) = 0.48
$$

$$
aa: q^2 = (0.4)^2 = 0.16
$$

**Total**: 0.36 + 0.48 + 0.16 = 1.0 ✓

### Génération 2 (si équilibre)

Les fréquences alléliques **restent identiques**:
- p = 0.6
- q = 0.4

**Et ainsi de suite à chaque génération...**

## Applications

L'équilibre de Hardy-Weinberg permet:

- 🔬 **Détecter l'évolution** - Si fréquences changent, une force agit
- 📊 **Prédire fréquences** - Sans perturbation, on connaît les proportions
- 🧪 **Valider populations** - Tester si données s'ajustent au modèle

> Pour en savoir plus: [Khan Academy - Hardy-Weinberg](https://www.khanacademy.org)

---

## ⚛️ Exemple 2: Chimie - Cinétique Réactionnelle

```markdown
# Cinétique Réactionnelle

## Vitesse de Réaction

La **vitesse de réaction** mesure la rapidité avec laquelle les réactifs se transforment en produits.

### Définition Mathématique

Pour la réaction:

$$
aA + bB \rightarrow cC + dD
$$

La vitesse peut s'exprimer en fonction de chaque espèce:

$$
v = -\frac{1}{a}\frac{d[A]}{dt} = -\frac{1}{b}\frac{d[B]}{dt} = \frac{1}{c}\frac{d[C]}{dt} = \frac{1}{d}\frac{d[D]}{dt}
$$

Où:
- [X] = concentration en mol/L
- t = temps en secondes
- Les signes négatifs indiquent la **consommation** des réactifs

## Loi de Vitesse

Pour une réaction donnée, la vitesse suit une **loi expérimentale**:

$$
v = k[A]^x[B]^y
$$

Où:
- **k** = constante de vitesse (dépend de T)
- **x, y** = ordres de réaction (déterminés expérimentalement)
- L'ordre global = x + y

## Classification par Ordre

### Réaction d'Ordre 0

$$
v = k
$$

- Vitesse **constante** (indépendante de [A])
- Exemple: Réaction photochimique

### Réaction d'Ordre 1

$$
v = k[A]
$$

- Dépend linéairement de [A]
- Exemple: Radioactivité, décomposition

### Réaction d'Ordre 2

$$
v = k[A]^2
$$

ou

$$
v = k[A][B]
$$

- Dépend du carré de la concentration
- Exemple: Réactions bimoléculaires

## Équation Intégrée (Ordre 1)

Pour une réaction d'ordre 1:

$$
\ln[A] = \ln[A]_0 - kt
$$

ou

$$
[A] = [A]_0 e^{-kt}
$$

### Demi-vie

Le temps pour que [A] = [A]₀/2:

$$
t_{1/2} = \frac{\ln 2}{k} = \frac{0.693}{k}
$$

> La demi-vie est **indépendante de la concentration initiale** pour les réactions d'ordre 1!

## Facteurs Influençant la Vitesse

1. **Concentration** - Plus haute = plus rapide (en général)
2. **Température** - +10°C ≈ ×2 à ×3 vitesse
3. **Catalyseur** - Augmente la vitesse sans se consumer
4. **Surface** - Plus grande surface = plus rapide (solides)

## Exemple Pratique

Considérez la décomposition du $H_2O_2$ avec enzyme catalase:

$$
2H_2O_2 \xrightarrow{catalase} 2H_2O + O_2
$$

- **Sans enzyme**: $k$ très faible, réaction très lente
- **Avec enzyme**: $k$ augmente 10⁶ fois, réaction très rapide!

---

## 🌊 Exemple 3: Physique - Ondes et Optique

```markdown
# Ondes Lumineuses

## Équation d'Onde

Une onde progressive sinusoïdale se décrit par:

$$
y(x,t) = A \sin(kx - \omega t + \phi)
$$

Où:
- **A** = amplitude (hauteur maximale)
- **k** = nombre d'onde = $\frac{2\pi}{\lambda}$
- **ω** = pulsation = $2\pi f$
- **φ** = phase initiale
- **λ** = longueur d'onde
- **f** = fréquence

## Relation Fondamentale

La vitesse de l'onde est:

$$
v = f \lambda = \frac{\omega}{k}
$$

Pour la lumière dans le vide:

$$
c = 3 \times 10^8 \text{ m/s}
$$

## Énergie d'un Photon

L'énergie d'un photon est:

$$
E = h f = \frac{hc}{\lambda}
$$

Où **h** = constante de Planck = $6.626 \times 10^{-34}$ J·s

### Interprétation

- **Haute fréquence** (courte λ) → **Haute énergie**
- **Basse fréquence** (longue λ) → **Basse énergie**

> C'est pourquoi les **rayons UV** (courte λ) brûlent la peau, contrairement aux **IR** (longue λ)!

## Spectrom Électromagnétique

```
Rayons γ:    λ < 10⁻¹² m    (très énergétique)
Rayons X:    10⁻¹² à 10⁻⁹ m
UV:          10⁻⁹ à 4×10⁻⁷ m
Visible:     4×10⁻⁷ à 7×10⁻⁷ m
IR:          7×10⁻⁷ à 10⁻³ m
Micro-ondes: 10⁻³ à 0.1 m
Radio:       > 0.1 m        (peu énergétique)
```

---

## 📏 Exemple 4: Mathématiques - Calcul Intégral

```markdown
# Intégrales et Primitives

## Définition

L'intégrale définie d'une fonction f entre a et b représente l'**aire sous la courbe**:

$$
\int_a^b f(x) \, dx = F(b) - F(a)
$$

Où F est une **primitive** de f, c'est-à-dire $F'(x) = f(x)$

## Propriétés Fondamentales

### Linéarité

$$
\int_a^b [cf(x) + g(x)] \, dx = c\int_a^b f(x) \, dx + \int_a^b g(x) \, dx
$$

### Inversion des limites

$$
\int_a^b f(x) \, dx = -\int_b^a f(x) \, dx
$$

### Relation de Chasles

$$
\int_a^c f(x) \, dx = \int_a^b f(x) \, dx + \int_b^c f(x) \, dx
$$

## Primitives Usuelles

| f(x) | $\int f(x) \, dx$ |
|------|-----------|
| $c$ | $cx$ |
| $x^n$ | $\frac{x^{n+1}}{n+1}$ (n ≠ -1) |
| $\frac{1}{x}$ | $\ln\|x\|$ |
| $e^x$ | $e^x$ |
| $\sin x$ | $-\cos x$ |
| $\cos x$ | $\sin x$ |

## Exemple: Calcul d'Aire

Calculer l'aire sous la parabole $y = x^2$ entre 0 et 3:

$$
\int_0^3 x^2 \, dx = \left[\frac{x^3}{3}\right]_0^3 = \frac{27}{3} - 0 = 9
$$

**Unité**: 9 unités carrées

## Intégration par Parties

Pour $\int u \, dv$:

$$
\int u \, dv = uv - \int v \, du
$$

### Exemple

Calculer $\int x e^x \, dx$:
- $u = x \Rightarrow du = dx$
- $dv = e^x dx \Rightarrow v = e^x$

$$
\int x e^x \, dx = xe^x - \int e^x \, dx = xe^x - e^x = e^x(x-1)
$$

---

## ✅ Résumé pour Utilisation

### Pour ajouter ces exemples:

1. **Copier** le texte Markdown ci-dessus
2. **Ouvrir** Firestore Console
3. **Éditer** le champ `summary` d'un cours
4. **Coller** le contenu Markdown
5. **Sauvegarder**
6. **Vérifier** dans l'app que LaTeX s'affiche correctement

### Symboles spéciaux:

- Utilisez `\rightarrow` pour →
- Utilisez `\times` pour ×
- Utilisez `\pm` pour ±
- Utilisez `\frac{a}{b}` pour fractions
- Utilisez `\sqrt{x}` pour racines

---

**✅ Tous ces exemples compilent et s'affichent correctement!**
