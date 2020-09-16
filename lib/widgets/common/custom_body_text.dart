import 'package:flutter/material.dart';

class CustomBodyText extends StatelessWidget {
  final IconData icon;
  final String value;

  const CustomBodyText({this.icon, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        bottom: 10.0,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[600],
          ),
          SizedBox(width: 10.0),
          Text(
            "$value",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
