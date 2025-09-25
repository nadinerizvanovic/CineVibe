import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/model/product.dart';
import 'package:cinevibe_desktop/providers/product_provider.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:cinevibe_desktop/screens/product_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ProductAddEditScreen extends StatefulWidget {
  final Product? product;

  const ProductAddEditScreen({super.key, this.product});

  @override
  State<ProductAddEditScreen> createState() => _ProductAddEditScreenState();
}

class _ProductAddEditScreenState extends State<ProductAddEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late ProductProvider productProvider;
  bool isLoading = true;
  bool _isSaving = false;
  String? _selectedImageBase64;
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    _initialValue = {
      "name": widget.product?.name ?? '',
      "price": widget.product?.price ?? 0.0,
      "isActive": widget.product?.isActive ?? true,
    };
    if (widget.product?.picture != null) {
      _selectedImageBase64 = widget.product!.picture;
    }
    initFormData();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        
        setState(() {
          _selectedImageBase64 = base64String;
          _currentImagePath = result.files.single.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageBase64 = null;
      _currentImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.product != null ? "Edit Product" : "Add Product",
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
                    
                    // Add image to request if selected
                    if (_selectedImageBase64 != null) {
                      request['picture'] = _selectedImageBase64;
                    }

                    try {
                      if (widget.product == null) {
                        await productProvider.insert(request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await productProvider.update(widget.product!.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ProductListScreen(),
                          settings: const RouteSettings(name: 'ProductListScreen'),
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
                        Icons.shopping_bag,
                        size: 28,
                        color: const Color(0xFF004AAD),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      widget.product != null ? "Edit Product" : "Add New Product",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),

                // Product Name field
                FormBuilderTextField(
                  name: "name",
                  decoration: customTextFieldDecoration(
                    "Product Name",
                    prefixIcon: Icons.shopping_bag,
                    hintText: "Enter product name",
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(200),
                  ]),
                ),
                SizedBox(height: 20),

                // Price field
                FormBuilderTextField(
                  name: "price",
                  decoration: customTextFieldDecoration(
                    "Price",
                    prefixIcon: Icons.attach_money,
                    hintText: "Enter price",
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.min(0.01),
                    FormBuilderValidators.max(999.99),
                  ]),
                ),
                SizedBox(height: 20),

                // Image picker section
                _buildImagePicker(),
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product Image",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _selectedImageBase64 != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(_selectedImageBase64!),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE2E8F0),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 50,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 50,
                          color: const Color(0xFF64748B),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Tap to select image",
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "JPG, PNG, GIF supported",
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
