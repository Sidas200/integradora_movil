/// Noticia publicada (`GET /news`).
class NewsSummary {
  const NewsSummary({
    required this.slug,
    required this.title,
    required this.summary,
    required this.publishedAt,
  });

  final String slug;
  final String title;
  final String summary;
  final DateTime publishedAt;

  factory NewsSummary.fromJson(Map<String, dynamic> json) => NewsSummary(
        slug: json['slug'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        publishedAt: DateTime.parse(json['publishedAt'] as String),
      );
}

/// Detalle de una noticia (`GET /news/{slug}`).
class NewsPost extends NewsSummary {
  const NewsPost({
    required super.slug,
    required super.title,
    required super.summary,
    required super.publishedAt,
    required this.contentMd,
  });

  /// Contenido en Markdown.
  final String contentMd;

  factory NewsPost.fromJson(Map<String, dynamic> json) => NewsPost(
        slug: json['slug'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        publishedAt: DateTime.parse(json['publishedAt'] as String),
        contentMd: json['contentMd'] as String,
      );
}
