import 'package:conecapp/ui/chat/chat_doc.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class Messages extends StatelessWidget {
  final List<ChatDoc> chatDocs;


  Messages(this.chatDocs);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: chatDocs.length,
      itemBuilder: (ctx, index) => MessageBubble(
        chatDocs[index].text,
        chatDocs[index].userName,
        chatDocs[index].userImage,
        chatDocs[index].userId,
        key: ValueKey(chatDocs[index].docId),
      ),
    );
  }
}
