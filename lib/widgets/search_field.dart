import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final Function(String) onSearch;
  final Function() onEndSearch;
  final String defaultText;
  const SearchField(
      {Key? key,
      required this.onSearch,
      required this.onEndSearch,
      this.defaultText = ""})
      : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController controller = TextEditingController();
  FocusNode focus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.text = widget.defaultText;
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focus,
            onSubmitted: widget.onSearch,
            onChanged: (_) {
              // Update state so clear text button can be shown or hidden
              setState(() {});
            },
            decoration: const InputDecoration(labelText: "Search"),
          ),
        ),
        // Clear text button
        if (controller.text.isNotEmpty || focus.hasFocus)
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                focus.requestFocus();
                setState(() {
                  controller.text = "";
                });
              } else {
                focus.unfocus();
                widget.onEndSearch();
              }
            },
          ),
      ],
    );
  }
}
