import 'package:demo/providers/valentine_provider.dart';
import 'package:flutter/material.dart';
import 'package:demo/constants/colors.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  final Map<String, String> userData;

  const EditProfile({super.key, required this.userData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _ageController = TextEditingController(text: widget.userData['age']);
    _weightController = TextEditingController(
        text: widget.userData['weight']?.replaceAll(' kg', ''));
    _heightController = TextEditingController(
        text: widget.userData['height']?.replaceAll(' cm', ''));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String? Function(String?)? validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValentine = context.watch<ValentineProvider>().isValentineMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: isValentine ? Colors.pink[400] : null,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                  'Name',
                  _nameController,
                  (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null),
              _buildTextField(
                  'Email',
                  _emailController,
                  (value) =>
                      value?.isEmpty ?? true ? 'Email is required' : null),
              _buildTextField(
                  'Phone',
                  _phoneController,
                  (value) =>
                      value?.isEmpty ?? true ? 'Phone is required' : null),
              _buildTextField('Age', _ageController,
                  (value) => value?.isEmpty ?? true ? 'Age is required' : null),
              _buildTextField(
                  'Weight (kg)',
                  _weightController,
                  (value) =>
                      value?.isEmpty ?? true ? 'Weight is required' : null),
              _buildTextField(
                  'Height (cm)',
                  _heightController,
                  (value) =>
                      value?.isEmpty ?? true ? 'Height is required' : null),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Create updated user data
                    final updatedUserData = {
                      'name': _nameController.text,
                      'email': _emailController.text,
                      'phone': _phoneController.text,
                      'age': _ageController.text,
                      'weight': '${_weightController.text} kg',
                      'height': '${_heightController.text} cm',
                    };
                    Navigator.pop(context, updatedUserData);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isValentine ? Colors.pink[400] : AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
