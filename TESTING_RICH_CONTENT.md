# 🧪 Guide de Test - Contenu Riche

## ✅ Étapes pour Tester la Nouvelle Fonctionnalité

### 1️⃣ Vérifier la Compilation
```bash
cd c:\Users\HP\ProjetFlutter\dsrevis
flutter pub get
flutter analyze lib/
# Résultat attendu: No errors (seulement des infos/warnings pré-existants)
```

### 2️⃣ Tester Localement avec la Page de Prévisualisation

Si vous avez accès au dashboard admin:

1. Naviguez vers `ContentPreviewScreen`
2. Vous verrez deux zones:
   - **Zone d'édition** (gauche): Écrire du Markdown
   - **Aperçu** (droite): Voir le rendu en temps réel

3. Testez différents formats:
```markdown
# Titre principal

Texte avec **gras**, *italique* et ***combinaison***.

## Sous-titre

- Item 1
- Item 2

> Citation importante

[Lien vers Google](https://google.com)
```

### 3️⃣ Tester avec Firestore

#### 3.1 - Créer un cours de test
1. Ouvrez Firestore Console: https://console.firebase.google.com
2. Naviguez vers votre database
3. Créez/modifiez un cours avec le format:

```
{
  "title": "Cours Test Markdown",
  "category": "Sciences",
  "filiere": "Licence 1",
  "summary": "# Titre du Cours\n\nCe cours contient du **gras**, de l'*italique* et des liens [vers Google](https://google.com).",
  "driveLink": "https://drive.google.com/...",
  "premiumOnly": false
}
```

**Important**: Utilisez `\n` pour les retours à la ligne dans Firestore

#### 3.2 - Vérifier dans l'app
1. Lancez l'app
2. Naviguez vers "Mes Cours"
3. Cliquez sur le cours test
4. Le résumé s'affiche avec formatage correct:
   - Titre en grand
   - Texte en gras/italique appliqué
   - Lien cliquable

### 4️⃣ Test de Chaîne Complète (End-to-End)

#### Exemple 1: Cours de Chimie
```json
{
  "summary": "# Équation de Réaction\n\nLa réaction chimique s'écrit:\n\n**A + B → C + D**\n\nOù:\n- **A** et **B** sont les réactifs\n- **C** et **D** sont les produits\n\n> La conservation de la masse s'applique toujours!\n\nPour plus de détails: [Khan Academy](https://www.khanacademy.org)"
}
```

#### Exemple 2: Cours de Biologie
```json
{
  "summary": "# Cycle Cellulaire\n\n## Phases\n\n1. **G1** - Croissance\n2. **S** - Réplication d'ADN\n3. **G2** - Préparation\n4. **M** - Mitose\n\n### Points de Contrôle\n\n> Les points de contrôle vérifient l'intégrité cellulaire\n\n- Contrôle G1/S\n- Contrôle G2/M\n- Point de contrôle de la métaphase"
}
```

### 5️⃣ Tester les Liens

1. Dans un cours, ajoutez un lien Markdown: `[Test](https://google.com)`
2. En consultant le cours dans l'app, le lien apparaît en **bleu souligné**
3. Cliquez dessus → doit ouvrir le navigateur (ou gérer selon le lien)

### 6️⃣ Tester les Cas Limites

#### Citation avec plusieurs lignes
```markdown
> Ceci est une citation
> qui s'étend sur plusieurs lignes
> et elle doit afficher correctement
```

#### Code Block
```markdown
Voici du code:

\`\`\`dart
void main() {
  print("Hello");
}
\`\`\`
```

#### Tableau
```markdown
| Groupe | Antigènes |
|--------|-----------|
| O      | Aucun     |
| A      | A         |
```

---

## 🎯 Résultats Attendus

### ✅ Affichage Correct
- [x] Le gras s'affiche en gras
- [x] L'italique s'affiche en italique
- [x] Les titres sont grands et lisibles
- [x] Les listes sont indentées correctement
- [x] Les citations ont un style spécial (bordure gauche)
- [x] Les liens sont bleus et cliquables
- [x] Pas de caractères d'échappement visibles

### ✅ Interaction
- [x] Les liens sont cliquables
- [x] Le texte est sélectionnable (copier/coller)
- [x] Le contenu scroll si trop long

### ✅ Performance
- [x] L'app ne lag pas
- [x] Le rendu est instantané
- [x] Navigation fluide

---

## 🐛 Troubleshooting

### Problem: Texte brut au lieu de formaté

**Solution**: Vérifiez que le contenu dans Firestore est exactement en format Markdown:
- Utilisez `**texte**` pour le gras (pas `__texte__`)
- Utilisez `# Titre` avec un espace après le #
- Utilisez `\n` pour les retours à la ligne

### Problem: Les liens ne s'ouvrent pas

**Solution**: Assurez-vous que:
- Le lien commence par `https://` ou `http://`
- Le format est `[texte](url)` et non `[texte] (url)`
- Vous avez un accès internet

### Problem: Le widget n'affiche rien

**Solution**: Vérifiez que:
- Le widget est importé: `import 'package:dsrevis/features/shared/presentation/widgets/rich_content_display.dart';`
- Le `content` n'est pas vide ou null
- Flutter compile sans erreur: `flutter analyze lib/`

### Problem: Caractères spéciaux manquants

**Solution**: Dans Firestore:
- Utilisez l'éditeur Firestore directement (pas Excel/Google Sheets)
- Évitez de copier-coller depuis Word (formatage caché)
- Testez d'abord avec la page `ContentPreviewScreen`

---

## 📊 Checklist de Validation

- [ ] Code compile sans erreurs
- [ ] CourseDetailsScreen affiche le widget RichContentDisplay
- [ ] Les cours gratuits affichent du contenu formaté
- [ ] Les liens sont cliquables
- [ ] Les citations affichent avec le style spécial
- [ ] Les listes affichent correctement
- [ ] Pas de crash lors du scroll
- [ ] Performance acceptable (pas de lag)
- [ ] Contenu adaptatif (responsif)
- [ ] ContentPreviewScreen est fonctionnel

---

## 🔄 Prochaines Étapes

1. **Test Production**: Déployer l'APK et tester sur des appareils réels
2. **Feedback Admin**: Demander aux admins de tester la saisie de contenu
3. **Optimisation**: Si nécessaire, optimiser les performances
4. **LaTeX Integration**: Ajouter support LaTeX si besoin

---

## 📞 Support

Si vous avez des questions:
1. Consultez `ADMIN_GUIDE_CONTENU_RICHE.md` pour la syntaxe
2. Consultez `GUIDE_FORMAT_CONTENU.dart` pour les références techniques
3. Consultez `IMPLEMENTATION_CONTENU_RICHE.md` pour l'architecture
4. Utilisez `ContentPreviewScreen` pour valider avant publication

---

**Version**: 1.0  
**Date**: 2026-07-10
