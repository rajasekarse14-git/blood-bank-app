import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemolife/features/inventory/data/inventory_repository.dart';
import 'package:hemolife/features/donors/data/donor_repository.dart';
import 'package:hemolife/features/requests/data/blood_request_repository.dart';

/// Test adapter for Dio that returns pre-configured mock responses.
class MockHttpClientAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions options) handler;

  MockHttpClientAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final res = handler(options);
    final status = res['status'] as int? ?? 200;
    final data = res['data'];
    final jsonStr = jsonEncode(data);

    return ResponseBody.fromString(
      jsonStr,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Repository Tests with Mock Dio Adapter', () {
    test('InventoryRepository returns inventory list and searches blood', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000'));
      dio.httpClientAdapter = MockHttpClientAdapter((options) {
        if (options.path.contains('/api/search')) {
          return {
            'data': {
              'blood_group': 'A+',
              'units': 12,
              'available': true,
              'status': 'available',
              'updated_at': '2026-10-06',
            }
          };
        }
        return {
          'data': {
            'inventory': [
              {'blood_group': 'A+', 'units': 12, 'updated_at': '2026-10-06'},
              {'blood_group': 'O+', 'units': 15, 'updated_at': '2026-10-06'},
            ]
          }
        };
      });

      final repo = InventoryRepositoryImpl(dio: dio);
      final items = await repo.getInventory();
      expect(items.length, 2);
      expect(items.first.bloodGroup, 'A+');

      final search = await repo.searchBlood('A+');
      expect(search.bloodGroup, 'A+');
      expect(search.units, 12);
      expect(search.available, isTrue);
    });

    test('DonorRepository registers donor and fetches paginated list', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000'));
      dio.httpClientAdapter = MockHttpClientAdapter((options) {
        if (options.method == 'POST') {
          return {
            'status': 201,
            'data': {
              'message': 'Donor registered',
              'donor': {
                'id': 10,
                'name': 'Karthik',
                'age': 30,
                'gender': 'Male',
                'blood_group': 'B+',
                'phone': '9988776655',
                'address': 'Chennai',
                'is_active': 1,
                'created_at': '2026-10-06',
              }
            }
          };
        }
        return {
          'data': {
            'donors': [
              {
                'id': 1,
                'name': 'Arjun',
                'age': 28,
                'gender': 'Male',
                'blood_group': 'A+',
                'phone': '9876543210',
                'address': 'Mumbai',
                'is_active': 1,
                'created_at': '2026-10-06',
              }
            ],
            'page': 1,
            'limit': 20,
            'total': 1,
          }
        };
      });

      final repo = DonorRepositoryImpl(dio: dio);
      final res = await repo.getDonors();
      expect(res.donors.length, 1);
      expect(res.donors.first.name, 'Arjun');

      final newDonor = await repo.registerDonor(
        name: 'Karthik',
        age: 30,
        gender: 'Male',
        bloodGroup: 'B+',
        phone: '9988776655',
        address: 'Chennai',
      );
      expect(newDonor.id, 10);
      expect(newDonor.name, 'Karthik');
    });

    test('BloodRequestRepository creates emergency request and fetches list', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000'));
      dio.httpClientAdapter = MockHttpClientAdapter((options) {
        if (options.method == 'POST') {
          return {
            'status': 201,
            'data': {
              'message': 'Request created',
              'reference_id': 'REQ-2026-TEST',
              'request': {
                'id': 5,
                'reference_id': 'REQ-2026-TEST',
                'patient_name': 'Meera',
                'blood_group': 'O+',
                'quantity': 2,
                'hospital': 'City Hospital',
                'contact': '9876543210',
                'status': 'pending',
                'notes': '',
                'created_at': '2026-10-06',
                'updated_at': '2026-10-06',
              }
            }
          };
        }
        return {
          'data': {
            'requests': [
              {
                'id': 1,
                'reference_id': 'REQ-01',
                'patient_name': 'Priya',
                'blood_group': 'O+',
                'quantity': 2,
                'hospital': 'Apollo',
                'contact': '9812345670',
                'status': 'pending',
                'notes': '',
                'created_at': '2026-10-06',
                'updated_at': '2026-10-06',
              }
            ],
            'page': 1,
            'limit': 20,
            'total': 1,
          }
        };
      });

      final repo = BloodRequestRepositoryImpl(dio: dio);
      final result = await repo.createRequest(
        patientName: 'Meera',
        bloodGroup: 'O+',
        quantity: 2,
        hospital: 'City Hospital',
        contact: '9876543210',
      );

      expect(result['reference_id'], 'REQ-2026-TEST');
      final listRes = await repo.getRequests();
      expect(listRes.requests.length, 1);
      expect(listRes.requests.first.patientName, 'Priya');
    });
  });
}
