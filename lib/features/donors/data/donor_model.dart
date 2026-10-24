/// Donor model matching GET /api/donors response shape.
class Donor {
  final int id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;
  final String phone;
  final String address;
  final int isActive;
  final String createdAt;

  const Donor({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.phone,
    required this.address,
    required this.isActive,
    required this.createdAt,
  });

  bool get active => isActive == 1;

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      bloodGroup: json['blood_group'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      isActive: (json['is_active'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'blood_group': bloodGroup,
      'phone': phone,
      'address': address,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  Donor copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    String? bloodGroup,
    String? phone,
    String? address,
    int? isActive,
    String? createdAt,
  }) {
    return Donor(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Paginated donor list response matching GET /api/donors.
class DonorListResponse {
  final List<Donor> donors;
  final int page;
  final int limit;
  final int total;

  const DonorListResponse({
    required this.donors,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory DonorListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['donors'] as List<dynamic>? ?? [])
        .map((e) => Donor.fromJson(e as Map<String, dynamic>))
        .toList();

    return DonorListResponse(
      donors: list,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? list.length,
    );
  }
}
