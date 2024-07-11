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

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final _dropdownKey = GlobalKey();
  final _textCtrl = TextEditingController();
  T? _currentValue;
  late RenderBox _box;

  TextStyle style = const TextStyle();

  OverlayEntry? _dialog;

  onTapDrowdown() async {
    final offset = _box.localToGlobal(Offset(0, _box.size.height));
    final height = MediaQuery.of(context).size.height;
    double? bottomPos;
    double? topPos = offset.dy + MediaQuery.of(context).viewInsets.bottom;
    if (topPos > height / 2) {
      // topPos = topPos -
      //     height / 4 -
      //     50 -
      //     MediaQuery.of(context).viewInsets.bottom;
      // if (topPos < 0) topPos = 0;
      bottomPos = height - offset.dy + 50;
      topPos = null;
    }
    _onRemoveDialog();
    _dialog = OverlayEntry(builder: (context) {
      return Positioned(
        top: topPos,
        bottom: bottomPos,
        left: offset.dx,
        child: TapRegion(
          onTapOutside: (details) => _onRemoveDialog(),
          child: _buildDropdown(),
        ),
      );
    });
    Overlay.of(context).insert(_dialog!);
  }

  _onRemoveDialog() {
    if (_dialog == null || _dialog?.mounted == false) return;
    _dialog?.remove();
    _dialog = null;
  }

  onPickItem(int index) {
    _currentValue = widget.data[index];
    if (_currentValue == null) {
      return;
    }
    widget.onChanged?.call(_currentValue!);
    setState(() {
      _textCtrl.text = widget.text(widget.data[index]);
      _onRemoveDialog();
    });
  }

  @override
  void initState() {
    // _dropdownKey = GlobalObjectKey(widget.hashCode);

    if (widget.style != null) {
      style = widget.style!;
    }

    final value = widget.initValue;

    if (value != null) {
      _textCtrl.text = widget.text(value);
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        _box = _dropdownKey.currentContext?.findRenderObject() as RenderBox;

        setState(() {});
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      key: _dropdownKey,
      textCtrl: _textCtrl,
      labelText: widget.fieldName,
      readOnly: widget.readOnly,
      onTap: () => onTapDrowdown(),
      style: style,
      onSaved: (value) {
        widget.onSaved?.call(_currentValue);
      },
      suffixIcon: const Icon(
        Icons.arrow_drop_down_outlined,
        size: 24,
      ),
    );
  }

  _buildDropdown() {
    final boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 1,
        ),
        color: Colors.white);
    return Material(
      // color: ,
      child: Container(
          width: _box.size.width,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 4,
          ),
          decoration: boxDecoration,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: widget.data.isNotEmpty
              ? ListView.separated(
                  itemCount: widget.data.length,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => onPickItem(index),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.text(widget.data[index]),
                        style: style,
                      ),
                    ),
                  ),
                  separatorBuilder: (context, index) {
                    return const Divider(
                      thickness: 1,
                    );
                  },
                )
              : widget.noDataWidget ?? const SizedBox()),
    );
  }
}
