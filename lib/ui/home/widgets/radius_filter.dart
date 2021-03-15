import 'package:flutter/material.dart';

class RadiusFilter extends StatefulWidget {
  final Function(int selectedValue) onRadiusFilter;
  final int selectedValue;

  RadiusFilter(this.onRadiusFilter, this.selectedValue);

  @override
  _RadiusFilterState createState() => _RadiusFilterState();
}

class _RadiusFilterState extends State<RadiusFilter> {
  List<int> _radius = [5, 10, 15, 20, 50];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 0.5,
            color: Colors.grey,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _radius
                  .map((e) => Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            widget.onRadiusFilter(e);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 60,
                            margin: EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    width: widget.selectedValue == e ? 1 : 0.5,
                                    color: widget.selectedValue == e
                                        ? Colors.red
                                        : Colors.grey,
                                    style: BorderStyle.solid)),
                            child: Text('$e Km',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
