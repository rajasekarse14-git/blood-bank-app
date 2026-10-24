import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/providers/api_providers.dart';

/// Public Request Blood Screen: form with validation, quantity stepper, and API submission.
class RequestBloodScreen extends ConsumerStatefulWidget {
  const RequestBloodScreen({super.key});

  @override
  ConsumerState<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends ConsumerState<RequestBloodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedBloodGroup = 'O+';
  int _quantity = 1;
  bool _isLoading = false;

  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _hospitalController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = ref.read(bloodRequestRepositoryProvider);
      final result = await repo.createRequest(
        patientName: _nameController.text.trim(),
        bloodGroup: _selectedBloodGroup,
        quantity: _quantity,
        hospital: _hospitalController.text.trim(),
        contact: _contactController.text.trim(),
        notes: _notesController.text.trim(),
      );

      HapticFeedback.lightImpact();

      if (mounted) {
        final referenceId = result['reference_id'] as String;
        context.push(
          '/request-success',
          extra: {
            'referenceId': referenceId,
            'patientName': _nameController.text.trim(),
            'bloodGroup': _selectedBloodGroup,
            'quantity': _quantity,
            'hospital': _hospitalController.text.trim(),
          },
        );

        // Reset form
        _nameController.clear();
        _hospitalController.clear();
        _contactController.clear();
        _notesController.clear();
        setState(() {
          _quantity = 1;
        });
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Blood'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.badgeRedBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Provide accurate patient and hospital details for immediate verification and dispatch.',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // PATIENT NAME
              Text('Patient Full Name *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('patientNameField'),
                controller: _nameController,
                validator: Validators.validateName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Ramesh Kumar',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 18),

              // BLOOD GROUP DROPDOWN
              Text('Required Blood Group *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                key: const Key('bloodGroupDropdown'),
                value: _selectedBloodGroup,
                items: bloodGroups.map((bg) {
                  return DropdownMenuItem(
                    value: bg,
                    child: Text(bg, style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedBloodGroup = val;
                    });
                  }
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.water_drop_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 18),

              // QUANTITY STEPPER
              Text('Units Needed *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantity (Bags / Units)', style: TextStyle(fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          key: const Key('decrementQuantityBtn'),
                          onPressed: _quantity > 1
                              ? () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove, size: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton.filledTonal(
                          key: const Key('incrementQuantityBtn'),
                          onPressed: _quantity < 10
                              ? () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _quantity++;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // HOSPITAL
              Text('Hospital / Clinic Name *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('hospitalField'),
                controller: _hospitalController,
                validator: Validators.validateHospital,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Apollo Hospital, Ward 4',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
              ),
              const SizedBox(height: 18),

              // CONTACT PHONE
              Text('Emergency Contact Phone (10 digits) *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('contactPhoneField'),
                controller: _contactController,
                validator: Validators.validatePhone,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  hintText: '9876543210',
                  prefixIcon: Icon(Icons.phone_outlined),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 18),

              // ADDITIONAL NOTES
              Text('Notes or Urgency Details (Optional)', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('notesField'),
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Surgery scheduled for 2 PM, urgent ICU requirement',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 28),

              // SUBMIT BUTTON
              CustomButton(
                key: const Key('submitRequestBtn'),
                text: 'Submit Emergency Request',
                icon: Icons.send_rounded,
                isLoading: _isLoading,
                onPressed: _submitRequest,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
