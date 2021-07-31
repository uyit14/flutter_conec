import 'package:flutter/material.dart';

class SpeedDial extends StatefulWidget {
  final Function() onOpenZalo;
  final Function() onOpenMess;
  final Function() onOpenChat;
  final Function() onAddNew;
  final Function(bool) onFabAction;

  SpeedDial(
      {this.onOpenZalo, this.onOpenMess, this.onOpenChat, this.onAddNew, this.onFabAction});

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
    return InkWell(
      onTap: () {
        animate();
        widget.onOpenZalo();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: _isOpened
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Hỗ trợ ngay qua Zalo", style: TextStyle(fontSize: 16)),
                  FloatingActionButton(
                    onPressed: null,
                    backgroundColor: Colors.white,
                    tooltip: 'zalo',
                    heroTag: 'zalo',
                    child: Image.asset(
                      'assets/images/zalo-logo.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                    ),
                    elevation: 0,
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  Widget messButton() {
    return InkWell(
      onTap: () {
        animate();
        widget.onOpenMess();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: _isOpened
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Hỗ trợ ngay qua Messenger",
                      style: TextStyle(fontSize: 16)),
                  FloatingActionButton(
                    onPressed: null,
                    tooltip: 'mess',
                    heroTag: 'mess',
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/images/messenger.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                    ),
                    elevation: 0,
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  Widget chatButton() {
    return InkWell(
      onTap: () {
        animate();
        widget.onOpenChat();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: _isOpened
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Trò chuyện", style: TextStyle(fontSize: 16)),
            FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.white,
              tooltip: 'chat',
              heroTag: 'chat',
              child: Image.asset(
                'assets/images/message.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
              ),
              elevation: 0,
            ),
          ],
        )
            : Container(),
      ),
    );
  }

  Widget addNewButton() {
    return InkWell(
      onTap: () {
        animate();
        widget.onAddNew();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: _isOpened
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Đăng tin mới", style: TextStyle(fontSize: 16)),
                  FloatingActionButton(
                    onPressed: null,
                    tooltip: 'addnew',
                    heroTag: 'addnew',
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/images/add.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                    ),
                    elevation: 0,
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  Widget fabButton() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: !_isOpened ? Colors.white : Colors.white,
        onPressed: animate,
        tooltip: 'Toggle menu',
        child: Image.asset(
          _isOpened ? "assets/images/close.png" : 'assets/images/comments.png',
          width: 34,
          height: 34,
          color: _isOpened ? Colors.red : null,
        ),
        elevation: 6,
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
          child: messButton(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: zaloButton(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 1.0,
            0.0,
          ),
          child: chatButton(),
        ),
        fabButton(),
      ],
    );
  }
}
