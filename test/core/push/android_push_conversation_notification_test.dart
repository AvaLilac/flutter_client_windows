import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/push/android_push_conversation_history.dart';
import 'package:fluxer_app/core/push/android_push_conversation_notification.dart';

void main() {
  group('resolvePushSenderName', () {
    test('strips guild suffix from title', () {
      expect(resolvePushSenderName('Alice (#general, My Server)'), 'Alice');
    });

    test('strips group dm suffix', () {
      expect(resolvePushSenderName('Alice (Group DM)'), 'Alice');
    });

    test('keeps plain dm title', () {
      expect(resolvePushSenderName('Alice'), 'Alice');
    });
  });

  group('buildPushMessagingStyle', () {
    test('uses conversation title for guild channels', () {
      final MessagingStyleInformation style = buildPushMessagingStyle(
        payload: const <String, String>{'guild_id': '1'},
        lines: <PushConversationLine>[
          const PushConversationLine(
            messageId: '1',
            senderName: 'Alice',
            senderKey: 'a',
            body: 'hey',
            timestampMs: 1000,
          ),
        ],
        title: 'Alice (#general, My Server)',
      );
      expect(style.conversationTitle, 'general');
      expect(style.groupConversation, isTrue);
      expect(style.messages, hasLength(1));
      expect(style.messages!.single.person?.name, 'Alice');
    });

    test('omits conversation title for 1:1 dms', () {
      final MessagingStyleInformation style = buildPushMessagingStyle(
        payload: const <String, String>{'guild_id': 'null'},
        lines: <PushConversationLine>[
          const PushConversationLine(
            messageId: '1',
            senderName: 'Alice',
            senderKey: 'a',
            body: 'hey',
            timestampMs: 1000,
          ),
        ],
        title: 'Alice',
      );
      expect(style.conversationTitle, isNull);
      expect(style.groupConversation, isFalse);
    });

    test('adds inline image metadata when present', () {
      final List<Message> messages =
          pushConversationMessages(<PushConversationLine>[
            const PushConversationLine(
              messageId: '1',
              senderName: 'Alice',
              senderKey: 'a',
              body: 'photo',
              timestampMs: 1000,
              imagePath: '/tmp/push.jpg',
            ),
          ]);
      expect(messages.single.dataMimeType, 'image/jpeg');
      expect(messages.single.dataUri, contains('push.jpg'));
    });
  });
}
