import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:lexbid/core/common/widgets/app_flushbar.dart';
import 'package:lexbid/core/common/widgets/confirmation_dialog.dart';
import 'package:lexbid/core/common/widgets/custom_botton.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/features/auth/bloc/auth_bloc.dart';
import 'package:lexbid/features/auth/bloc/auth_event.dart';
import 'package:lexbid/features/auth/bloc/auth_state.dart';
import 'package:lexbid/features/client/bloc/client_profile/client_profile_bloc.dart';
import 'package:lexbid/features/client/bloc/client_profile/client_profile_event.dart';
import 'package:lexbid/features/client/bloc/client_profile/client_profile_state.dart';
import 'package:lexbid/features/client/data/client_profile/models/client_profile.dart';
import 'package:lexbid/features/client/presentation/view/client_profile/widgets/skeletons/client_profile_skeleton.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerProfile/widgets/lawyer_profile_info_tile.dart';
import 'package:lexbid/routes.dart';
import 'package:lexbid/widgets/ui_loader.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientProfileBloc()..add(LoadClientProfile()),
      child: const _ClientProfileView(),
    );
  }
}

class _ClientProfileView extends StatefulWidget {
  const _ClientProfileView();

  @override
  State<_ClientProfileView> createState() => _ClientProfileViewState();
}

class _ClientProfileViewState extends State<_ClientProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoggingOut = false; // ✅ Logout overlay flag

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _syncController(ClientProfileModel profile) {
    if (_nameController.text != profile.name) {
      _nameController.text = profile.name;
    }
    if (_whatsappController.text != profile.whatsappNumber) {
      _whatsappController.text = profile.whatsappNumber;
    }
  }

  Future<void> _pickImage(ClientProfileBloc bloc, ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (image == null) return;
    if (!mounted) return;

    bloc.add(PickProfileImage(File(image.path)));
  }

  void _showImageSourceSheet(BuildContext context) {
    final profileBloc = context.read<ClientProfileBloc>();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(profileBloc, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(profileBloc, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(controller: _nameController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showWhatsappDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit WhatsApp Number'),
        content: TextField(
          controller: _whatsappController,
          keyboardType: TextInputType.number,
          maxLength: 11,
          decoration: const InputDecoration(hintText: '03XXXXXXXXX'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final number = _whatsappController.text.trim();
              if (number.isNotEmpty && number.length != 11) {
                AppFlushBar.showError(context,
                    message: 'WhatsApp number must be 11 digits');
                return;
              }
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
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
          // ✅ Show overlay instead of dialog
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
              child: BlocConsumer<ClientProfileBloc, ClientProfileState>(
                listener: (context, state) {
                  if (state is ClientProfileLoaded) {
                    _syncController(state.profile);
                  }
                  if (state is ClientProfileUpdateSuccess) {
                    AppFlushBar.showSuccess(context,
                        message: 'Profile updated successfully');
                  }
                  if (state is ClientProfileError) {
                    AppFlushBar.showError(context, message: state.message);
                  }
                },
                builder: (context, state) {
                  if (state is ClientProfileLoading) {
                    return const ClientProfileSkeleton();
                  }

                  ClientProfileModel? profile;
                  File? localImage;

                  if (state is ClientProfileLoaded) {
                    profile = state.profile;
                    localImage = state.imageFile;
                  } else if (state is ClientProfileUpdateSuccess) {
                    profile = state.profile;
                  }

                  if (profile == null) return const SizedBox.shrink();

                  final initials = profile.name.isNotEmpty
                      ? profile.name[0].toUpperCase()
                      : '?';

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () => _showImageSourceSheet(context),
                          child: Stack(
                            children: [
                              Container(
                                width: 90.w,
                                height: 90.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.darkContrast
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: localImage != null
                                      ? Image.file(localImage,
                                      fit: BoxFit.cover)
                                      : (profile.avatarUrl.isNotEmpty
                                      ? Image.network(profile.avatarUrl,
                                      fit: BoxFit.cover)
                                      : Center(
                                    child: Text(
                                      initials,
                                      style: AppStyle.style28w600(
                                          color:
                                          AppColors.whiteColor),
                                    ),
                                  )),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 26.w,
                                  height: 26.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.darkContrast,
                                    border: Border.all(
                                        color: AppColors.backgroundColor,
                                        width: 2),
                                  ),
                                  child: Icon(Icons.edit,
                                      size: 12.sp,
                                      color: AppColors.whiteColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(profile.email,
                            style: AppStyle.style17w900(
                                color: AppColors.lightGrey)),
                        SizedBox(height: 20.h),
                        LawyerInfoTile(
                          label: 'Full Name',
                          value: _nameController.text,
                          onTap: () => _showEditDialog(context),
                        ),
                        SizedBox(height: 12.h),
                        LawyerInfoTile(
                          label: 'WhatsApp Number',
                          value: _whatsappController.text.isEmpty
                              ? '03XXXXXXXXX'
                              : _whatsappController.text,
                          onTap: () => _showWhatsappDialog(context),
                        ),
                        SizedBox(height: 30.h),
                        CustomButton(
                          width: double.infinity,
                          height: 54.h,
                          gradientColors: AppColors.buttonGradient,
                          text: 'Save Changes',
                          onTap: () {
                            final whatsapp = _whatsappController.text.trim();
                            if (whatsapp.isNotEmpty && whatsapp.length != 11) {
                              AppFlushBar.showError(context,
                                  message:
                                  'WhatsApp number must be 11 digits');
                              return;
                            }

                            if (profile == null) return;

                            final currentUid =
                                FirebaseAuth.instance.currentUser?.uid ?? '';

                            context.read<ClientProfileBloc>().add(
                              UpdateClientProfile(
                                profile.copyWith(
                                  uid: profile.uid.isEmpty
                                      ? currentUid
                                      : profile.uid,
                                  name: _nameController.text.trim(),
                                  whatsappNumber: whatsapp,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20.h),
                        _buildLogoutButton(context),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ✅ Full-screen logout overlay — same as LoginView
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

  Widget _buildLogoutButton(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.liteGery, width: 1.5),
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
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
          final token = await FirebaseMessaging.instance.getToken() ?? '';

          if (!mounted) return;

          if (uid != null) {
            authBloc.add(LogoutEvent(uid: uid, deviceToken: token));
          }
        },
        child: const Text('Logout'),
      ),
    );
  }
}