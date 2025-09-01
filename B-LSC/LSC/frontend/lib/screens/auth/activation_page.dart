// lib/pages/activation_page.dart

import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import '../dashboard/dashboard_screen.dart';

class ActivationPage extends StatefulWidget {
  const ActivationPage({super.key});

  @override
  _ActivationPageState createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  final _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _activateLicense() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await ApiService().activateLicense(_keyController.text);

        if (success) {
          // If activation is successful, navigate to the dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        } else {
          // Show error message if activation failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid key. Please try again.')),
          );
        }
      } catch (e) {
        // Handle any exceptions during the API call
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to activate key. Network error.'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activate License')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Your account license is not active. Please enter your activation key.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _keyController,
                  decoration: const InputDecoration(
                    labelText: 'Activation Key',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an activation key.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _activateLicense,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Activate'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _activateLicense,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Activate'),
                      ),
                    ],
                  ),
                ),
                // ElevatedButton(
                //   onPressed: _isLoading ? null : _activateLicense,
                //   child: _isLoading
                //       ? const CircularProgressIndicator(color: Colors.white)
                //       : const Text('Activate'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
