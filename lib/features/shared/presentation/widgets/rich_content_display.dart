import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dsrevis/core/constants/app_colors.dart';

/// Widget avancé pour afficher du contenu enrichi avec support :
/// - Markdown (gras, italique, listes, titres)
/// - Formules LaTeX mathématiques ($...$ et $$...$$)
/// - Liens hypertexte
/// - Citations formatées
/// - **SCROLLBAR VISIBLE** pour navigation rapide

class RichContentDisplay extends StatefulWidget {
  final String content;
  final TextStyle? baseTextStyle;
  final EdgeInsets padding;

  const RichContentDisplay({
    super.key,
    required this.content,
    this.baseTextStyle,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  State<RichContentDisplay> createState() => _RichContentDisplayState();
}

class _RichContentDisplayState extends State<RichContentDisplay> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true, // Scrollbar VISIBLE
        thickness: 8,
        radius: const Radius.circular(4),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: _buildContentWithLatex(),
        ),
      ),
    );
  }

  /// Construit le contenu en parsant et affichant LaTeX
  Widget _buildContentWithLatex() {
    final parts = _parseLatex(widget.content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts,
    );
  }

  /// Parse le contenu pour détecter et séparer les formules LaTeX
  List<Widget> _parseLatex(String content) {
    final List<Widget> widgets = [];
    final blockRegex = RegExp(r'\$\$([\s\S]*?)\$\$', multiLine: true);

    final matches = <_ParsedSection>[];

    for (final match in blockRegex.allMatches(content)) {
      matches.add(_ParsedSection(
        start: match.start,
        end: match.end,
        formula: match.group(1) ?? '',
        isBlock: true,
        isLatex: true,
      ));
    }

    matches.sort((a, b) => a.start.compareTo(b.start));

    int lastIndex = 0;
    for (final section in matches) {
      if (section.start > lastIndex) {
        final before = content.substring(lastIndex, section.start);
        if (before.trim().isNotEmpty) {
          widgets.add(_buildMarkdownWidget(before));
        }
      }

      widgets.add(_buildLatexWidget(section.formula.trim(), isBlock: true));
      lastIndex = section.end;
    }

    if (lastIndex < content.length) {
      final tail = content.substring(lastIndex);
      if (tail.trim().isNotEmpty) {
        widgets.add(_buildMarkdownWidgetWithInlineLatex(tail));
      }
    }

    if (widgets.isEmpty) {
      widgets.add(_buildMarkdownWidget(content));
    }

    return widgets;
  }

  Widget _buildMarkdownWidget(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: MarkdownBody(
        data: text,
        selectable: true,
        styleSheet: _buildMarkdownStyleSheet(),
        onTapLink: _handleTapLink,
      ),
    );
  }

  Widget _buildMarkdownWidgetWithInlineLatex(String text) {
    final parts = <Widget>[];
    final inlineRegex = RegExp(r'\$([^\$\n]+)\$');
    final matches = inlineRegex.allMatches(text).toList();

    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        final before = text.substring(lastIndex, match.start);
        if (before.trim().isNotEmpty) {
          parts.add(_buildMarkdownWidget(before));
        }
      }

      parts.add(_buildLatexWidget(match.group(1) ?? '', isBlock: false));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      final tail = text.substring(lastIndex);
      if (tail.trim().isNotEmpty) {
        parts.add(_buildMarkdownWidget(tail));
      }
    }

    if (parts.isEmpty) {
      return _buildMarkdownWidget(text);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts,
    );
  }

  /// Construit un widget pour afficher les formules LaTeX
  Widget _buildLatexWidget(String formula, {bool isBlock = false}) {
    final displayFormula = formula.trim();
    if (displayFormula.isEmpty) {
      return const SizedBox.shrink();
    }

    final label = isBlock ? '[$displayFormula]' : '($displayFormula)';

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isBlock ? 12 : 6,
        horizontal: 0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryLight,
            width: 1,
          ),
        ),
        child: SelectableText(
          label,
          style: const TextStyle(
            color: AppColors.text,
            fontFamily: 'monospace',
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  /// Gère le clic sur les liens
  Future<void> _handleTapLink(String text, String? href, String title) async {
    if (href != null && href.isNotEmpty) {
      final Uri url = Uri.parse(href);
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d\'ouvrir le lien: $href'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// Construit les styles Markdown personnalisés
  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      // Titres
      h1: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: AppColors.text,
        height: 1.4,
      ),
      h2: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
        height: 1.35,
      ),
      h3: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        height: 1.3,
      ),
      // Texte normal
      p: widget.baseTextStyle ??
          const TextStyle(
            fontSize: 16,
            color: AppColors.text,
            height: 1.6,
            fontWeight: FontWeight.normal,
          ),
      // Texte en gras
      strong: widget.baseTextStyle?.copyWith(fontWeight: FontWeight.w900) ??
          const TextStyle(
            fontSize: 16,
            color: AppColors.text,
            fontWeight: FontWeight.w900,
            height: 1.6,
          ),
      // Texte en italique
      em: widget.baseTextStyle?.copyWith(fontStyle: FontStyle.italic) ??
          const TextStyle(
            fontSize: 16,
            color: AppColors.text,
            fontStyle: FontStyle.italic,
            height: 1.6,
          ),
      // Code inline
      code: const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontFamily: 'monospace',
        backgroundColor: Color(0xFF2C3E50),
      ),
      // Blocs de code
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      codeblockPadding: const EdgeInsets.all(16),
      // Citations
      blockquote: const TextStyle(
        fontSize: 16,
        color: AppColors.text,
        fontStyle: FontStyle.italic,
        height: 1.6,
      ),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
      blockquotePadding: const EdgeInsets.all(16),
      // Listes
      listBullet: const TextStyle(
        fontSize: 16,
        color: AppColors.text,
        height: 1.6,
      ),
      listBulletPadding: const EdgeInsets.only(left: 8),
      // Liens
      a: const TextStyle(
        fontSize: 16,
        color: AppColors.primary,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w600,
      ),
      // Espacement général
      h1Padding: const EdgeInsets.symmetric(vertical: 16),
      h2Padding: const EdgeInsets.symmetric(vertical: 12),
      h3Padding: const EdgeInsets.symmetric(vertical: 10),
      pPadding: const EdgeInsets.symmetric(vertical: 8),
      listIndent: 24,
    );
  }
}

/// Classe interne pour représenter une section parsée
class _ParsedSection {
  final int start;
  final int end;
  final String formula;
  final bool isBlock;
  final bool isLatex;

  _ParsedSection({
    required this.start,
    required this.end,
    required this.formula,
    required this.isBlock,
    required this.isLatex,
  });
}

/// Widget simplifié pour du contenu court
class SimpleRichContent extends StatelessWidget {
  final String content;
  final EdgeInsets padding;

  const SimpleRichContent({
    super.key,
    required this.content,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return RichContentDisplay(
      content: content,
      padding: padding,
    );
  }
}
