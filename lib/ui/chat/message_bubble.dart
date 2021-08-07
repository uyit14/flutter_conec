import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
    this.message,
    this.userName,
    this.userImage,
    this.createdDate,
    this.isMe, {
    this.key,
  });

  final Key key;
  final String message;
  final String userName;
  final String userImage;
  final String createdDate;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                Container(
                  constraints: BoxConstraints(minWidth: 140, maxWidth: MediaQuery.of(context).size.width * 2 / 3),
                  decoration: BoxDecoration(
                    color: isMe ? Theme.of(context).accentColor : Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
                      bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  margin: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        message,
                        style: TextStyle(
                          color: isMe
                              ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: isMe ? 8 : null,
                  left: isMe ? null : 8,
                  child: Text(
                    createdDate,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12
                    ),
                    textAlign: TextAlign.start,
                  ),
                )
              ],
            ),

          ],
        ),
      ],
      overflow: Overflow.visible,
    );
  }
}
