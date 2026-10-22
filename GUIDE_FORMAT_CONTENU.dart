/// GUIDE POUR LES ADMINISTRATEURS: FORMAT DU CONTENU DES COURS
/// 
/// Ce guide explique comment formater les résumés de cours dans Firebase
/// pour que l'app les affiche correctement avec Markdown, LaTeX et liens.
///
/// =============================================================================
/// 1. TEXTE DE BASE
/// =============================================================================
///
/// - Texte normal : Écrivez simplement votre texte
/// - Ligne vide : Crée un paragraphe
/// - **Gras** : Utilisez des astérisques doubles
/// - *Italique* : Utilisez des astérisques simples
/// - ***Gras ET italique*** : Trois astérisques
/// - ~~Barré~~ : Double tilde
///
/// Exemple:
/// ```
/// Le système immunitaire est **très important** pour la *santé*.
/// C'est une notion ***fondamentale*** en médecine.
/// ```
///
/// =============================================================================
/// 2. TITRES ET SOUS-TITRES
/// =============================================================================
///
/// # Titre Principal (H1)
/// ## Sous-titre (H2)
/// ### Sous-sous-titre (H3)
/// #### H4
/// ##### H5
/// ###### H6
///
/// Exemple:
/// ```
/// # Anatomie du Cœur
/// ## Structure générale
/// ### Les 4 cavités
/// ```
///
/// =============================================================================
/// 3. LISTES À PUCES
/// =============================================================================
///
/// - Item 1
/// - Item 2
/// - Item 3
///   - Sous-item 3.1
///   - Sous-item 3.2
///
/// Exemple:
/// ```
/// ## Fonctions du cœur:
/// - Pompage du sang
/// - Distribution de l'oxygène
/// - Circulation sanguine
///   - Circulation systémique
///   - Circulation pulmonaire
/// ```
///
/// =============================================================================
/// 4. LISTES NUMÉROTÉES
/// =============================================================================
///
/// 1. Premier item
/// 2. Deuxième item
/// 3. Troisième item
///
/// Exemple:
/// ```
/// ## Étapes de la respiration:
/// 1. Inspiration (dilatation)
/// 2. Échange gazeux
/// 3. Expiration (contraction)
/// ```
///
/// =============================================================================
/// 5. CITATIONS
/// =============================================================================
///
/// > Ceci est une citation importante
/// > Elle peut s'étendre sur plusieurs lignes
///
/// > Chaque ligne commençant par > est une citation
///
/// Exemple:
/// ```
/// ## Principe Fondamental:
/// > "L'équilibre homéostatique est essentiel à la survie de l'organisme"
/// > - Principe physiologique classique
/// ```
///
/// =============================================================================
/// 6. FORMULES MATHÉMATIQUES ET SCIENTIFIQUES (LaTeX)
/// =============================================================================
///
/// Formule inline (dans le texte): $E = mc^2$
///
/// Formule block (multi-ligne):
/// $$
/// f(x) = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
/// $$
///
/// La formule block doit être sur ses propres lignes.
///
/// Exemples courants:
/// - Fraction: $\frac{a}{b}$
/// - Racine: $\sqrt{x}$
/// - Somme: $\sum_{i=1}^{n} x_i$
/// - Intégrale: $\int_{0}^{1} x^2 dx$
/// - Exposant: $x^2$
/// - Indice: $x_i$
/// - Symboles grecs: $\alpha, \beta, \gamma, \Delta$
///
/// Exemple complet:
/// ```
/// # Équation de Henderson-Hasselbalch
///
/// La régulation du pH sanguin est donnée par:
///
/// $$
/// pH = pKa + \log\left(\frac{[A^-]}{[HA]}\right)
/// $$
///
/// Où:
/// - $pH$ : potentiel hydrogène
/// - $pKa$ : constante d'acidité
/// - $[A^-]$ : concentration de la base conjuguée
/// - $[HA]$ : concentration de l'acide faible
/// ```
///
/// =============================================================================
/// 7. LIENS HYPERTEXTE
/// =============================================================================
///
/// [Texte du lien](https://exemple.com)
///
/// Exemple:
/// ```
/// Pour plus d'informations, consultez [Wikipedia sur le cœur](https://fr.wikipedia.org/wiki/Coeur)
/// 
/// Ressources utiles:
/// - [Khan Academy Biologie](https://www.khanacademy.org/science/biology)
/// - [CDC Santé](https://www.cdc.gov)
/// ```
///
/// =============================================================================
/// 8. CODE (inline ou blocs)
/// =============================================================================
///
/// Code inline: `const x = 5;`
///
/// Bloc de code:
/// ```
/// function exemple() {
///   console.log("Voici du code");
/// }
/// ```
///
/// =============================================================================
/// 9. TABLEAUX
/// =============================================================================
///
/// | Colonne 1 | Colonne 2 | Colonne 3 |
/// |-----------|-----------|-----------|
/// | Cellule 1 | Cellule 2 | Cellule 3 |
/// | Cellule 4 | Cellule 5 | Cellule 6 |
///
/// Exemple complet:
/// ```
/// ## Comparaison des types de sang
///
/// | Groupe | Antigènes | Anticorps |
/// |--------|-----------|-----------|
/// | O      | Aucun     | Anti-A/B  |
/// | A      | A         | Anti-B    |
/// | B      | B         | Anti-A    |
/// | AB     | A et B    | Aucun     |
/// ```
///
/// =============================================================================
/// 10. COMBINAISONS COMPLEXES (EXEMPLE COMPLET)
/// =============================================================================
///
/// # Biochimie du Glucose
///
/// ## Définition
/// Le **glucose** est un sucre simple crucial pour l'énergie cellulaire.
///
/// ### Structure chimique
///
/// La formule brute du glucose est:
///
/// $$
/// C_6H_{12}O_6
/// $$
///
/// ## Métabolisme
///
/// Le glucose est métabolisé via plusieurs voies:
///
/// 1. **Glycolyse** - Décomposition du glucose en pyruvate
///    - Libère de l'énergie (2 ATP)
///    - Produit du NADH
/// 
/// 2. **Cycle de Krebs** - Oxydation complète
/// 
/// 3. **Glycogenèse** - Stockage en glycogène
///
/// > Le glucose est le substrat énergétique préféré du cerveau!
///
/// ### Concentration normale
///
/// - À jeun: $70-100 \text{ mg/dL}$
/// - Après les repas: $< 140 \text{ mg/dL}$
///
/// Pour plus de détails, voir [Biologie cellulaire](https://exemple.com/biologie)
///
/// =============================================================================
/// 11. ASTUCES PRATIQUES
/// =============================================================================
///
/// ✓ Utilisez des espaces vides pour séparer les sections
/// ✓ Les titres aident la navigation mentale
/// ✓ Les listes rendent le contenu scannable
/// ✓ Les citations mettent en avant les points importants
/// ✓ Les formules LaTeX doivent être exactes (testez-les!)
/// ✓ Les liens doivent être valides et commencer par http:// ou https://
///
/// =============================================================================
/// 12. ERREURS À ÉVITER
/// =============================================================================
///
/// ✗ Oublier les astérisques: Ne mettez pas gras au lieu de **gras**
/// ✗ Formules LaTeX mal fermées: $x^2 au lieu de $x^2$
/// ✗ Liens incomplets: [texte](site.com) au lieu de [texte](https://site.com)
/// ✗ Titres sans espaces: #Titre au lieu de # Titre
/// ✗ Mélanger les listes: Passez une ligne entre liste et paragraphe
///
/// =============================================================================

// Cette page de documentation est incluse pour référence administrateur
// Elle ne s'affiche pas dans l'app mais guide la création du contenu
