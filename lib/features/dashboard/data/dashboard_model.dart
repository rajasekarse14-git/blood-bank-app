import '../../inventory/data/inventory_model.dart';
import '../../donors/data/donor_model.dart';
import '../../requests/data/blood_request_model.dart';

/// Statistical summary data from GET /api/dashboard/stats.
class DashboardStats {
  final int totalDonors;
  final int totalRequests;
  final int pendingRequests;
  final int fulfilledRequests;
  final int totalUnitsAvailable;
  final int requestsThisMonth;
  final int newDonorsThisMonth;

  const DashboardStats({
    required this.totalDonors,
    required this.totalRequests,
    required this.pendingRequests,
    required this.fulfilledRequests,
    required this.totalUnitsAvailable,
    required this.requestsThisMonth,
    required this.newDonorsThisMonth,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalDonors: (json['total_donors'] as num?)?.toInt() ?? 0,
      totalRequests: (json['total_requests'] as num?)?.toInt() ?? 0,
      pendingRequests: (json['pending_requests'] as num?)?.toInt() ?? 0,
      fulfilledRequests: (json['fulfilled_requests'] as num?)?.toInt() ?? 0,
      totalUnitsAvailable: (json['total_units_available'] as num?)?.toInt() ?? 0,
      requestsThisMonth: (json['requests_this_month'] as num?)?.toInt() ?? 0,
      newDonorsThisMonth: (json['new_donors_this_month'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Blood group distribution item in dashboard.
class BloodGroupDistribution {
  final String bloodGroup;
  final int count;

  const BloodGroupDistribution({
    required this.bloodGroup,
    required this.count,
  });

  factory BloodGroupDistribution.fromJson(Map<String, dynamic> json) {
    return BloodGroupDistribution(
      bloodGroup: json['blood_group'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Full dashboard response envelope.
class DashboardData {
  final DashboardStats stats;
  final List<InventoryItem> inventory;
  final List<BloodRequest> recentRequests;
  final List<Donor> recentDonors;
  final List<BloodGroupDistribution> bloodGroupDistribution;

  const DashboardData({
    required this.stats,
    required this.inventory,
    required this.recentRequests,
    required this.recentDonors,
    required this.bloodGroupDistribution,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] as Map<String, dynamic>? ?? {};
    final invList = (json['inventory'] as List<dynamic>? ?? [])
        .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final reqList = (json['recent_requests'] as List<dynamic>? ?? [])
        .map((e) => BloodRequest.fromJson(e as Map<String, dynamic>))
        .toList();
    final donList = (json['recent_donors'] as List<dynamic>? ?? [])
        .map((e) => Donor.fromJson(e as Map<String, dynamic>))
        .toList();
    final distList = (json['blood_group_distribution'] as List<dynamic>? ?? [])
        .map((e) => BloodGroupDistribution.fromJson(e as Map<String, dynamic>))
        .toList();

    return DashboardData(
      stats: DashboardStats.fromJson(statsJson),
      inventory: invList,
      recentRequests: reqList,
      recentDonors: donList,
      bloodGroupDistribution: distList,
    );
  }
}
