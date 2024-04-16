import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'custom_textfield.dart';

class CustomSearchBar<T> extends StatefulWidget {
  const CustomSearchBar(
      {Key? key,
      this.onChanged,
      this.readOnly = true,
      required this.onGenerateItem,
      this.inputStyle,
      required this.onSelected,
      this.suffixIcon,
      this.prefixIcon,
      this.hintText,
      this.dropdownStyle,
      this.border,
      this.dropdownBorder,
      this.focusBorder,
      this.errorBorder,
      this.disabledBorder,
      this.dividerColor,
      this.data})
      : super(key: key);
  final Function(T value) onSelected;
  final Future<List<T>> Function(String value)? onChanged;
  final bool readOnly;
  final String Function(T value) onGenerateItem;
  final TextStyle? inputStyle;
  final TextStyle? dropdownStyle;
  final Widget? suffixIcon;
  final String? hintText;
  final InputBorder? border;
  final BoxBorder? dropdownBorder;
  final InputBorder? focusBorder;
  final InputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final Color? dividerColor;
  final Widget? prefixIcon;
  final List<T>? data;
  @override
  State<CustomSearchBar<T>> createState() => _CustomSearchBarState<T>();
}

class _CustomSearchBarState<T> extends State<CustomSearchBar<T>> {
  final _dropdownKey = GlobalKey();
  final _textCtrl = TextEditingController();
  late RenderBox _box;
  List<T> data = [];
  Timer? timer;

  onShowDropdown() {
    showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (context) {
          final offset = _box.localToGlobal(Offset(0, _box.size.height));
          final halfHeight = MediaQuery.of(context).size.height / 2;
          double verticalPos = offset.dy;
          if (offset.dy > halfHeight) {
            verticalPos = offset.dy - halfHeight - 100;
          }
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.only(top: verticalPos, left: offset.dx),
            // titlePadding: EdgeInsets.zero,
            alignment: Alignment.topLeft,
            elevation: 0,
            child: _buildDropdown(),
          );
        });
  }

  onPickItem(int index) {
    widget.onSelected(data[index]);
    setState(() {
      _textCtrl.text = widget.onGenerateItem(data[index]);
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  _onSearch(String value) async {
    if (widget.readOnly) return;

    if (widget.onChanged == null) return;
    if (value.length < 2) return;
    if (timer != null) timer?.cancel();
    timer = Timer(const Duration(seconds: 2), () async {
      data = await widget.onChanged!.call(value);
      if (data.isNotEmpty) {
        onShowDropdown();
      }
    });
  }

  @override
  void initState() {
    data = widget.data ?? [];
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        if (widget.readOnly && widget.data == null) {
          throw "Missing data on dropdown only";
        }
        if (!widget.readOnly && widget.onChanged == null) {
          throw "Missing onChanged function on searchable";
        }
        _box = _dropdownKey.currentContext?.findRenderObject() as RenderBox;
      },
    );

    super.initState();
  }

  // @override
  // void didUpdateWidget(CustomSearchBar<T> oldWidget) {
  //   if (widget.initValue != oldWidget.initValue) {
  //     final value = widget.initValue;

  //     if (value != null) {
  //       _textCtrl.text = widget.text(value);
  //       setState(() {});
  //     }
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

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
      hintText: widget.hintText,
      readOnly: widget.readOnly,
      onChanged: _onSearch,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      onTap: widget.readOnly ? onShowDropdown : null,
    );
  }

  _buildDropdown() {
    // final offset = _box.localToGlobal(Offset(0, _box.size.height + 20));
    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: widget.dropdownBorder,
      color: Colors.white,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 38,
        maxHeight: MediaQuery.of(context).size.height / 2,
      ),
      child: data.isNotEmpty
          ? Container(
              width: _box.size.width,
              decoration: boxDecoration,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.separated(
                  itemCount: data.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) => InkWell(
                    onTap: () => onPickItem(index),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.onGenerateItem(data[index]),
                        style: widget.dropdownStyle,
                      ),
                    ),
                  ),
                  separatorBuilder: (context, index) {
                    return Divider(
                      thickness: 1,
                      color: widget.dividerColor,
                    );
                  },
                ),
              ))
          : Container(
              height: double.minPositive,
              width: _box.size.width,
              decoration: boxDecoration,
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  'Không có dữ liệu',
                  style: widget.dropdownStyle
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ),
      // ),
    );
  }
}
