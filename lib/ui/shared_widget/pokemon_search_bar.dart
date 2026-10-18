import 'package:flutter/material.dart';
import '../color.dart';
import '../typography.dart';

/// Reusable Search Bar khas PokéAtlas dengan animasi focus glow,
/// rounded kapsul, dan tombol clear otomatis.
class PokemonSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry? margin;
  final bool autofocus;

  const PokemonSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search Pokémon',
    this.onChanged,
    this.onClear,
    this.margin,
    this.autofocus = false,
  });

  @override
  State<PokemonSearchBar> createState() => _PokemonSearchBarState();
}

class _PokemonSearchBarState extends State<PokemonSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }

    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    if (_isInternalFocusNode) _focusNode.dispose();
    if (_isInternalController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final hasText = _controller.text.isNotEmpty;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isFocused ? primaryColor : borderNeutral,
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? primaryColor.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isFocused ? 14 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        style: smMedium.copyWith(color: bgDark),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: smRegular.copyWith(
            fontSize: 13.5,
            color: black400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isFocused ? primaryColor : black500,
            size: 22,
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: black400),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                    widget.onClear?.call();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );

    if (widget.margin != null) {
      return Padding(
        padding: widget.margin!,
        child: content,
      );
    }

    return content;
  }
}
