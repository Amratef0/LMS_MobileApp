/// Every list endpoint in the API returns `{ total, page, pageSize, items }`
/// (see e.g. SessionsController.GetSessions) — this wraps that shape
/// generically for any item type.
class Paginated<T> {
  Paginated({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawItems = (json['items'] as List?) ?? const [];
    return Paginated(
      items: rawItems
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? rawItems.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? rawItems.length,
    );
  }

  static Paginated<T> empty<T>() =>
      Paginated<T>(items: [], total: 0, page: 1, pageSize: 10);
}

/// Small helpers reused by every model's fromJson.
int? asInt(dynamic v) => v == null ? null : (v as num).toInt();
int asIntOr(dynamic v, [int fallback = 0]) =>
    v == null ? fallback : (v as num).toInt();
double asDouble(dynamic v) => v == null ? 0 : (v as num).toDouble();
String asStr(dynamic v, [String fallback = '']) => (v as String?) ?? fallback;
DateTime? asDate(dynamic v) => v == null ? null : DateTime.tryParse(v as String);
bool asBool(dynamic v, [bool fallback = false]) => (v as bool?) ?? fallback;
