import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lexbid/core/common/widgets/app_flushbar.dart';
import 'package:lexbid/core/common/widgets/confirmation_dialog.dart';
import 'package:lexbid/core/common/widgets/custom_botton.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/features/auth/bloc/auth_bloc.dart';
import 'package:lexbid/features/auth/bloc/auth_event.dart';
import 'package:lexbid/features/auth/bloc/auth_state.dart';
import 'package:lexbid/features/lawyer/data/lawyer_profile/models/lawyer_profile_model.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyer_profile/lawyer_profile_bloc.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyer_profile/lawyer_profile_event.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyer_profile/lawyer_profile_state.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerProfile/widgets/lawyer_profile_info_tile.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerProfile/widgets/skeletons/lawyer_profile_skeleton.dart';
import 'package:lexbid/routes.dart';
import 'package:lexbid/widgets/ui_loader.dart';

class LawyerProfileScreen extends StatelessWidget {
  const LawyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LawyerProfileBloc()..add(LoadLawyerProfile()),
      child: const _LawyerProfileView(),
    );
  }
}

class _LawyerProfileView extends StatefulWidget {
  const _LawyerProfileView();

  @override
  State<_LawyerProfileView> createState() => _LawyerProfileViewState();
}

class _LawyerProfileViewState extends State<_LawyerProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _whatsappController;
  late TextEditingController _casesWonController;
  bool _isLoggingOut = false; // ✅ Logout overlay flag (same as client profile)

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _whatsappController = TextEditingController();
    _casesWonController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _whatsappController.dispose();
    _casesWonController.dispose();
    super.dispose();
  }

  // --- Image Picker Logic ---

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (bottomSheetContext) {
        return Wrap(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.textPrimary,
                ),
                title: Text(
                  'Gallery',
                  style: AppStyle.style14w400(
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.textPrimary,
              ),
              title: Text(
                'Camera',
                style: AppStyle.style14w400(
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
            SizedBox(height: 12.h),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null && mounted) {
      context.read<LawyerProfileBloc>().add(
        UploadProfileImage(picked.path),
      );
    }
  }

  // --- End Image Picker Logic ---

  void _syncControllers(LawyerProfileModel profile) {
    if (_nameController.text != profile.name) _nameController.text = profile.name;
    if (_locationController.text != profile.location) _locationController.text = profile.location;
    if (_whatsappController.text != profile.whatsappNumber) _whatsappController.text = profile.whatsappNumber;
    if (_casesWonController.text != profile.casesWon.toString()) {
      _casesWonController.text = profile.casesWon.toString();
    }
  }

  void _triggerValidation(LawyerProfileModel currentProfile) {
    context.read<LawyerProfileBloc>().add(
      ValidateLawyerProfile(
        currentProfile.copyWith(
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
          whatsappNumber: _whatsappController.text.trim(),
          casesWon: int.tryParse(_casesWonController.text.trim()) ?? 0,
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context,
      String field,
      TextEditingController controller,
      LawyerProfileModel profile, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Text(
          'Edit $field',
          style: AppStyle.style16w800(color: AppColors.lightGrey),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.lightGrey, fontSize: 14.sp),
          onChanged: (_) => _triggerValidation(profile),
          decoration: InputDecoration(
            hintText: 'Enter $field',
            hintStyle: TextStyle(color: AppColors.lightGrey, fontSize: 14.sp),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: AppColors.textPrimary,
                width: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
      current is AuthLoading ||
          current is AuthFailure ||
          current is AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthLoading) {
          // ✅ Show overlay instead of dialog (same as client profile)
          setState(() => _isLoggingOut = true);
        }

        if (state is AuthUnauthenticated) {
          setState(() => _isLoggingOut = false);
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteGenerator.roleSelectionRoute,
                (_) => false,
          );
        }

        if (state is AuthFailure) {
          // ✅ Hide overlay and show error
          setState(() => _isLoggingOut = false);
          AppFlushBar.showError(context, message: state.failure.message);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              child: BlocConsumer<LawyerProfileBloc, LawyerProfileState>(
                listener: (context, state) {
                  if (state is LawyerProfileLoaded && state.nameError == null) {
                    _syncControllers(state.profile);
                  }

                  if (state is LawyerProfileUpdateSuccess) {
                    _syncControllers(state.profile);
                    AppFlushBar.showSuccess(
                      context,
                      message: 'Profile updated successfully',
                    );
                  }

                  if (state is LawyerProfileError) {
                    AppFlushBar.showError(
                      context,
                      message: state.message,
                    );
                  }
                },
                builder: (context, state) {
                  // IMPLEMENTED SKELETON LOADER
                  if (state is LawyerProfileLoading) {
                    return const LawyerProfileSkeleton();
                  }

                  LawyerProfileModel? profile;
                  LawyerProfileLoaded? loadedState;

                  if (state is LawyerProfileLoaded) {
                    profile = state.profile;
                    loadedState = state;
                  } else if (state is LawyerProfileUpdateSuccess) {
                    profile = state.profile;
                  } else if (state is LawyerProfileUpdating) {
                    profile = state.oldProfile;
                  }

                  if (profile != null) {
                    return _buildBody(
                      context,
                      profile,
                      state is LawyerProfileUpdating ||
                          state is LawyerProfileImageUploading,
                      loadedState,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // ✅ Full-screen logout overlay — same as ClientProfileScreen / LoginView
          if (_isLoggingOut)
            Container(
              color: Colors.black.withAlpha(40),
              child: const Center(
                child: UiLoader(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      LawyerProfileModel profile,
      bool isUpdating,
      LawyerProfileLoaded? loadedState,
      ) {
    final initials = profile.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          // Avatar Section
          Stack(
            children: [
              Container(
                width: 90.w,
                height: 90.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: profile.avatarUrl.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    profile.avatarUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.whiteColor));
                    },
                  ),
                )
                    : Center(
                  child: Text(
                    initials,
                    style: AppStyle.style28w600(
                        color: AppColors.whiteColor),
                  ),
                ),
              ),
              Positioned(
                bottom: 2.h,
                right: 2.w,
                child: GestureDetector(
                  onTap: () => _showImageSourceDialog(context),
                  child: Container(
                    width: 26.w,
                    height: 26.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundColor,
                          width: 2.w,
                        ),
                        color: AppColors.darkContrast),
                    child: Icon(
                      Icons.edit,
                      color: AppColors.whiteColor,
                      size: 12.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '${profile.lawyerType} lawyer',
            style: AppStyle.style12w600(color: AppColors.liteGreen),
          ),
          SizedBox(height: 5.h),
          Text(
            profile.email,
            style: AppStyle.style17w900(color: AppColors.lightGrey),
          ),
          SizedBox(height: 15.h),

          LawyerInfoTile(
            label: 'Full Name',
            value: _nameController.text,
            errorText: loadedState?.nameError,
            onTap: () =>
                _showEditDialog(context, 'Full Name', _nameController, profile),
          ),
          SizedBox(height: 12.h),

          _buildAvailabilityCard(context, profile, isUpdating),
          SizedBox(height: 12.h),

          LawyerInfoTile(
            label: 'Location',
            value: _locationController.text,
            errorText: loadedState?.locationError,
            onTap: () =>
                _showEditDialog(context, 'Location', _locationController, profile),
          ),
          SizedBox(height: 12.h),

          LawyerInfoTile(
            label: 'WhatsApp Number',
            value: _whatsappController.text,
            errorText: loadedState?.whatsappError,
            onTap: () => _showEditDialog(
              context,
              'WhatsApp Number',
              _whatsappController,
              profile,
              keyboardType: TextInputType.phone,
            ),
          ),
          SizedBox(height: 12.h),
          LawyerInfoTile(
            label: 'Cases Won',
            value: '${_casesWonController.text} Cases',
            errorText: loadedState?.casesError,
            onTap: () => _showEditDialog(
              context,
              'Cases Won',
              _casesWonController,
              profile,
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 22.h),

          CustomButton(
            width: double.infinity,
            height: 54.h,
            gradientColors: AppColors.buttonGradient,
            text: isUpdating ? null : 'Save Changes',
            onTap: (isUpdating || (loadedState != null && !loadedState.isValid))
                ? null
                : () {
              context.read<LawyerProfileBloc>().add(
                UpdateLawyerProfile(
                  // FIXED: Removed the redundant '!' since 'profile' is non-nullable here.
                  profile.copyWith(
                    name: _nameController.text.trim(),
                    location: _locationController.text.trim(),
                    whatsappNumber: _whatsappController.text.trim(),
                    casesWon:
                    int.tryParse(_casesWonController.text.trim()) ?? 0,
                  ),
                ),
              );
            },
            child: isUpdating
                ? SizedBox(
              height: 24.w,
              width: 24.w,
              child: const CircularProgressIndicator(
                color: AppColors.whiteColor,
                strokeWidth: 2,
              ),
            )
                : null,
          ),
          SizedBox(height: 12.h),

          _buildLogoutButton(context),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(
      BuildContext context,
      LawyerProfileModel profile,
      bool isUpdating,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.liteGery.withAlpha(120),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVAILABILITY',
                  style: AppStyle.style12w400(color: AppColors.lightGrey),
                ),
                SizedBox(height: 3.h),
                Text(
                  profile.isAvailable ? 'Available for cases' : 'Not available',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isUpdating
                ? null
                : () async {
              bool? shouldToggle = true;
              if (!profile.isAvailable) {
                shouldToggle = await ConfirmationDialog.show(
                  context: context,
                  title: 'Your availability',
                  message:
                  'Allows clients to contact you for their cases. Do you want to proceed?',
                  confirmText: 'Confirm',
                  confirmColor: AppColors.liteGreen,
                );
              }
              if (shouldToggle == true && context.mounted) {
                context.read<LawyerProfileBloc>().add(
                  ToggleAvailability(),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44.w,
              height: 26.h,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13.r),
                gradient:
                profile.isAvailable ? AppColors.primaryGradient : null,
                color: profile.isAvailable ? null : AppColors.liteGery,
              ),
              child: Align(
                alignment: profile.isAvailable
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: const BoxDecoration(
                    color: AppColors.whiteColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.liteGery, width: 1.5),
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: () async {
          final confirm = await ConfirmationDialog.show(
            context: context,
            title: 'Logout',
            message: 'Are you sure you want to logout?',
            confirmText: 'Logout',
            confirmColor: AppColors.redColor,
          );

          if (confirm != true) return;

          final uid = FirebaseAuth.instance.currentUser?.uid;

          if (uid == null) return;

          final token = await FirebaseMessaging.instance.getToken() ?? "";

          // FIXED: Check if the widget is still mounted before using context across the async gap
          if (!context.mounted) return;

          context.read<AuthBloc>().add(
            LogoutEvent(
              uid: uid,
              deviceToken: token,
            ),
          );
        },
        child: Text(
          'Log Out',
          style: TextStyle(
            color: AppColors.liteGery,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}