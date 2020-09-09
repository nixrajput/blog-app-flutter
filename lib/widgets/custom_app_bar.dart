import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;

  const CustomAppBar(this.title);

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
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 16.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 32.0,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 10.0),
          Text(
            title,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).accentColor),
          ),
        ],
      ),
    );
  }
}
