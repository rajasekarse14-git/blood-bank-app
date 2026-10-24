import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/donor_provider.dart';

/// Public Donate Screen: donor registration form with validation and success state.
class DonateScreen extends ConsumerStatefulWidget {
  const DonateScreen({super.key});

  @override
  ConsumerState<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends ConsumerState<DonateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'O+';
  bool _isLoading = false;
  bool _registrationSuccess = false;
  String _registeredDonorName = '';

  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  static const List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _registerDonor() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(donorListProvider.notifier).registerDonor(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            gender: _selectedGender,
            bloodGroup: _selectedBloodGroup,
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          );

      if (success) {
        HapticFeedback.mediumImpact();
        setState(() {
          _registeredDonorName = _nameController.text.trim();
          _registrationSuccess = true;
        });
      } else {
        throw Exception('Registration failed. Please check network connection.');
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

  void _resetForm() {
    _nameController.clear();
    _ageController.clear();
    _phoneController.clear();
    _addressController.clear();
    setState(() {
      _selectedGender = 'Male';
      _selectedBloodGroup = 'O+';
      _registrationSuccess = false;
      _registeredDonorName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_registrationSuccess) {
      return Scaffold(
        appBar: AppBar(title: const Text('Donor Registered')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.badgeGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.healthy,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Thank You, $_registeredDonorName!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'You are registered as a life-saving blood donor ($_selectedBloodGroup). When patients nearby urgently need your blood type, they can reach you directly.',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Register Another Donor',
                  icon: Icons.person_add_rounded,
                  isOutlined: true,
                  onPressed: _resetForm,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Blood Donor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MOTIVATION CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.accent.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.volunteer_activism_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'One Donation Saves Up to 3 Lives',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Healthy adults aged 18 to 65 are eligible to donate every 3 months.',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // NAME
              Text('Full Name *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                validator: Validators.validateName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Ananya Patel',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 18),

              // AGE (18 - 65)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Age (18–65) *', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _ageController,
                          validator: Validators.validateAge,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: const InputDecoration(
                            hintText: '25',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            counterText: '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gender *', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          items: genders.map((g) {
                            return DropdownMenuItem(value: g, child: Text(g));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedGender = val;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.wc_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // BLOOD GROUP
              Text('Blood Group *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
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

              // PHONE NUMBER
              Text('Phone Number (10 digits) *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
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

              // ADDRESS / LOCATION
              Text('Address / City / Locality *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _addressController,
                validator: Validators.validateAddress,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Koramangala 4th Block, Bengaluru',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 28),

              // REGISTER BUTTON
              CustomButton(
                text: 'Register as Blood Donor',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isLoading,
                onPressed: _registerDonor,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
