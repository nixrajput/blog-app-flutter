import 'package:blog_api_app/widgets/common/custom_divider.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Widget actions;
  final IconData mainIcon;
  final Function onPressed;

  const CustomAppBar(this.title, this.actions, this.mainIcon, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        mainIcon,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: onPressed,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Raleway",
                          color: Theme.of(context).accentColor),
                    )
                  ],
                ),
                actions
              ],
            ),
          ),
          CustomDivider(),
        ],
      ),
    );
  }
}
