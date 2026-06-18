// lib/view/onboarding/steps/profile_setup_step.dart

// ignore_for_file: unused_element, deprecated_member_use

import 'package:examace/const/app_responsive.dart';
import 'package:examace/view/onboarding/widget/footer_widget.dart';
import 'package:examace/view/onboarding/widget/step_line_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../view_model/onboarding_view_model.dart';

class ProfileSetupStep extends ConsumerStatefulWidget {
  const ProfileSetupStep({super.key});

  @override
  ConsumerState<ProfileSetupStep> createState() => _ProfileSetupStepState();
}

class _ProfileSetupStepState extends ConsumerState<ProfileSetupStep> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLocating = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();

    // Restore previously saved state (important for back/forward steps)
    final state = ref.read(onboardingProvider);

    _nameController.text = state.fullName;
    _ageController.text = state.age;
    _cityController.text = state.city;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const _LocationException('Please turn on location services.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw const _LocationException('Location permission was denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw const _LocationException(
          'Location permission is permanently denied. Enable it in app settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final locationName = await _locationNameFromPosition(position);

      if (!mounted) return;
      _cityController.text = locationName;
      ref.read(onboardingProvider.notifier).onCityChanged(locationName);
      setState(() => _isLocating = false);
    } on _LocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _locationError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _locationError = 'Could not get your current location. Try again.';
      });
    }
  }

  Future<String> _locationNameFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts =
            <String?>[
                  place.locality,
                  place.subAdministrativeArea,
                  place.administrativeArea,
                ]
                .whereType<String>()
                .map((part) => part.trim())
                .where((part) => part.isNotEmpty)
                .toSet()
                .toList();

        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {
      // Coordinates are still better than blocking onboarding entirely.
    }

    return '${position.latitude.toStringAsFixed(5)}, '
        '${position.longitude.toStringAsFixed(5)}';
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    final notifier = ref.read(onboardingProvider.notifier);
    final state = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              // ── Glow blobs ──────────────────────────────────
              Positioned(
                bottom: -r.h50 * 2,
                right: -r.w50 * 2,
                child: _GlowBlob(
                  color: const Color(0xFFD8EE36),
                  size: r.wp(65),
                ),
              ),
              Positioned(
                top: -r.h50 * 2,
                left: -r.w50 * 2,
                child: _GlowBlob(
                  color: const Color(0xFF5822B8),
                  size: r.wp(65),
                ),
              ),

              // ── Main Content ───────────────────────────────
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    r.sp20,
                    r.h20,
                    r.sp20,
                    MediaQuery.of(context).viewInsets.bottom + r.h40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StepIndicator(currentStep: state.currentStep),

                      SizedBox(height: r.h30),

                      Text(
                        "Let's set up\nyour profile",
                        style: TextStyle(
                          fontSize: r.fs36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),

                      SizedBox(height: r.h10),

                      Text(
                        "We'll personalize your preparation journey\nbased on your background.",
                        style: TextStyle(
                          fontSize: r.fs14,
                          color: const Color(0xFFC7C8AE),
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: r.h30),

                      // ── Name ────────────────────────────
                      _GlassField(
                        r: r,
                        label: 'FULL NAME',
                        controller: _nameController,
                        hint: 'Enter your full name',
                        inputType: TextInputType.name,
                        onChanged: notifier.onFullNameChanged,
                      ),

                      SizedBox(height: r.h20),

                      // ── Age ─────────────────────────────
                      _GlassField(
                        r: r,
                        label: 'AGE',
                        controller: _ageController,
                        hint: 'e.g. 24',
                        inputType: TextInputType.number,
                        onChanged: notifier.onAgeChanged,
                      ),

                      SizedBox(height: r.h20),

                      // ── Location ─────────────────────────
                      _LocationField(
                        r: r,
                        label: 'CITY / DISTRICT',
                        controller: _cityController,
                        isLoading: _isLocating,
                        error: _locationError,
                        onTap: _isLocating ? null : _useCurrentLocation,
                      ),

                      SizedBox(height: r.h30),

                      // ── Privacy Card ────────────────────
                      Container(
                        padding: EdgeInsets.all(r.sp16),
                        decoration: BoxDecoration(
                          color: const Color(0xCC131309),
                          borderRadius: BorderRadius.circular(r.sp16),
                          border: Border.all(color: const Color(0xFF1E1E2E)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security_rounded,
                              color: const Color(0xFFD8EE36),
                              size: r.fs22,
                            ),
                            SizedBox(width: r.w10),
                            Expanded(
                              child: Text(
                                'Your data is used only for personalized exams.',
                                style: TextStyle(
                                  fontSize: r.fs13,
                                  color: const Color(0xFFC7C8AE),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Footer Button ─────────────────────────────
          FooterCTA(
            r: r,
            btnTitle: 'Continue',

            // FIX: correct validation for step 2
            enabled: state.isStep2Valid,

            onTap: state.isStep2Valid
                ? () async {
                    notifier.updateProfile(
                      fullName: _nameController.text.trim(),
                      age: _ageController.text.trim(),
                      city: _cityController.text.trim(),
                    );

                    await notifier.saveLocally();

                    if (!mounted) return;

                    notifier.nextStep();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _LocationException implements Exception {
  final String message;
  const _LocationException(this.message);
}

// ── Glass Field ─────────────────────────────
class _GlassField extends StatelessWidget {
  final AppResponsive r;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? inputType;
  final ValueChanged<String>? onChanged;

  const _GlassField({
    required this.r,
    required this.label,
    required this.hint,
    required this.controller,
    this.inputType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: r.fs11,
            letterSpacing: 1.5,
            color: const Color(0xFFD8EE36),
          ),
        ),
        SizedBox(height: r.h10),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: inputType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0x4DC7C8AE)),
            filled: true,
            fillColor: const Color(0xCC131309),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E1E2E)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Current Location Field ─────────────────────
class _LocationField extends StatelessWidget {
  final AppResponsive r;
  final String label;
  final TextEditingController controller;
  final bool isLoading;
  final String? error;
  final VoidCallback? onTap;

  const _LocationField({
    required this.r,
    required this.label,
    required this.controller,
    required this.isLoading,
    required this.error,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: r.fs11,
            letterSpacing: 1.5,
            color: const Color(0xFFD8EE36),
          ),
        ),
        SizedBox(height: r.h10),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(r.sp12 + 2),
            decoration: BoxDecoration(
              color: const Color(0xCC131309),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1E2E)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.my_location_rounded,
                  color: const Color(0xFFD8EE36),
                  size: r.fs22,
                ),
                SizedBox(width: r.w10),
                Expanded(
                  child: Text(
                    isLoading
                        ? 'Getting current location...'
                        : hasLocation
                        ? controller.text.trim()
                        : 'Use current location',
                    style: TextStyle(
                      color: hasLocation || isLoading
                          ? Colors.white
                          : const Color(0x4DC7C8AE),
                      fontSize: r.fs15,
                    ),
                  ),
                ),
                SizedBox(width: r.w10),
                isLoading
                    ? SizedBox(
                        width: r.fs18,
                        height: r.fs18,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD8EE36),
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        color: const Color(0xFF91937A),
                        size: r.fs20,
                      ),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          SizedBox(height: r.h10 * 0.8),
          Text(
            error!,
            style: TextStyle(color: const Color(0xFFFFB4AB), fontSize: r.fs13),
          ),
        ],
      ],
    );
  }
}

// ── Glow Blob ───────────────────────────────
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.05),
      ),
    );
  }
}
