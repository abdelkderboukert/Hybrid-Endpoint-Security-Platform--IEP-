import 'package:flutter/material.dart';
import 'package:frontend/utils/app_styles.dart';

class CostumTextFaild extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final int? maxLines;
  final int maxLenght;
  const CostumTextFaild({
    super.key,
    required this.hintText,
    required this.controller,
    this.maxLines,
    required this.maxLenght,
  });

  @override
  State<CostumTextFaild> createState() => _CostumTextFaildState();
}

class _CostumTextFaildState extends State<CostumTextFaild> {
  FocusNode _focusNode = FocusNode();
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      controller: widget.controller,
      maxLength: widget.maxLenght,
      maxLines: widget.maxLines ?? 1,
      cursorColor: APPTheme.dark,
      decoration: InputDecoration(
        filled: true,
        fillColor: APPTheme.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintText: "Enter text",
      ),
    );
  }
}
