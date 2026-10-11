import 'package:fluxer_app/core/push/push_notification_payload.dart';

const String kAndroidPushMessageChannelId = 'fluxer_messages';
const String kAndroidPushDirectMessageChannelId = 'fluxer_direct_messages';
const String kAndroidPushForumThreadCreatedChannelId =
    'fluxer_forum_thread_created';

const String kAndroidPushMessageChannelName = 'Messages';
const String kAndroidPushDirectMessageChannelName = 'Direct messages';
const String kAndroidPushForumThreadCreatedChannelName = 'New forum posts';

const String kAndroidPushChannelDescription = 'Messages and alerts';
const String kAndroidPushNotificationIcon = '@drawable/fluxer_logo_monochrome';

String androidPushChannelId(Map<String, String> payload) {
  if (isDmPushPayload(payload)) {
    return kAndroidPushDirectMessageChannelId;
  }
  if (isForumThreadCreatedPushPayload(payload)) {
    return kAndroidPushForumThreadCreatedChannelId;
  }
  return kAndroidPushMessageChannelId;
}

String androidPushChannelName(Map<String, String> payload) {
  if (isDmPushPayload(payload)) {
    return kAndroidPushDirectMessageChannelName;
  }
  if (isForumThreadCreatedPushPayload(payload)) {
    return kAndroidPushForumThreadCreatedChannelName;
  }
  return kAndroidPushMessageChannelName;
}
