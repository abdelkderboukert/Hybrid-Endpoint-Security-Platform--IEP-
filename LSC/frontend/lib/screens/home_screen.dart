import 'package:flutter/material.dart';
import 'package:frontend/UI/costum_text_faild.dart';
import 'package:frontend/utils/app_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APPTheme.dark,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _mainbutton(() => null, "text"),
              Row(
                children: [
                  _mainbutton(() => null, "text"),
                  const SizedBox(width: 8),
                  _mainbutton(() => null, "text1"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          CostumTextFaild(
            hintText: 'User name',
            controller: controller,
            maxLenght: 30,
          ),
        ],
      ),
    );
  }

  ElevatedButton _mainbutton(Function()? onPressed, String text) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _buttonStyle(),
      child: Text(text),
    );
  }
}

ButtonStyle _buttonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: APPTheme.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
