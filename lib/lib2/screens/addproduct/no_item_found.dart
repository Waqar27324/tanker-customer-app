import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoItemFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset("images/back.svg"),
          onPressed: () {
            Navigator.pop(context);
            //productss.clear();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                'Item Searched',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 25,
                    letterSpacing: 3,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        height: 30,
        margin: EdgeInsets.fromLTRB(15, 25, 15, 15),
        child: Text(
          'Not Found please go back',
          style: TextStyle(
            fontSize: 25,
          ),
        ),
      ),
    );
  }
}
