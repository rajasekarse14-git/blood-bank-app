/// Blood Request model matching GET /api/requests response shape.
class BloodRequest {
  final int id;
  final String referenceId;
  final String patientName;
  final String bloodGroup;
  final int quantity;
  final String hospital;
  final String contact;
  final String status; // 'pending', 'processing', 'fulfilled', 'cancelled'
  final String? notes;
  final String createdAt;
  final String updatedAt;

  const BloodRequest({
    required this.id,
    required this.referenceId,
    required this.patientName,
    required this.bloodGroup,
    required this.quantity,
    required this.hospital,
    required this.contact,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      referenceId: json['reference_id'] as String? ?? '',
      patientName: json['patient_name'] as String? ?? '',
      bloodGroup: json['blood_group'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      hospital: json['hospital'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference_id': referenceId,
      'patient_name': patientName,
      'blood_group': bloodGroup,
      'quantity': quantity,
      'hospital': hospital,
      'contact': contact,
      'status': status,
      'notes': notes ?? '',
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  BloodRequest copyWith({
    int? id,
    String? referenceId,
    String? patientName,
    String? bloodGroup,
    int? quantity,
    String? hospital,
    String? contact,
    String? status,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return BloodRequest(
      id: id ?? this.id,
      referenceId: referenceId ?? this.referenceId,
      patientName: patientName ?? this.patientName,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      quantity: quantity ?? this.quantity,
      hospital: hospital ?? this.hospital,
      contact: contact ?? this.contact,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Paginated request list response matching GET /api/requests.
class BloodRequestListResponse {
  final List<BloodRequest> requests;
  final int page;
  final int limit;
  final int total;

  const BloodRequestListResponse({
    required this.requests,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory BloodRequestListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['requests'] as List<dynamic>? ?? [])
        .map((e) => BloodRequest.fromJson(e as Map<String, dynamic>))
        .toList();

    return BloodRequestListResponse(
      requests: list,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? list.length,
    );
  }
}
