import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/features/dm/domain/dm_channel_types.dart';
import 'package:fluxer_app/features/dm/domain/dm_conversation.dart';
import 'package:fluxer_app/features/dm/providers/dm_view_model.dart';
import 'package:fluxer_app/shared/utils/chat_context_utils.dart';

typedef ComposerWatch = ({
  bool isSystemDm,
  bool isPersonalNotes,
  bool isGroup,
  String recipientId,
  String recipientName,
  String? name,
});

ComposerWatch? composerWatchFor(DmConversation? conversation) {
  if (conversation == null) {
    return null;
  }
  return (
    isSystemDm: isSystemDmConversation(conversation),
    isPersonalNotes: conversation.isPersonalNotes,
    isGroup: conversation.isGroup,
    recipientId: conversation.recipientId,
    recipientName: conversation.recipientName,
    name: conversation.name,
  );
}

//
// ignore: specify_nonobvious_property_types
final composerWatchProvider = Provider.autoDispose
    .family<ComposerWatch?, String>((Ref ref, String channelId) {
      final List<DmConversation> conversations = ref.watch(
        dmViewModelProvider.select((DmViewState state) => state.conversations),
      );
      return composerWatchFor(findDmById(conversations, channelId));
    });
