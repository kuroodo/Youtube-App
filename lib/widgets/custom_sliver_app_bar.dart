import 'package:flutter/material.dart';
import 'package:my_youtube_clone/widgets/search_field.dart';

class CustomSliverAppBar extends StatelessWidget {
  final Function(String) onSearch;
  final Function() onEndSearch;
  final String defaultSearchText;
  const CustomSliverAppBar({
    Key? key,
    required this.onEndSearch,
    required this.onSearch,
    this.defaultSearchText = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      leadingWidth: 100.0,
      leading: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          onEndSearch();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Image.asset("assets/yt_logo_dark.png"),
        ),
      ),
      title: SearchField(
        defaultText: defaultSearchText,
        onSearch: onSearch,
        onEndSearch: onEndSearch,
      ),
    );
  }
}
