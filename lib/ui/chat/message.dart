import 'package:conecapp/models/response/chat/message_response.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class Messages extends StatelessWidget {
  final List<MessageChat> messages;
  final ScrollController scrollController;


  Messages(this.messages, this.scrollController);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      controller: scrollController,
      itemBuilder: (ctx, index) => MessageBubble(
        messages[index].content,
        messages[index].ownerName,
        messages[index].ownerAvatar,
        messages[index].createdDate,
        messages[index].createdByCurrentUser,
        key: ValueKey(messages[index].id),
      ),
    );
  }
}
