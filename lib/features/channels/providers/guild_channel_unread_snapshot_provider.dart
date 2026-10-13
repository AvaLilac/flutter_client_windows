import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/features/channels/domain/channel.dart';
import 'package:fluxer_app/features/channels/providers/channel_list_view_model.dart';
import 'package:fluxer_app/features/channels/providers/unread_provider.dart';
import 'package:fluxer_app/features/guilds/providers/guild_read_state_ready_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guild_channel_unread_snapshot_provider.g.dart';

@Riverpod(keepAlive: true)
class GuildChannelUnreadFold extends _$GuildChannelUnreadFold {
  @override
  Map<String, UnreadState> build() => <String, UnreadState>{};

  void apply(Map<String, UnreadState> patch) {
    if (patch.isEmpty) {
      return;
    }
    state = <String, UnreadState>{...state, ...patch};
  }

  void reset() {
    state = <String, UnreadState>{};
  }
}

@riverpod
Map<String, UnreadState> guildChannelUnreadSnapshot(Ref ref, String guildId) {
  final List<ChannelCategory> categories = ref.watch(
    channelListViewModelProvider.select(
      (ChannelListState state) => state.guild?.id == guildId
          ? state.categories
          : const <ChannelCategory>[],
    ),
  );
  final Map<String, UnreadState> fold = ref.watch(
    guildChannelUnreadFoldProvider,
  );
  final Map<String, UnreadState> snapshot = <String, UnreadState>{
    for (final ChannelCategory category in categories)
      for (final Channel channel in category.channels)
        channel.id: fold[channel.id] ?? const UnreadState(),
  };
  return Map<String, UnreadState>.unmodifiable(snapshot);
}

@riverpod
bool guildChannelUnreadKnown(Ref ref, String guildId) {
  if (!ref.watch(guildReadStateReadyProvider)) {
    return false;
  }
  final List<ChannelCategory> categories = ref.watch(
    channelListViewModelProvider.select(
      (ChannelListState state) => state.guild?.id == guildId
          ? state.categories
          : const <ChannelCategory>[],
    ),
  );
  final Map<String, UnreadState> fold = ref.watch(
    guildChannelUnreadFoldProvider,
  );
  for (final ChannelCategory category in categories) {
    for (final Channel channel in category.channels) {
      if (!fold.containsKey(channel.id)) {
        return false;
      }
    }
  }
  return true;
}
