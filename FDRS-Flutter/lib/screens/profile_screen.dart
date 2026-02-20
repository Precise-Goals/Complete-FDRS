import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../theme/app_theme.dart';

class MobileNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 5) {
        formatted += '-';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FDRS',
                                style: AppTheme.poppinsFont.copyWith(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.green[500],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SYSTEM ACTIVE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                      color: Colors.green[500]?.withAlpha(204),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Profile Avatar
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => model.pickImage(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 146, 97, 23),
                                  Colors.red,
                                  Color.fromARGB(255, 232, 186, 3)
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withAlpha(100),
                                  blurRadius: 20,
                                )
                              ],
                            ),
                            // child: BackdropFilter(
                            //   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            //   child: Container(color: Colors.transparent),
                            // ),
                          ),
                          Container(
                            width: 128,
                            height: 128,
                            padding: const EdgeInsets.all(1),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(255, 255, 255, 0.4),
                                  Color.fromRGBO(255, 255, 255, 0.05)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                image: DecorationImage(
                                  image: model.profileImageBase64 != null
                                      ? MemoryImage(base64Decode(
                                          model.profileImageBase64!))
                                      : const NetworkImage(
                                          'https://i.ibb.co/9mbvXqx4/business-user-profile-icon-black-white-minimal-flat-style-professional-avatar-symbol-account-login-c.jpg',
                                        ) as ImageProvider,
                                  fit: BoxFit.cover,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black12, BlendMode.darken),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFF97316),
                                    Color(0xFFEA580C)
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black54, blurRadius: 20)
                                ],
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          model.nameController.text.isNotEmpty
                              ? model.nameController.text
                              : model.userEmail,
                          style: AppTheme.poppinsFont.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified,
                            color: Colors.blue, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${model.userUid}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Forms
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _buildFormSection(
                            icon: Icons.person_outline,
                            title: 'Identity',
                            children: [
                              _buildInputField('Full Name', '', false,
                                  controller: model.nameController),
                              const SizedBox(height: 20),
                              _buildInputField(
                                  'Email Address', model.userEmail, false),
                              const SizedBox(height: 20),
                              _buildInputField(
                                'Mobile Number',
                                '',
                                false,
                                controller: model.mobileController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  MobileNumberFormatter(),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildFormSection(
                            icon: Icons.shield_outlined,
                            title: 'Secure Data',
                            children: [
                              _buildInputField('Device Build Number',
                                  model.buildNumber, true),
                              const SizedBox(height: 20),
                              _buildInputField('Residential Address', '', false,
                                  isMultiline: true,
                                  controller: model.addressController),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Save Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x80F97316),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: model.isLoading
                                    ? null
                                    : () => model.saveProfile(context),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (model.isLoading)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    else ...[
                                      const Icon(Icons.save_outlined,
                                          color: Colors.white),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'SAVE SECURE PROFILE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: model.signOut,
                            icon: const Icon(Icons.logout,
                                size: 16, color: Colors.grey),
                            label: const Text(
                              'SIGN OUT',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  letterSpacing: 1.0),
                            ),
                          ),

                          const SizedBox(height: 100), // Space for bottom nav
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormSection(
      {required IconData icon,
      required String title,
      required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.15)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[400], size: 16),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value, bool isSecure,
      {bool isMultiline = false,
      TextEditingController? controller,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Colors.grey[500],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: 16, vertical: isMultiline ? 16 : 14),
          decoration: BoxDecoration(
            color: const Color(0xFF050505),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
          ),
          child: Row(
            crossAxisAlignment: isMultiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: controller != null
                    ? TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        inputFormatters: inputFormatters,
                        style: TextStyle(
                          color: Colors.grey[100],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: 'Enter $label',
                          hintStyle: TextStyle(color: Colors.grey[700]),
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          color: Colors.grey[100],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          fontFamily: isSecure ? 'monospace' : null,
                        ),
                      ),
              ),
              if (isSecure)
                const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
