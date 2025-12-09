import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import '../../../../model/model.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'package:urban_wear_app/features/shared/services/localization_service.dart';
import 'package:urban_wear_app/features/shared/services/theme_service.dart';
import 'package:urban_wear_app/features/shared/routes/app_router.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..loadProfile(user),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;

  final List<String> _countries = [
    'Indonesia',
    'United States',
    'Singapore',
    'Malaysia',
    'Australia'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickGalleryImage(BuildContext context) async {
    // Skip permission check on Web
    if (kIsWeb) {
      await _executePickImage(context);
      return;
    }

    PermissionStatus status;
    if (defaultTargetPlatform == TargetPlatform.android) {
      status = await Permission.photos.request();
      if (status.isPermanentlyDenied || status.isDenied) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted || status.isLimited) {
      if (context.mounted) await _executePickImage(context);
    } else if (status.isDenied || status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(context);
      }
    }
  }

  Future<void> _executePickImage(BuildContext context) async {
    try {
      final XFile? picked = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85);

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final b64 = base64Encode(bytes);
        if (context.mounted) {
          context.read<ProfileCubit>().updateImage(b64);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Image pick error: $e');
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text('Please grant Gallery access to select a photo.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ctx.pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void _saveProfile(BuildContext context, String? selectedCountry) {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().saveProfile(
            name: _nameController.text,
            phone: _phoneController.text,
            dob: _dobController.text,
            country: selectedCountry,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final inputFillColor = isDark ? Colors.grey[800]! : Colors.white;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 900;
      double responsiveSize(num mobileSp, num desktopPx) =>
          isDesktop ? desktopPx.toDouble() : mobileSp.toDouble().sp;

      return ValueListenableBuilder<String>(
          valueListenable: ThemeService.languageNotifier,
          builder: (context, currentLang, child) {
            return BlocListener<ProfileCubit, ProfileState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {
                if (state.status == ProfileStatus.success) {
                  if (_nameController.text.isEmpty) {
                    _nameController.text = state.name;
                  }
                  if (_emailController.text.isEmpty) {
                    _emailController.text = state.email;
                  }
                  if (_phoneController.text.isEmpty) {
                    _phoneController.text = state.phone;
                  }
                  if (_dobController.text.isEmpty) {
                    _dobController.text = state.dob;
                  }
                }
                if (state.status == ProfileStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage ?? 'Error')),
                  );
                }
              },
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  backgroundColor:
                      Theme.of(context).appBarTheme.backgroundColor,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: textColor, size: responsiveSize(18, 24)),
                    onPressed: () => context.go(AppRoutes.dashboard),
                  ),
                  title: Text(
                    LocalizationService.get(currentLang, 'editProfile'),
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveSize(16, 20)),
                  ),
                  centerTitle: true,
                ),
                body: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                  if (state.status == ProfileStatus.loading &&
                      state.name.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_nameController.text != state.name &&
                      state.name.isNotEmpty &&
                      _nameController.text.isEmpty) {
                    _nameController.text = state.name;
                  }
                  if (_emailController.text != state.email &&
                      state.email.isNotEmpty &&
                      _emailController.text.isEmpty) {
                    _emailController.text = state.email;
                  }
                  if (_phoneController.text != state.phone &&
                      state.phone.isNotEmpty &&
                      _phoneController.text.isEmpty) {
                    _phoneController.text = state.phone;
                  }
                  if (_dobController.text != state.dob &&
                      state.dob.isNotEmpty &&
                      _dobController.text.isEmpty) {
                    _dobController.text = state.dob;
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 20 : 5.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: isDesktop ? 100 : 25.w,
                                  height: isDesktop ? 100 : 25.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    image: state.base64Image != null
                                        ? DecorationImage(
                                            image: MemoryImage(base64Decode(
                                                state.base64Image!)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: state.base64Image == null
                                      ? Icon(Icons.person,
                                          size: isDesktop ? 50 : 12.w,
                                          color: isDark
                                              ? Colors.grey[500]
                                              : Colors.grey[400])
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _pickGalleryImage(context),
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(isDesktop ? 8 : 2.w),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.grey[700]
                                            : Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Icon(Icons.photo_library,
                                          size: responsiveSize(12, 16),
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isDesktop ? 32 : 4.h),

                          // Form Fields
                          _buildLabel(
                              LocalizationService.get(currentLang, 'name'),
                              textColor,
                              responsiveSize),
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(
                                color: textColor,
                                fontSize: responsiveSize(11, 14)),
                            decoration: _inputDecoration(
                                LocalizationService.get(
                                    currentLang, 'enterName'),
                                inputFillColor,
                                borderColor,
                                isDark,
                                responsiveSize),
                            validator: (v) => v?.isEmpty == true
                                ? LocalizationService.get(
                                    currentLang, 'nameRequired')
                                : null,
                          ),
                          SizedBox(height: isDesktop ? 16 : 2.h),

                          _buildLabel(
                              LocalizationService.get(currentLang, 'email'),
                              textColor,
                              responsiveSize),
                          TextFormField(
                            controller: _emailController,
                            readOnly: true,
                            style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: responsiveSize(11, 14)),
                            decoration: _inputDecoration(
                                    LocalizationService.get(
                                        currentLang, 'enterEmail'),
                                    inputFillColor,
                                    borderColor,
                                    isDark,
                                    responsiveSize)
                                .copyWith(
                              suffixIcon: Icon(Icons.email,
                                  size: responsiveSize(12, 16),
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                            ),
                          ),
                          SizedBox(height: isDesktop ? 16 : 2.h),

                          _buildLabel(
                              LocalizationService.get(
                                  currentLang, 'phoneNumber'),
                              textColor,
                              responsiveSize),
                          TextFormField(
                            controller: _phoneController,
                            style: TextStyle(
                                color: textColor,
                                fontSize: responsiveSize(11, 14)),
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                                '081234567890',
                                inputFillColor,
                                borderColor,
                                isDark,
                                responsiveSize),
                          ),
                          SizedBox(height: isDesktop ? 16 : 2.h),

                          _buildLabel(
                              LocalizationService.get(
                                  currentLang, 'dateOfBirth'),
                              textColor,
                              responsiveSize),
                          TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            style: TextStyle(
                                color: textColor,
                                fontSize: responsiveSize(11, 14)),
                            onTap: () => _selectDate(context),
                            decoration: _inputDecoration(
                                    'dd/mm/yyyy',
                                    inputFillColor,
                                    borderColor,
                                    isDark,
                                    responsiveSize)
                                .copyWith(
                              suffixIcon: Icon(Icons.calendar_today,
                                  size: responsiveSize(16, 20),
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                            ),
                          ),
                          SizedBox(height: isDesktop ? 16 : 2.h),

                          _buildLabel(
                              LocalizationService.get(currentLang, 'country'),
                              textColor,
                              responsiveSize),
                          DropdownButtonFormField<String>(
                            value: state.selectedCountry,
                            dropdownColor:
                                isDark ? Colors.grey[800] : Colors.white,
                            style: TextStyle(
                                color: textColor,
                                fontSize: responsiveSize(11, 14)),
                            items: _countries
                                .map((c) =>
                                    DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) {
                              context.read<ProfileCubit>().saveProfile(
                                  name: _nameController.text,
                                  phone: _phoneController.text,
                                  dob: _dobController.text,
                                  country: v);
                            },
                            decoration: _inputDecoration(
                                LocalizationService.get(
                                    currentLang, 'selectCountry'),
                                inputFillColor,
                                borderColor,
                                isDark,
                                responsiveSize),
                            icon: Icon(Icons.keyboard_arrow_down,
                                size: responsiveSize(18, 24),
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
                          ),

                          SizedBox(height: isDesktop ? 32 : 4.h),

                          SizedBox(
                            width: double.infinity,
                            height: isDesktop ? 50 : 6.h,
                            child: ElevatedButton(
                              onPressed: () {
                                _saveProfile(context, state.selectedCountry);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(LocalizationService.get(
                                        currentLang, 'savedSuccess')),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                LocalizationService.get(
                                    currentLang, 'saveChanges'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsiveSize(12, 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          });
    });
  }

  Widget _buildLabel(String label, Color color, Function responsiveSize) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: responsiveSize(11, 14),
          color: color,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, Color fillColor,
      Color borderColor, bool isDark, Function responsiveSize) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: isDark ? Colors.grey[500] : Colors.grey[400],
          fontSize: responsiveSize(11, 14)),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      filled: true,
      fillColor: fillColor,
    );
  }
}
