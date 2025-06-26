import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'button.dart';

class CustomDropdownMenu extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String> onItemSelected;
  final String buttonText;
  final double width;
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  const CustomDropdownMenu({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.buttonText = 'فتح القائمة',
    this.width = 140,
    this.gradientColors = const [AppColors.primary, AppColors.lightSecondary],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  State<CustomDropdownMenu> createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  OverlayEntry? _overlayEntry;
  bool _isDropdownVisible = false;
  final LayerLink _layerLink = LayerLink();

  static const double _buttonPaddingHorizontal = 32.0;
  static const double _buttonPaddingVertical = 8.0;

  @override
  void dispose() {
    _removeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    _isDropdownVisible ? _removeDropdown() : _showDropdown();
  }

  void _showDropdown() {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: widget.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            child: Material(
              borderRadius: BorderRadius.circular(2),
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: widget.gradientColors,
                    begin: widget.begin,
                    end: widget.end,
                  ),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: widget.items.map((item) {
                    return CustomButton(
                      text: item,
                      onPressed: () {
                        widget.onItemSelected(item);
                        _removeDropdown();
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() {
      _isDropdownVisible = true;
    });
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomButton(
        padding: EdgeInsets.symmetric(
          horizontal: _buttonPaddingHorizontal,
          vertical: _buttonPaddingVertical,
        ),
        onPressed: _toggleDropdown,
        text: widget.buttonText,
      ),
    );
  }
}
