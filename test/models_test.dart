import 'package:flutter_test/flutter_test.dart';
import 'package:hemolife/features/inventory/data/inventory_model.dart';
import 'package:hemolife/features/donors/data/donor_model.dart';
import 'package:hemolife/features/requests/data/blood_request_model.dart';
import 'package:hemolife/features/dashboard/data/dashboard_model.dart';

void main() {
  group('Models Deserialization & Serialization Tests', () {
    test('InventoryItem fromJson and toJson', () {
      final json = {
        'blood_group': 'O+',
        'units': 15,
        'updated_at': '2026-10-06 09:00:00',
      };

      final item = InventoryItem.fromJson(json);
      expect(item.bloodGroup, 'O+');
      expect(item.units, 15);
      expect(item.updatedAt, '2026-10-06 09:00:00');
      expect(item.toJson(), json);
    });

    test('Donor fromJson and toJson', () {
      final json = {
        'id': 1,
        'name': 'Arjun Kumar',
        'age': 28,
        'gender': 'Male',
        'blood_group': 'A+',
        'phone': '9876543210',
        'address': 'MG Road, Mumbai',
        'is_active': 1,
        'created_at': '2026-02-26 08:27:21',
      };

      final donor = Donor.fromJson(json);
      expect(donor.id, 1);
      expect(donor.name, 'Arjun Kumar');
      expect(donor.age, 28);
      expect(donor.gender, 'Male');
      expect(donor.bloodGroup, 'A+');
      expect(donor.active, isTrue);
      expect(donor.toJson(), json);
    });

    test('BloodRequest fromJson and toJson', () {
      final json = {
        'id': 1,
        'reference_id': 'REQ-SEED01',
        'patient_name': 'Priya Menon',
        'blood_group': 'O+',
        'quantity': 2,
        'hospital': 'Apollo Hospital',
        'contact': '9812345670',
        'status': 'pending',
        'notes': '',
        'created_at': '2026-02-26 08:27:21',
        'updated_at': '2026-02-26 08:27:21',
      };

      final req = BloodRequest.fromJson(json);
      expect(req.id, 1);
      expect(req.referenceId, 'REQ-SEED01');
      expect(req.patientName, 'Priya Menon');
      expect(req.bloodGroup, 'O+');
      expect(req.quantity, 2);
      expect(req.status, 'pending');
      expect(req.toJson(), json);
    });

    test('DashboardStats fromJson', () {
      final json = {
        'total_donors': 12,
        'total_requests': 5,
        'pending_requests': 2,
        'fulfilled_requests': 3,
        'total_units_available': 48,
        'requests_this_month': 4,
        'new_donors_this_month': 2,
      };

      final stats = DashboardStats.fromJson(json);
      expect(stats.totalDonors, 12);
      expect(stats.totalRequests, 5);
      expect(stats.pendingRequests, 2);
      expect(stats.fulfilledRequests, 3);
      expect(stats.totalUnitsAvailable, 48);
    });
  });
}
