import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_mobile/providers/user_provider.dart';
import 'package:cinevibe_mobile/providers/city_provider.dart';
import 'package:cinevibe_mobile/providers/gender_provider.dart';
import 'package:cinevibe_mobile/model/city.dart';
import 'package:cinevibe_mobile/model/gender.dart';
import 'package:cinevibe_mobile/utils/base_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isLoadingCities = true;
  bool _isLoadingGenders = true;

  City? _selectedCity;
  Gender? _selectedGender;
  List<City> _cities = [];
  List<Gender> _genders = [];

  // Picture upload
  File? _image;
  String? _pictureBase64;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final cityProvider = Provider.of<CityProvider>(context, listen: false);
      final genderProvider = Provider.of<GenderProvider>(context, listen: false);

      final citiesResult = await cityProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );
      final gendersResult = await genderProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        setState(() {
          _cities = citiesResult.items ?? [];
          _genders = gendersResult.items ?? [];
          _isLoadingCities = false;
          _isLoadingGenders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCities = false;
          _isLoadingGenders = false;
        });
        _showErrorDialog("Failed to load registration data: $e");
      }
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // This ensures we get the file data
    );
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _pictureBase64 = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF004AAD).withOpacity(0.1),
                  const Color(0xFF1E40AF).withOpacity(0.05),
                  const Color(0xFF3B82F6).withOpacity(0.03),
                ],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Header
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Color(0xFF004AAD),
                                size: 20,
                              ),
                            ),
                            alignment: Alignment.center, // Center the back arrow
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Join CineVibe and discover amazing movies",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Registration form card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              spreadRadius: 0,
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            // Profile Picture Section
                            _buildProfilePictureSection(),
                            const SizedBox(height: 32),

                            // Form Fields
                            _buildFormFields(),
                            const SizedBox(height: 32),

                            // Register button
                            _buildRegisterButton(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Text(
          "Profile Picture",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),

        // Current/Selected Image Display
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF004AAD).withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004AAD).withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _pictureBase64 != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      base64Decode(_pictureBase64!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    ),
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        const SizedBox(height: 16),

        // Image Selection Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text("Select Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AAD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _image = null;
                    _pictureBase64 = null;
                  });
                },
                icon: const Icon(Icons.clear, size: 18),
                label: const Text("Clear"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // First Name field
          customTextField(
            label: "First Name",
            controller: firstNameController,
            prefixIcon: Icons.person_outline,
            hintText: "Enter first name",
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Last Name field
          customTextField(
            label: "Last Name",
            controller: lastNameController,
            prefixIcon: Icons.person_outline,
            hintText: "Enter last name",
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Email field
          customTextField(
            label: "Email",
            controller: emailController,
            prefixIcon: Icons.email_outlined,
            hintText: "Enter your email",
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Username field
          customTextField(
            label: "Username",
            controller: usernameController,
            prefixIcon: Icons.alternate_email,
            hintText: "Choose a username",
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a username';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password field
          customTextField(
            label: "Password",
            controller: passwordController,
            prefixIcon: Icons.lock_outline,
            hintText: "Enter password",
            obscureText: !_isPasswordVisible,
            suffixIcon: _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            onSuffixIconPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 4) {
                return 'Password must be at least 4 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Confirm Password field
          customTextField(
            label: "Confirm Password",
            controller: confirmPasswordController,
            prefixIcon: Icons.lock_outline,
            hintText: "Confirm your password",
            obscureText: !_isConfirmPasswordVisible,
            suffixIcon: _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
            onSuffixIconPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Phone field
          customTextField(
            label: "Phone Number",
            controller: phoneController,
            prefixIcon: Icons.phone_outlined,
            hintText: "Enter phone number",
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Gender dropdown
          _buildGenderDropdown(),
          const SizedBox(height: 20),

          // City dropdown
          _buildCityDropdown(),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<Gender>(
        value: _selectedGender,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.person_outline, color: Color(0xFF6B7280)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelText: "Gender",
          labelStyle: TextStyle(color: Color(0xFF6B7280)),
        ),
        items: _genders.map((Gender gender) {
          return DropdownMenuItem<Gender>(
            value: gender,
            child: Text(gender.name),
          );
        }).toList(),
        onChanged: (Gender? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a gender';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<City>(
        value: _selectedCity,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.location_city_outlined, color: Color(0xFF6B7280)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelText: "City",
          labelStyle: TextStyle(color: Color(0xFF6B7280)),
        ),
        items: _cities.map((City city) {
          return DropdownMenuItem<City>(
            value: city,
            child: Text(
              city.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList(),
        onChanged: (City? newValue) {
          setState(() {
            _selectedCity = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a city';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isLoading || _isLoadingCities || _isLoadingGenders)
            ? null
            : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004AAD),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          "Tap to add\nprofile picture",
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Create registration request
      final registrationData = {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "username": usernameController.text.trim(),
        "password": passwordController.text,
        "phoneNumber": phoneController.text.trim(),
        "genderId": _selectedGender!.id,
        "cityId": _selectedCity!.id,
        "isActive": true,
        "roleIds": [2], // Standard user role
        "picture": _pictureBase64,
      };

      await userProvider.insert(registrationData);

      if (mounted) {
        _showSuccessDialog();
      }
    } on Exception catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      }
    } catch (e) {
      print(e);
      if (mounted) {
        _showErrorDialog("An unexpected error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Registration Failed"),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 20,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFF8FAFC)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF10B981),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                "Registration Successful!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              const Text(
                "Your account has been created successfully! You can now sign in with your credentials.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to login screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}