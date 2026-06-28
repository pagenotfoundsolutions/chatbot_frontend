class PaginatedData<T> {
  final List<T> items;
  final int total;
  final int page;
  final int size;
  final int pages;

  PaginatedData({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });
}
