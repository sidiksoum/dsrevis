import 'package:flutter/material.dart';
import 'package:dsrevis/core/constants/app_colors.dart';
import 'package:dsrevis/features/shared/presentation/widgets/rich_content_display.dart';

/// Page de PRÉVISUALISATION pour les administrateurs
/// Permet de tester le rendu du contenu Markdown + LaTeX avant publication
class ContentPreviewScreen extends StatefulWidget {
  const ContentPreviewScreen({super.key});

  @override
  State<ContentPreviewScreen> createState() => _ContentPreviewScreenState();
}

class _ContentPreviewScreenState extends State<ContentPreviewScreen> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: _getExampleContent(),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  String _getExampleContent() {
    return '''# Exemple de Contenu Riche

## Texte formaté

Le **glucose** est un sucre simple *très important* pour l'énergie cellulaire. C'est une notion ***fondamentale*** en médecine.

## Titres et structure

### Ceci est un sous-titre

Vous pouvez utiliser les markdown classiques.

## Listes

- Item 1
- Item 2
  - Sous-item 2.1
  - Sous-item 2.2
- Item 3

## Listes numérotées

1. Première étape
2. Deuxième étape
3. Troisième étape

## Citations importantes

> Le glucose est le substrat énergétique préféré du cerveau!
> Cette citation s'affiche avec un style spécial.

## Formules mathématiques

Vous pouvez inclure du Markdown formaté: **gras**, *italique*, [liens](https://example.com)

## Liens

Pour en savoir plus, consultez [Google](https://google.com) ou [Wikipedia](https://wikipedia.org).
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prévisualisation de Contenu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Zone d'édition
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Éditeur Markdown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: 'Entrez votre contenu ici...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Container(
            height: 40,
            color: AppColors.primary,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_downward, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'APERÇU EN TEMPS RÉEL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Zone de prévisualisation
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: RichContentDisplay(
                      content: _contentController.text,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Contenu: ${_contentController.text.length} caractères',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        label: const Text('Copier'),
        icon: const Icon(Icons.copy),
      ),
    );
  }
}
