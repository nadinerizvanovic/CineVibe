import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/model/actor.dart';
import 'package:cinevibe_desktop/providers/actor_provider.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:cinevibe_desktop/screens/actor_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ActorDetailsScreen extends StatefulWidget {
  final Actor? actor;

  const ActorDetailsScreen({super.key, this.actor});

  @override
  State<ActorDetailsScreen> createState() => _ActorDetailsScreenState();
}

class _ActorDetailsScreenState extends State<ActorDetailsScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late ActorProvider actorProvider;
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    actorProvider = Provider.of<ActorProvider>(context, listen: false);
    _initialValue = {
      "firstName": widget.actor?.firstName ?? '',
      "lastName": widget.actor?.lastName ?? '',
      "isActive": widget.actor?.isActive ?? true,
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
      title: widget.actor != null ? "Edit Actor" : "Add Actor",
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
                      if (widget.actor == null) {
                        await actorProvider.insert(request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Actor created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await actorProvider.update(widget.actor!.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Actor updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ActorListScreen(),
                          settings: const RouteSettings(name: 'ActorListScreen'),
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
                        Icons.person,
                        size: 28,
                        color: const Color(0xFF004AAD),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      widget.actor != null ? "Edit Actor" : "Add New Actor",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),

                // First Name field
                FormBuilderTextField(
                  name: "firstName",
                  decoration: customTextFieldDecoration(
                    "First Name",
                    prefixIcon: Icons.person,
                    hintText: "Enter first name",
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.match(
                      RegExp(r'^[\p{L} ]+$', unicode: true),
                      errorText:
                          'Only letters (including international), and spaces allowed',
                    ),
                  ]),
                ),
                SizedBox(height: 20),

                // Last Name field
                FormBuilderTextField(
                  name: "lastName",
                  decoration: customTextFieldDecoration(
                    "Last Name",
                    prefixIcon: Icons.person_outline,
                    hintText: "Enter last name",
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.match(
                      RegExp(r'^[\p{L} ]+$', unicode: true),
                      errorText:
                          'Only letters (including international), and spaces allowed',
                    ),
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
