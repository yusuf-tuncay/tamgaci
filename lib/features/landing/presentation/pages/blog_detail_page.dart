// ========== BLOG DETAIL PAGE ==========
// lib/features/landing/presentation/pages/blog_detail_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'blog_page.dart';

/// Blog detay sayfası - SEO için önemli içerik
class BlogDetailPage extends StatelessWidget {
  final String slug;

  const BlogDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final blogPost = _getBlogPostBySlug(slug);

    if (blogPost == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
            onPressed: () => context.go('/blog'),
          ),
          title: Text(
            'Blog',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
          onPressed: () => context.go('/blog'),
        ),
        title: Text(
          'Blog',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A8A),
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
              decoration: BoxDecoration(
                gradient: const LinearGradient(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Content
                  Text(
                    blogPost['description'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: const Color(0xFF64748B),
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Back to Blog Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () => context.go('/blog'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
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
    return BlogPage.getBlogPosts();
  }
}

