/// Respuesta paginada de la API: `{ content: [...], page: { number, size, totalElements, totalPages } }`.
class PageResult<T> {
  const PageResult({
    required this.content,
    required this.number,
    required this.totalPages,
    required this.totalElements,
  });

  final List<T> content;
  final int number;
  final int totalPages;
  final int totalElements;

  bool get hasMore => number + 1 < totalPages;

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final page = json['page'] as Map<String, dynamic>;
    return PageResult(
      content: (json['content'] as List<dynamic>)
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      number: (page['number'] as num).toInt(),
      totalPages: (page['totalPages'] as num).toInt(),
      totalElements: (page['totalElements'] as num).toInt(),
    );
  }
}
