import 'package:flutter/material.dart';

class SpeedDial extends StatefulWidget {
  final Function() onOpenZalo;
  final Function() onOpenMess;
  final Function() onAddNew;
  final Function(bool) onFabAction;
  SpeedDial({this.onOpenZalo, this.onOpenMess, this.onAddNew, this.onFabAction});

  @override
  State<StatefulWidget> createState() => SpeedDialState();
}

class SpeedDialState extends State<SpeedDial>
    with SingleTickerProviderStateMixin {
  bool _isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;

  // this is needed to know how much to "translate"
  double _fabHeight = 56.0;

  // when the menu is closed, we remove elevation to prevent
  // stacking all elevations
  bool _shouldHaveElevation = false;

  @override
  initState() {
    // a bit faster animation, which looks better: 300
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));

    // this does the translation of menu items
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  void animate() {
    if (!_isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    _isOpened = !_isOpened;
    widget.onFabAction(_isOpened);
    // here we update whether or not they FABs should have elevation
    _shouldHaveElevation = !_shouldHaveElevation;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget zaloButton() {
    return Container(
      child: FloatingActionButton(
        onPressed: (){
          animate();
          widget.onOpenZalo();
        },
        tooltip: 'distance',
        heroTag: 'distance',
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/images/zalo-logo.png',
          color: Color.fromRGBO(182, 110, 218, 1),
        ),
        elevation: _shouldHaveElevation ? 6.0 : 0,
      ),
    );
  }

  Widget messButton() {
    return Container(
      child: FloatingActionButton(
        onPressed: (){
          animate();
          widget.onOpenMess();
        },
        tooltip: 'likes',
        heroTag: 'likes',
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/images/facebook.png',
        ),
        elevation: _shouldHaveElevation ? 6.0 : 0,
      ),
    );
  }

  Widget addNewButton() {
    return Container(
      child: FloatingActionButton(
        onPressed: (){
          animate();
          widget.onAddNew();
        },
        tooltip: 'bookmarks',
        heroTag: 'bookmarks',
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/images/add.png'
        ),
        elevation: _shouldHaveElevation ? 6.0 : 0,
      ),
    );
  }


  Widget fabButton() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: animate,
        tooltip: 'Toggle menu',
        child: Image.asset(
          _isOpened ? "assets/images/close.png" :
          'assets/images/filter.png',
          width: 34,
          height: 34,
          color: _isOpened ? Colors.red : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 3.0,
            0.0,
          ),
          child: zaloButton(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: messButton(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: addNewButton(),
        ),
        fabButton(),
      ],
    );
  }
}
