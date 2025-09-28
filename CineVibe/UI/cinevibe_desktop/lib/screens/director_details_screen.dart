import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/model/director.dart';
import 'package:cinevibe_desktop/providers/director_provider.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class DirectorDetailsScreen extends StatefulWidget {
  final Director? director;

  const DirectorDetailsScreen({super.key, this.director});

  @override
  State<DirectorDetailsScreen> createState() => _DirectorDetailsScreenState();
}

class _DirectorDetailsScreenState extends State<DirectorDetailsScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late DirectorProvider directorProvider;
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    directorProvider = Provider.of<DirectorProvider>(context, listen: false);
    _initialValue = {
      "firstName": widget.director?.firstName ?? '',
      "lastName": widget.director?.lastName ?? '',
      "isActive": widget.director?.isActive ?? true,
    };
    initFormData();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.director != null ? "Edit Director" : "Add Director",
      showBackButton: true,
      child: _buildForm(),
    );
  }


  Widget _buildForm() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AAD)),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004AAD).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FormBuilder(
            key: formKey,
            initialValue: _initialValue,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004AAD).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.director != null ? Icons.edit : Icons.add_circle_outline,
                        color: const Color(0xFF004AAD),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.director != null ? 'Edit Director' : 'Add New Director',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            widget.director != null 
                                ? 'Update director information and settings'
                                : 'Create a new director for the cinema system',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // First Name field
                _buildFormField(
                  label: 'First Name',
                  child: FormBuilderTextField(
                    name: "firstName",
                    decoration: customTextFieldDecoration(
                      "First Name",
                      prefixIcon: Icons.person,
                      hintText: "Enter first name",
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(100),
                      FormBuilderValidators.match(
                        RegExp(r'^[\p{L} ]+$', unicode: true),
                        errorText:
                            'Only letters (including international), and spaces allowed',
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),

                // Last Name field
                _buildFormField(
                  label: 'Last Name',
                  child: FormBuilderTextField(
                    name: "lastName",
                    decoration: customTextFieldDecoration(
                      "Last Name",
                      prefixIcon: Icons.person_outline,
                      hintText: "Enter last name",
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(100),
                      FormBuilderValidators.match(
                        RegExp(r'^[\p{L} ]+$', unicode: true),
                        errorText:
                            'Only letters (including international), and spaces allowed',
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),

                // Status toggle
                _buildFormField(
                  label: 'Status',
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: FormBuilderSwitch(
                      name: "isActive",
                      title: Text(
                        "Active",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Text(
                        "Director is available for movie assignments",
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      activeColor: const Color(0xFF10B981),
                      inactiveThumbColor: const Color(0xFFEF4444),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                formKey.currentState?.saveAndValidate();
                                if (formKey.currentState?.validate() ?? false) {
                                  setState(() => _isSaving = true);
                                  var request = Map.from(formKey.currentState?.value ?? {});

                                  try {
                                    if (widget.director == null) {
                                      await directorProvider.insert(request);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Director created successfully!'),
                                          backgroundColor: Color(0xFF10B981),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                        ),
                                      );
                                    } else {
                                      await directorProvider.update(widget.director!.id, request);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Director updated successfully!'),
                                          backgroundColor: Color(0xFF10B981),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                        ),
                                      );
                                    }
                                    Navigator.of(context).pop(true);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: const Color(0xFFEF4444),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _isSaving = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004AAD),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                widget.director != null ? 'Update Director' : 'Create Director',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
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
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
