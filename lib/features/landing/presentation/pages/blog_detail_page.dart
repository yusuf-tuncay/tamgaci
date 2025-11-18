// ========== BLOG DETAIL PAGE ==========
// lib/features/landing/presentation/pages/blog_detail_page.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'blog_page.dart';

/// Blog detay sayfası - SEO için önemli içerik
class BlogDetailPage extends StatefulWidget {
  final String slug;

  const BlogDetailPage({super.key, required this.slug});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Her build'de eski recognizer'ları temizle
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = colorScheme.surface;

    final blogPost = _getBlogPostBySlug(widget.slug);

    if (blogPost == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => context.go('/blog'),
          ),
          title: Text(
            'Blog',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        body: const Center(
          child: Text('Blog yazısı bulunamadı'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => context.go('/blog'),
        ),
        title: Text(
          'Blog',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width > 768 ? 80 : 40,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    blogPost['icon'] as IconData,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    blogPost['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize:
                          MediaQuery.of(context).size.width > 768 ? 48 : 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        blogPost['date'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          blogPost['category'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Section
            Container(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width > 768 ? 80 : 40,
              ),
              color: surfaceColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blog Image (if available)
                  if (blogPost['image'] != null)
                    Container(
                      width: double.infinity,
                      height:
                          MediaQuery.of(context).size.width > 768 ? 400 : 250,
                      margin: const EdgeInsets.only(bottom: 40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.45)
                                : Colors.black.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          blogPost['image'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Icon(
                                  blogPost['icon'] as IconData,
                                  size: 80,
                                  color: colorScheme.primary,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Full Content with TAMGACI links
                  _buildRichContent(
                    context,
                    (blogPost['content'] as String?) ??
                        (blogPost['description'] as String),
                    _recognizers,
                  ),

                  const SizedBox(height: 60),

                  // Back to Blog Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () => context.go('/blog'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Blog Listesine Dön',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _getBlogPostBySlug(String slug) {
    final allPosts = _getAllBlogPosts();
    try {
      return allPosts.firstWhere((post) => post['slug'] == slug);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> _getAllBlogPosts() {
    // Blog listesini blog_page.dart'dan al
    return getBlogPosts();
  }

  /// TAMGACI kelimelerini tıklanabilir link yaparak içerik oluşturur
  Widget _buildRichContent(
    BuildContext context,
    String text,
    List<TapGestureRecognizer> recognizers,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final baseStyle = GoogleFonts.poppins(
      fontSize: 18,
      color: colorScheme.onSurface.withValues(alpha: 0.8),
      height: 1.8,
    );

    final headingStyle = GoogleFonts.poppins(
      fontSize: 24,
      color: colorScheme.onSurface,
      height: 1.6,
      fontWeight: FontWeight.w700,
    );

    final linkStyle = GoogleFonts.poppins(
      fontSize: 18,
      color: colorScheme.primary,
      height: 1.8,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    // Markdown benzeri başlıkları ve listeleri parse et
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    final RegExp tamgaciRegex = RegExp(r'\bTAMGACI\b', caseSensitive: false);

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 16));
        continue;
      }

      // Başlık kontrolü (## ile başlayanlar)
      if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 32, bottom: 16),
            child: Text(
              line.substring(3),
              style: headingStyle,
            ),
          ),
        );
        continue;
      }

      // Numaralı liste kontrolü
      if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: baseStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildRichTextLine(
                    context,
                    line.replaceFirst(RegExp(r'^\d+\.\s'), ''),
                    baseStyle,
                    linkStyle,
                    tamgaciRegex,
                    recognizers,
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Normal metin satırı
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRichTextLine(
            context,
            line,
            baseStyle,
            linkStyle,
            tamgaciRegex,
            recognizers,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Tek bir satırı TAMGACI linkleri ile birlikte oluşturur
  Widget _buildRichTextLine(
    BuildContext context,
    String line,
    TextStyle baseStyle,
    TextStyle linkStyle,
    RegExp tamgaciRegex,
    List<TapGestureRecognizer> recognizers,
  ) {
    final List<TextSpan> spans = [];
    final matches = tamgaciRegex.allMatches(line);
    int lastIndex = 0;

    for (final match in matches) {
      // Match'ten önceki metni ekle
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: line.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      // TAMGACI kelimesini tıklanabilir link olarak ekle
      final recognizer = TapGestureRecognizer()
        ..onTap = () {
          if (mounted) {
            context.go('/');
          }
        };
      recognizers.add(recognizer);
      spans.add(
        TextSpan(
          text: match.group(0),
          style: linkStyle,
          recognizer: recognizer,
        ),
      );

      lastIndex = match.end;
    }

    // Kalan metni ekle
    if (lastIndex < line.length) {
      spans.add(
        TextSpan(
          text: line.substring(lastIndex),
          style: baseStyle,
        ),
      );
    }

    // Eğer hiç TAMGACI yoksa, sadece metni ekle
    if (spans.isEmpty) {
      spans.add(
        TextSpan(
          text: line,
          style: baseStyle,
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
