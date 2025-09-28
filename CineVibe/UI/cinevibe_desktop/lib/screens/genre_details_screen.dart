import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/model/genre.dart';
import 'package:cinevibe_desktop/providers/genre_provider.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:cinevibe_desktop/screens/genre_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class GenreDetailsScreen extends StatefulWidget {
  final Genre? genre;

  const GenreDetailsScreen({super.key, this.genre});

  @override
  State<GenreDetailsScreen> createState() => _GenreDetailsScreenState();
}

class _GenreDetailsScreenState extends State<GenreDetailsScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late GenreProvider genreProvider;
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    genreProvider = Provider.of<GenreProvider>(context, listen: false);
    _initialValue = {
      "name": widget.genre?.name ?? '',
      "description": widget.genre?.description ?? '',
      "isActive": widget.genre?.isActive ?? true,
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
      title: widget.genre != null ? "Edit Genre" : "Add Genre",
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
                      if (widget.genre == null) {
                        await genreProvider.insert(request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Genre created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await genreProvider.update(widget.genre!.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Genre updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const GenreListScreen(),
                          settings: const RouteSettings(name: 'GenreListScreen'),
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
                        Icons.movie_creation,
                        size: 28,
                        color: const Color(0xFF004AAD),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      widget.genre != null ? "Edit Genre" : "Add New Genre",
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
                    "Genre Name",
                    prefixIcon: Icons.movie_creation,
                    hintText: "Enter genre name",
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
                    hintText: "Enter genre description (optional)",
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
