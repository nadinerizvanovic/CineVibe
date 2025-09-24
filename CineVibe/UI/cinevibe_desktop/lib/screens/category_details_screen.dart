import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/model/category.dart';
import 'package:cinevibe_desktop/providers/category_provider.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:cinevibe_desktop/screens/category_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final Category? category;

  const CategoryDetailsScreen({super.key, this.category});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CategoryProvider categoryProvider;
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _initialValue = {
      "name": widget.category?.name ?? '',
      "description": widget.category?.description ?? '',
      "isActive": widget.category?.isActive ?? true,
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
      title: widget.category != null ? "Edit Category" : "Add Category",
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        customElevatedButton(
          text: "Cancel",
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          isOutlined: true,
          backgroundColor: Colors.grey.shade600,
        ),
        const SizedBox(width: 16),
        customElevatedButton(
          text: "Save",
          onPressed: _isSaving
              ? null
              : () async {
                  formKey.currentState?.saveAndValidate();
                  if (formKey.currentState?.validate() ?? false) {
                    setState(() => _isSaving = true);
                    var request = Map.from(formKey.currentState?.value ?? {});

                    try {
                      if (widget.category == null) {
                        await categoryProvider.insert(request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Category created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await categoryProvider.update(widget.category!.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Category updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CategoryListScreen(),
                          settings: const RouteSettings(name: 'CategoryListScreen'),
                        ),
                      );
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } finally {
                      if (mounted) setState(() => _isSaving = false);
                    }
                  }
                },
          backgroundColor: const Color(0xFF004AAD),
          isLoading: _isSaving,
        ),
      ],
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: customCard(
          padding: const EdgeInsets.all(32.0),
          borderColor: const Color(0xFF004AAD).withOpacity(0.2),
          child: FormBuilder(
            key: formKey,
            initialValue: _initialValue,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004AAD).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.category,
                        size: 28,
                        color: const Color(0xFF004AAD),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      widget.category != null ? "Edit Category" : "Add New Category",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),

                // Name field
                FormBuilderTextField(
                  name: "name",
                  decoration: customTextFieldDecoration(
                    "Category Name",
                    prefixIcon: Icons.category,
                    hintText: "Enter category name",
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(100),
                  ]),
                ),
                SizedBox(height: 20),

                // Description field
                FormBuilderTextField(
                  name: "description",
                  maxLines: 3,
                  decoration: customTextFieldDecoration(
                    "Description",
                    prefixIcon: Icons.description,
                    hintText: "Enter category description (optional)",
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.maxLength(500),
                  ]),
                ),
                SizedBox(height: 20),

                // Is Active field
                FormBuilderSwitch(
                  name: "isActive",
                  title: Text(
                    "Active",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  activeColor: const Color(0xFF004AAD),
                ),
                SizedBox(height: 40),

                // Save and Cancel Buttons
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
