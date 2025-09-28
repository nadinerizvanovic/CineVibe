import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/main.dart';
import 'package:cinevibe_desktop/model/gender.dart';
import 'package:cinevibe_desktop/model/city.dart';
import 'package:cinevibe_desktop/providers/user_provider.dart';
import 'package:cinevibe_desktop/providers/gender_provider.dart';
import 'package:cinevibe_desktop/providers/city_provider.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;
  
  const ProfileScreen({super.key, this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  int? _selectedGenderId;
  int? _selectedCityId;
  String? _base64Image;
  bool _isSaving = false;
  bool _usernameChanged = false;
  List<Gender> _genders = [];
  List<City> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDropdownData();
  }

  void _loadUserData() {
    final user = UserProvider.currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _selectedGenderId = user.genderId;
      _selectedCityId = user.cityId;
      _base64Image = user.picture;
    }
  }

  Future<void> _loadDropdownData() async {
    final genderProvider = context.read<GenderProvider>();
    final cityProvider = context.read<CityProvider>();
    
    final results = await Future.wait([
      genderProvider.get(),
      cityProvider.get(),
    ]);
    
    setState(() {
      _genders = results[0].items?.cast<Gender>() ?? [];
      _cities = results[1].items?.cast<City>() ?? [];
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        
        setState(() {
          _base64Image = base64String;
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    // Validate required fields
    if (_firstNameController.text.isEmpty) {
      _showErrorDialog('First name is required');
      return;
    }
    if (_lastNameController.text.isEmpty) {
      _showErrorDialog('Last name is required');
      return;
    }
    if (_usernameController.text.isEmpty) {
      _showErrorDialog('Username is required');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showErrorDialog('Email is required');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      _showErrorDialog('Please enter a valid email');
      return;
    }
    if (_selectedGenderId == null) {
      _showErrorDialog('Please select a gender');
      return;
    }
    if (_selectedCityId == null) {
      _showErrorDialog('Please select a city');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = UserProvider.currentUser;
      if (user == null) return;

      // Check if username changed
      if (_usernameController.text != user.username) {
        _usernameChanged = true;
      }

      // Prepare the update data according to UserUpsertRequest structure
      final updateData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text.isNotEmpty ? _phoneController.text : null,
        'genderId': _selectedGenderId,
        'cityId': _selectedCityId,
        'isActive': user.isActive,
        'picture': _base64Image, // Send as base64 string like product screen does
        'roleIds': user.roles.map((role) => role.id).toList(),
      };

      // Use the UserProvider's update method (which uses BaseProvider.update)
      final userProvider = context.read<UserProvider>();
      final updatedUser = await userProvider.update(user.id, updateData);
      
      // Update current user data
      UserProvider.currentUser = updatedUser;
      
      // Reload user data to ensure we have the latest information
      _loadUserData();

      if (_usernameChanged) {
        _showUsernameChangeDialog();
      } else {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog('Error updating profile: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showUsernameChangeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF004AAD)),
            SizedBox(width: 8),
            Text("Username Changed"),
          ],
        ),
        content: const Text(
          "Your username has been changed. You will need to log in again with your new username.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF004AAD),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 8),
            Text("Profile Updated"),
          ],
        ),
        content: const Text("Your profile has been updated successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              widget.onProfileUpdated?.call(); // Notify parent of update
              Navigator.of(context).pop(); // Go back to previous screen
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF004AAD),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Error"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF004AAD),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Profile Settings",
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF004AAD).withOpacity(0.05),
                      const Color(0xFFF7B61B).withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Profile Picture
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF004AAD),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF004AAD).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _base64Image != null
                              ? Image.memory(
                                  base64Decode(_base64Image!),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: const Color(0xFF004AAD).withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Color(0xFF004AAD),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Profile Picture",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap to change your profile picture",
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Form Fields
              Row(
                children: [
                  Expanded(
                    child: customTextField(
                      label: "First Name",
                      controller: _firstNameController,
                      prefixIcon: Icons.person_outline,
                      hintText: "Enter first name",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: customTextField(
                      label: "Last Name",
                      controller: _lastNameController,
                      prefixIcon: Icons.person_outline,
                      hintText: "Enter last name",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: customTextField(
                      label: "Username",
                      controller: _usernameController,
                      prefixIcon: Icons.alternate_email,
                      hintText: "Enter username",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: customTextField(
                      label: "Email",
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      hintText: "Enter email",
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              customTextField(
                label: "Phone Number",
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                hintText: "Enter phone number",
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Consumer<GenderProvider>(
                      builder: (context, genderProvider, child) {
                        return DropdownButtonFormField<int>(
                          value: _selectedGenderId,
                          decoration: InputDecoration(
                            labelText: "Gender",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF004AAD)),
                            ),
                          ),
                          items: _genders
                              .where((gender) => gender.isActive)
                              .map((gender) => DropdownMenuItem<int>(
                                    value: gender.id,
                                    child: Text(gender.name),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGenderId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a gender';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<CityProvider>(
                      builder: (context, cityProvider, child) {
                        return DropdownButtonFormField<int>(
                          value: _selectedCityId,
                          decoration: InputDecoration(
                            labelText: "City",
                            prefixIcon: const Icon(Icons.location_city_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF004AAD)),
                            ),
                          ),
                          items: _cities
                              .map((city) => DropdownMenuItem<int>(
                                    value: city.id,
                                    child: Text(city.name),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCityId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a city';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: customElevatedButton(
                      text: "Save Changes",
                      onPressed: _isSaving ? null : _saveProfile,
                      height: 48,
                      isLoading: _isSaving,
                      backgroundColor: const Color(0xFF004AAD),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
