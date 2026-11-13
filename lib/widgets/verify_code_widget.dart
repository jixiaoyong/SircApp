import 'package:material_ui/material_ui.dart';

/*
* @description: verify code widget
*
* you can only input code one by one.
*
* when click the box, if there is no code, and the box is first or the one after
* the last filled box, then the box will be filled with the code.
* Otherwise, the box can't be selected.
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class VerifyCodeWidget extends StatefulWidget {
  final int verifyCodeCount;
  final ValueChanged<String>? onChanged;
  final IndexedWidgetBuilder? itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;

  const VerifyCodeWidget({
    super.key,
    this.verifyCodeCount = 6,
    this.onChanged,
    this.itemBuilder,
    this.separatorBuilder,
  });

  @override
  State<VerifyCodeWidget> createState() => _VerifyCodeWidgetState();
}

class _VerifyCodeWidgetState extends State<VerifyCodeWidget> {
  String _verifyCode = "";

  final _verifyCodeController = TextEditingController();
  var _currentVerifyIndex = 0;
  final _verifyFocusNode = FocusNode();

  @override
  void dispose() {
    _verifyCodeController.dispose();
    _verifyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextSelectionTheme(
          data: const TextSelectionThemeData(
            selectionColor: Colors.transparent,
          ),
          child: TextField(
            focusNode: _verifyFocusNode,
            controller: _verifyCodeController,
            decoration: const InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            showCursor: false,
            cursorHeight: 0,
            cursorWidth: 0,
            cursorColor: Colors.transparent,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.transparent),
            onChanged: (value) {
              widget.onChanged?.call(value);
              if (value.length >= widget.verifyCodeCount) {
                _verifyFocusNode.unfocus();
                setState(() {
                  _currentVerifyIndex = -1;
                });
                if (value.length > widget.verifyCodeCount) {
                  _verifyCodeController.text = value.substring(
                    0,
                    widget.verifyCodeCount,
                  );
                  return;
                }
              }
              // the code length is growing
              if (value.length > _verifyCode.length) {
                _currentVerifyIndex++;
                if (_currentVerifyIndex >= widget.verifyCodeCount) {
                  _currentVerifyIndex = widget.verifyCodeCount;
                }
                _verifyCodeController.selection = TextSelection.collapsed(
                  offset: _currentVerifyIndex,
                );
              } else if (value.length < _verifyCode.length) {
                _currentVerifyIndex--;
                if (_currentVerifyIndex < 0) {
                  _currentVerifyIndex = 0;
                }
                if (value.isNotEmpty) {
                  _verifyCodeController.selection = TextSelection(
                    baseOffset: _currentVerifyIndex,
                    extentOffset: _currentVerifyIndex + 1,
                  );
                }
              }
              setState(() {
                _verifyCode = value;
              });
            },
          ),
        ),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: ListView.separated(
            itemBuilder: (context, index) {
              var item = index >= _verifyCode.length ? "" : _verifyCode[index];
              return GestureDetector(
                onTap: () {
                  _verifyFocusNode.requestFocus();
                  if (index > _verifyCode.length) {
                    // can't insert blank char to the code
                    return;
                  }
                  setState(() {
                    _currentVerifyIndex = index;
                  });
                  if (index == _verifyCode.length) {
                    // insert a char to the end of the code list
                    _verifyCodeController.selection = TextSelection.collapsed(
                      offset: index,
                    );
                  } else {
                    // replace the char in the code list
                    _verifyCodeController.selection = TextSelection(
                      baseOffset: _currentVerifyIndex,
                      extentOffset: _currentVerifyIndex + 1,
                    );
                  }
                },
                child:
                    widget.itemBuilder?.call(context, index) ??
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: Border.all(
                          color: _currentVerifyIndex == index
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      child: Center(
                        child: Text(
                          item,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
              );
            },
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: widget.verifyCodeCount,
            separatorBuilder:
                widget.separatorBuilder ?? (context, index) => Container(),
          ),
        ),
      ],
    );
  }
}
