import 'dart:async';
import 'package:base/src/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class CustomSearchBar<T> extends StatefulWidget {
  const CustomSearchBar(
      {super.key,
      required this.onChanged,
      this.onTap,
      this.readOnly = true,
      required this.text,
      this.style,
      required this.onSelected,
      this.suffixIcon,
      this.prefixIcon,
      this.hintText,
      this.textCtrl,
      this.timeOutSearch = 1,
      this.waitTextSearch = 2,
      this.showDialog = true,
      this.initialValue, this.noDataWidget});
  final Function(T value) onSelected;
  final FutureOr<List<T>> Function(String? value) onChanged;
  final List<T> Function()? onTap;
  final bool readOnly;
  final String Function(T value) text;
  final TextStyle? style;
  final Widget? suffixIcon;
  final String? hintText;
  final TextEditingController? textCtrl;
  final Widget? prefixIcon;
  final int timeOutSearch;
  final String? initialValue;
  final bool showDialog;
  final int waitTextSearch;
  final Widget? noDataWidget;
  @override
  State<CustomSearchBar<T>> createState() => _CustomSearchBarState<T>();
}

class _CustomSearchBarState<T> extends State<CustomSearchBar<T>> {
  final _dropdownKey = GlobalKey();
  late final TextEditingController _textCtrl;
  late RenderBox _box;
  TextStyle style = const TextStyle();
  List<T> data = [];
  Timer? timer;
  Widget? suffixIcon;
  final _focusNode = FocusNode();
  OverlayEntry? _dialog;

  onTapDrowdown() async {
    final offset = _box.localToGlobal(Offset(0, _box.size.height));
    final halfHeight = MediaQuery.of(context).size.height / 2;
    double verticalPos = offset.dy + MediaQuery.of(context).viewInsets.bottom;
    if (verticalPos > halfHeight) {
      verticalPos = verticalPos -
          halfHeight / 2 -
          50 -
          MediaQuery.of(context).viewInsets.bottom;
      if (verticalPos < 0) verticalPos = 0;
    }
    _onRemoveDialog();
    _dialog = OverlayEntry(builder: (context) {
      return Positioned(
        top: verticalPos,
        left: offset.dx,
        child: TapRegion(
          onTapOutside: (details) => _onRemoveDialog(),
          child: _buildDropdown(),
        ),
      );
    });
    Overlay.of(context).insert(_dialog!);
  }

  onPickItem(int index) {
    widget.onSelected(data[index]);
    setState(() {
      _textCtrl.text = widget.text(data[index]);
      _onRemoveDialog();
    });
  }

  _onSearch(String? value) async {
    if (value == null) return;
    if (value.length < widget.waitTextSearch) return;
    if (timer != null) timer?.cancel();
    timer = Timer(Duration(seconds: widget.timeOutSearch), () async {
      data = await widget.onChanged(value);
      if (widget.showDialog) {
        onTapDrowdown();
      }
    });
  }

  _onTapField() {
    if (widget.onTap != null) {
      data = widget.onTap?.call() ?? [];
      onTapDrowdown();
    }
  }

  _onRemoveDialog() {
    if (_dialog == null || _dialog?.mounted == false) return;
    _dialog?.remove();
    _dialog = null;
  }

  @override
  void initState() {
    if (widget.style != null) {
      style = widget.style!;
    }
    if (widget.textCtrl != null) {
      _textCtrl = widget.textCtrl!;
    } else {
      _textCtrl = TextEditingController();
    }
    suffixIcon = widget.suffixIcon;
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        _box = _dropdownKey.currentContext?.findRenderObject() as RenderBox;
      },
    );
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    if (widget.textCtrl == null) {
      _textCtrl.dispose();
    }
    if (timer != null) {
      timer?.cancel();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      key: _dropdownKey,
      textCtrl: _textCtrl,
      // focusNode: _focusNode,
      onTap: () {
        _onTapField();
        suffixIcon = GestureDetector(
            // behavior: HitTestBehavior.translucent,
            onTap: () {
              _textCtrl.text = '';
              setState(() {});
            },
            child: const Icon(Icons.close));
        setState(() {});
      },
      onTapOutside: () {
        suffixIcon = widget.suffixIcon;
        // _onRemoveDialog();
        setState(() {});
      },
      hintText: widget.hintText,
      readOnly: widget.readOnly,
      onChanged: _onSearch,
      initialValue: widget.initialValue,
      prefixIcon: widget.prefixIcon,
      suffixIcon: suffixIcon,
      // onTap: () => onTapDrowdown(),
    );
  }

  _buildDropdown() {
    // final offset = _box.localToGlobal(Offset(0, _box.size.height + 20));
    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        width: 1,
      ),
      color: Colors.white,
    );
    return data.isNotEmpty
        ? Container(
            width: _box.size.width,
            decoration: boxDecoration,
            constraints: BoxConstraints(
              // minHeight: 38,
              maxHeight: MediaQuery.of(context).size.height / 4,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: ListView.separated(
              itemCount: data.length,
              padding: const EdgeInsets.all(0),
              // shrinkWrap: true,
              itemBuilder: (context, index) {
                final item = data[index];
                if (item == null) return const SizedBox();
                return InkWell(
                  onTap: () => onPickItem(index),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.text(data[index]),
                      style: style,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  thickness: 1,
                );
              },
            ))
        : widget.noDataWidget?? const SizedBox();
  }
}
