/// Blood inventory item model matching GET /api/inventory response shape.
class InventoryItem {
  final String bloodGroup;
  final int units;
  final String updatedAt;

  const InventoryItem({
    required this.bloodGroup,
    required this.units,
    required this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      bloodGroup: json['blood_group'] as String? ?? '',
      units: (json['units'] as num?)?.toInt() ?? 0,
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blood_group': bloodGroup,
      'units': units,
      'updated_at': updatedAt,
    };
  }

  InventoryItem copyWith({
    String? bloodGroup,
    int? units,
    String? updatedAt,
  }) {
    return InventoryItem(
      bloodGroup: bloodGroup ?? this.bloodGroup,
      units: units ?? this.units,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItem &&
          runtimeType == other.runtimeType &&
          bloodGroup == other.bloodGroup &&
          units == other.units;

  @override
  int get hashCode => bloodGroup.hashCode ^ units.hashCode;
}

/// Search result model matching GET /api/search response shape.
class SearchResult {
  final String bloodGroup;
  final int units;
  final bool available;
  final String status; // 'available', 'low', 'out_of_stock'
  final String updatedAt;

  const SearchResult({
    required this.bloodGroup,
    required this.units,
    required this.available,
    required this.status,
    required this.updatedAt,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      bloodGroup: json['blood_group'] as String? ?? '',
      units: (json['units'] as num?)?.toInt() ?? 0,
      available: json['available'] as bool? ?? false,
      status: json['status'] as String? ?? 'out_of_stock',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}
