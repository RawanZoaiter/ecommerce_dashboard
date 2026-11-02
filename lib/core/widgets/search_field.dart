import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A search box that reports its value only once typing pauses.
///
/// Without the debounce every keystroke would be a request; 350ms is short
/// enough to feel immediate and long enough to collapse a typed word into one
/// call.
class SearchField extends StatefulWidget {
  const SearchField({
    required this.hintText,
    required this.onChanged,
    this.initialValue = '',
    this.width = 280,
    super.key,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final String initialValue;
  final double width;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  static const _debounce = Duration(milliseconds: 350);

  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(_debounce, () => widget.onChanged(value.trim()));
    setState(() {}); // Toggles the clear button.
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search, size: 20),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 42,
            minHeight: 42,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _clear,
                ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}
