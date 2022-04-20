import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waterapp/lib2/constants.dart';

class SetLocation extends StatefulWidget {
  @override
  _SetLocationState createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {
  String _dropDownValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset("images/back.svg"),
          onPressed: () {
            Navigator.pop(context, newLocation);
            //productss.clear();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                'Set Location',
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
        color: Color(0xFFFAFAFA),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a location and then go back',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.all(15),
                height: 55,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(5))),
                child: DropdownButton(
                  hint: _dropDownValue == null
                      ? Text('Category',
                          style: TextStyle(fontSize: 20, color: Colors.black))
                      : Text(
                          _dropDownValue,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                  underline: Text(''),
                  isExpanded: true,
                  iconSize: 30.0,
                  style: TextStyle(color: Colors.black),
                  items: [
                    'Rawalpindi',
                    'Islamabad',
                    'Karachi',
                    'Lahore',
                    'Multan',
                    'Quetta',
                    'Taxila',
                    'All',
                  ].map(
                    (val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    },
                  ).toList(),
                  onChanged: (val) {
                    setState(
                      () {
                        _dropDownValue = val;
                        newLocation = _dropDownValue;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
