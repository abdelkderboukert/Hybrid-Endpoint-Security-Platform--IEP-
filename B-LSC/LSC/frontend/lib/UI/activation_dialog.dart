import 'package:frontend/services/api_service.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/screens/auth/login_screen.dart';

class ActivationDialog extends StatefulWidget {
  const ActivationDialog({super.key});

  @override
  _ActivationDialogState createState() => _ActivationDialogState();
}

class _ActivationDialogState extends State<ActivationDialog> {
  final _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _activateLicense() async {
    // You should still validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Clean the input before sending to the API
    final cleanedKey = _keyController.text.replaceAll(' ', '');

    try {
      final success = await ApiService().activateLicense(cleanedKey);

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Invalid Key'),
              content: const Text(
                'The activation key is invalid. Please try again.',
              ),
              severity: InfoBarSeverity.error,
              onClose: close,
            );
          },
        );
      }
    } catch (e) {
      displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Network Error'),
            content: const Text(
              'Failed to activate key. Check your network connection.',
            ),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Activate License'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your account license is not active. Please enter your activation key.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Use TextBox, the Fluent UI equivalent of TextFormField
            TextBox(
              controller: _keyController,
              placeholder: 'xxxx xxxx xxxx xxxx',
              // Since TextBox doesn't have a direct formatter,
              // you would need a custom one or manually handle the input.
              // For simplicity, we'll rely on the placeholder and validation.
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Button(
          onPressed: () async {
            await AuthService().logout();
            // Use FluentPageRoute for navigation
            Navigator.of(context).pushAndRemoveUntil(
              FluentPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _activateLicense,
          // Use a Row to show both text and loading indicator if needed
          child: _isLoading
              ? const ProgressRing(strokeWidth: 2.0)
              : const Text('Activate'),
        ),
      ],
    );
  }
}
