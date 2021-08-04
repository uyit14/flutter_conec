import 'package:flutter/material.dart';

import 'chat_bloc.dart';

class NewMessage extends StatefulWidget {
  final Function(String messs) onSend;
  final String conversationId;

  NewMessage({this.onSend, this.conversationId});

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  ChatBloc _chatBloc = ChatBloc();
  var _enteredMessage = '';

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    widget.onSend(_enteredMessage);
    _controller.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _chatBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              onTap: (){
                if(widget.conversationId != null)
                _chatBloc.requestSeenMessage(widget.conversationId);
              },
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'Nhập lời nhắn...'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(
              Icons.send,
            ),
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
          )
        ],
      ),
    );
  }
}
