import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/model/production_company.dart';
import 'package:cinevibe_desktop/providers/production_company_provider.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ProductionCompanyDetailsScreen extends StatefulWidget {
  final ProductionCompany? productionCompany;

  const ProductionCompanyDetailsScreen({super.key, this.productionCompany});

  @override
  State<ProductionCompanyDetailsScreen> createState() => _ProductionCompanyDetailsScreenState();
}

class _ProductionCompanyDetailsScreenState extends State<ProductionCompanyDetailsScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late ProductionCompanyProvider productionCompanyProvider;
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    productionCompanyProvider = Provider.of<ProductionCompanyProvider>(context, listen: false);
    _initialValue = {
      "name": widget.productionCompany?.name ?? '',
      "description": widget.productionCompany?.description ?? '',
      "country": widget.productionCompany?.country ?? '',
      "isActive": widget.productionCompany?.isActive ?? true,
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
      title: widget.productionCompany != null ? "Edit Production Company" : "Add Production Company",
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
                        widget.productionCompany != null ? Icons.edit : Icons.add_circle_outline,
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
                            widget.productionCompany != null ? 'Edit Production Company' : 'Add New Production Company',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            widget.productionCompany != null 
                                ? 'Update production company information and settings'
                                : 'Create a new production company',
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

                // Name field
                _buildFormField(
                  label: 'Company Name',
                  child: FormBuilderTextField(
                    name: "name",
                    decoration: customTextFieldDecoration(
                      "Company Name",
                      prefixIcon: Icons.business,
                      hintText: "Enter company name",
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(200),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),

                // Description field
                _buildFormField(
                  label: 'Description',
                  child: FormBuilderTextField(
                    name: "description",
                    maxLines: 3,
                    decoration: customTextFieldDecoration(
                      "Description",
                      prefixIcon: Icons.description,
                      hintText: "Enter company description (optional)",
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.maxLength(1000),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),

                // Country field
                _buildFormField(
                  label: 'Country',
                  child: FormBuilderTextField(
                    name: "country",
                    decoration: customTextFieldDecoration(
                      "Country",
                      prefixIcon: Icons.flag,
                      hintText: "Enter country (optional)",
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.maxLength(100),
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
                        "Production company is available for movie assignments",
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
                                    if (widget.productionCompany == null) {
                                      await productionCompanyProvider.insert(request);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Production Company created successfully!'),
                                          backgroundColor: Color(0xFF10B981),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                        ),
                                      );
                                    } else {
                                      await productionCompanyProvider.update(widget.productionCompany!.id, request);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Production Company updated successfully!'),
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
                                widget.productionCompany != null ? 'Update Production Company' : 'Create Production Company',
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
