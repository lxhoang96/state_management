import 'package:flutter/material.dart';
import 'custom_textfield.dart';

class CustomDropdown<T> extends StatefulWidget {
  const CustomDropdown({
    super.key,
    required this.data,
    this.onChanged,
    this.readOnly = true,
    required this.text,
    required this.initValue,
    required this.fieldName,
    this.style,
    this.onSaved,
    this.noDataWidget,
    this.maxHeight, // ✅ Add configurable max height
    this.itemPadding = const EdgeInsets.all(8.0), // ✅ Configurable padding
  });
  
  final List<T> data;
  final Function(T value)? onChanged;
  final Function(T? value)? onSaved;
  final bool readOnly;
  final String Function(T value) text;
  final T? initValue;
  final TextStyle? style;
  final String fieldName;
  final Widget? noDataWidget;
  final double? maxHeight; // ✅ Configurable max height
  final EdgeInsets itemPadding; // ✅ Configurable padding

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final _dropdownKey = GlobalKey();
  final _textCtrl = TextEditingController();
  T? _currentValue;
  RenderBox? _box; // ✅ Make nullable to handle initialization properly
  
  // ✅ Cache text style
  late final TextStyle _effectiveStyle;
  
  // ✅ Cache decoration
  late final BoxDecoration _dropdownDecoration;

  OverlayEntry? _dialog;
  bool _isInitialized = false; // ✅ Track initialization

  @override
  void initState() {
    super.initState();
    
    // ✅ Initialize style and decoration once
    _effectiveStyle = widget.style ?? const TextStyle();
    _dropdownDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(width: 1),
      color: Colors.white,
    );
    
    // ✅ Set initial value
    _currentValue = widget.initValue;
    if (widget.initValue != null) {
      _textCtrl.text = widget.text(widget.initValue as T);
    }
    
    // ✅ Get render box after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _dropdownKey.currentContext;
      if (context != null) {
        _box = context.findRenderObject() as RenderBox?;
        if (mounted) {
          setState(() => _isInitialized = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _onRemoveDialog(); // ✅ Clean up overlay before disposing
    _textCtrl.dispose();
    super.dispose();
  }

  // ✅ Optimized dropdown positioning
  void _onTapDropdown() {
    if (!_isInitialized || _box == null || _dialog != null) return;
    
    final offset = _box!.localToGlobal(Offset(0, _box!.size.height));
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    double? topPos;
    double? bottomPos;
    
    final availableSpaceBelow = screenHeight - offset.dy - keyboardHeight;
    final availableSpaceAbove = offset.dy;
    
    // ✅ Smart positioning based on available space
    if (availableSpaceBelow > 200 || availableSpaceBelow > availableSpaceAbove) {
      topPos = offset.dy;
    } else {
      bottomPos = screenHeight - offset.dy + 4;
    }
    
    _dialog = OverlayEntry(
      builder: (context) => Positioned(
        top: topPos,
        bottom: bottomPos,
        left: offset.dx,
        child: TapRegion(
          onTapOutside: (_) => _onRemoveDialog(),
          child: _buildDropdown(),
        ),
      ),
    );
    
    Overlay.of(context).insert(_dialog!);
  }

  void _onRemoveDialog() {
    if (_dialog?.mounted == true) {
      _dialog!.remove();
    }
    _dialog = null;
  }

  // ✅ Optimized item selection
  void _onPickItem(int index) {
    if (index < 0 || index >= widget.data.length) return;
    
    final selectedItem = widget.data[index];
    _currentValue = selectedItem;
    _textCtrl.text = widget.text(selectedItem);
    
    widget.onChanged?.call(selectedItem);
    _onRemoveDialog();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      key: _dropdownKey,
      textCtrl: _textCtrl,
      labelText: widget.fieldName,
      readOnly: widget.readOnly,
      onTap: _onTapDropdown,
      style: _effectiveStyle,
      onSaved: (_) => widget.onSaved?.call(_currentValue),
      suffixIcon: const Icon(Icons.arrow_drop_down_outlined, size: 24),
    );
  }

  // ✅ Optimized dropdown builder
  Widget _buildDropdown() {
    final maxHeight = widget.maxHeight ?? MediaQuery.of(context).size.height / 4;
    
    return Material(
      elevation: 8, // ✅ Add elevation for better visual hierarchy
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: _box!.size.width,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: _dropdownDecoration,
        child: widget.data.isNotEmpty
            ? _buildItemList()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: widget.noDataWidget ?? const SizedBox(),
              ),
      ),
    );
  }

  // ✅ Separate item list builder for better performance
  Widget _buildItemList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shrinkWrap: true,
      itemCount: widget.data.length,
      itemBuilder: (context, index) => InkWell( // ✅ Use InkWell for better touch feedback
        onTap: () => _onPickItem(index),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: widget.itemPadding,
          child: Text(
            widget.text(widget.data[index]),
            style: _effectiveStyle,
          ),
        ),
      ),
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
    );
  }
}