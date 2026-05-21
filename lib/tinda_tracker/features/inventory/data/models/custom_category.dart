/// Domain model for a user-managed product category stored in [tt_product_categories].
///
/// `description` and `examples` populate the management UI so shopkeepers
/// remember what each category covers.  The `isQuickAccess` flag pins the
/// category to the dashboard chip row — the UI enforces a hard cap of 10
/// pinned categories.
class CustomCategory {
  final int localId;
  final String syncId;
  final String? serverId;
  final String name;
  final String description;
  final String examples;
  final bool isQuickAccess;
  final bool isDeleted;
  final bool isDirty;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomCategory({
    required this.localId,
    required this.syncId,
    this.serverId,
    required this.name,
    this.description = '',
    this.examples = '',
    this.isQuickAccess = false,
    this.isDeleted = false,
    this.isDirty = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomCategory.fromLocalDb(Map<String, dynamic> row) {
    return CustomCategory(
      localId: row['id'] as int,
      syncId: row['sync_id'] as String,
      serverId: row['server_id'] as String?,
      name: row['name'] as String,
      description: (row['description'] as String?) ?? '',
      examples: (row['examples'] as String?) ?? '',
      isQuickAccess: (row['is_quick_access'] as int? ?? 0) == 1,
      isDeleted: (row['is_deleted'] as int? ?? 0) == 1,
      isDirty: (row['is_dirty'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'syncId': syncId,
    'name': name,
    'description': description,
    'examples': examples,
    'isQuickAccess': isQuickAccess,
    'isDeleted': isDeleted,
  };

  CustomCategory copyWith({
    String? name,
    String? description,
    String? examples,
    bool? isQuickAccess,
    bool? isDeleted,
    bool? isDirty,
  }) {
    return CustomCategory(
      localId: localId,
      syncId: syncId,
      serverId: serverId,
      name: name ?? this.name,
      description: description ?? this.description,
      examples: examples ?? this.examples,
      isQuickAccess: isQuickAccess ?? this.isQuickAccess,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
