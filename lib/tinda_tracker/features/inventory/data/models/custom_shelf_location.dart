/// Domain model for a user-managed shelf / store location stored in [tt_shelf_locations].
///
/// Keeps both an `imagePath` (local file URI, survives offline) and an
/// `imageUrl` (server URL, set after a successful multipart upload). The
/// management UI renders `imagePath` first whenever available so freshly
/// captured photos appear immediately regardless of sync state.
class CustomShelfLocation {
  final int localId;
  final String syncId;
  final String? serverId;
  final String name;
  final String description;
  final String examples;
  final String? imagePath;
  final String? imageUrl;
  final bool isDeleted;
  final bool isDirty;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomShelfLocation({
    required this.localId,
    required this.syncId,
    this.serverId,
    required this.name,
    this.description = '',
    this.examples = '',
    this.imagePath,
    this.imageUrl,
    this.isDeleted = false,
    this.isDirty = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomShelfLocation.fromLocalDb(Map<String, dynamic> row) {
    return CustomShelfLocation(
      localId: row['id'] as int,
      syncId: row['sync_id'] as String,
      serverId: row['server_id'] as String?,
      name: row['name'] as String,
      description: (row['description'] as String?) ?? '',
      examples: (row['examples'] as String?) ?? '',
      imagePath: row['image_path'] as String?,
      imageUrl: row['image_url'] as String?,
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
    'imageUrl': imageUrl,
    'isDeleted': isDeleted,
  };

  CustomShelfLocation copyWith({
    String? name,
    String? description,
    String? examples,
    String? imagePath,
    String? imageUrl,
    bool? isDeleted,
    bool? isDirty,
  }) {
    return CustomShelfLocation(
      localId: localId,
      syncId: syncId,
      serverId: serverId,
      name: name ?? this.name,
      description: description ?? this.description,
      examples: examples ?? this.examples,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
