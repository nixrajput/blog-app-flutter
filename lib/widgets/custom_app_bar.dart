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
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(0.0, 0.0),
            blurRadius: 20.0,
            color: Colors.grey.withOpacity(0.5),
          )
        ],
      ),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  mainIcon,
                  size: 32.0,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: onPressed,
              ),
              SizedBox(width: 10.0),
              Text(
                title,
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor),
              )
            ],
          ),
          actions
        ],
      ),
    );
  }
}
