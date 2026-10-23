// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nyachi';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get remove => 'Remove';

  @override
  String get switchLabel => 'Switch';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get copied => 'Copied';

  @override
  String get notFound => 'Page not found';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorAuth => 'Your session has expired';

  @override
  String get errorRateLimit =>
      'Too many requests. Wait a moment and try again.';

  @override
  String get errorServer => 'The server could not complete the request';

  @override
  String get errorNetwork =>
      'Could not reach the instance. Check your connection and try again.';

  @override
  String get errorStorage => 'Secure storage is unavailable';

  @override
  String get loginTitle => 'Sign in to Misskey';

  @override
  String get loginSubtitle => 'Use MiAuth or an access token.';

  @override
  String get instanceHost => 'Instance host';

  @override
  String get instanceHostHint => 'misskey.io';

  @override
  String get miAuthLogin => 'Continue with MiAuth';

  @override
  String get manualToken => 'Use an access token';

  @override
  String get token => 'Access token';

  @override
  String get openBrowser => 'Open browser';

  @override
  String get copyLink => 'Copy link';

  @override
  String get waitingApproval => 'Waiting for approval…';

  @override
  String get cancelLogin => 'Cancel sign-in';

  @override
  String get loginFailed => 'Sign-in failed';

  @override
  String get hostRequired => 'Enter an instance host';

  @override
  String get tokenRequired => 'Enter an access token';

  @override
  String get addAccount => 'Add account';

  @override
  String get sessionExpired => 'Your session has expired. Sign in again.';

  @override
  String get relogin => 'Sign in again';

  @override
  String get home => 'Home';

  @override
  String get local => 'Local';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get global => 'Global';

  @override
  String get notifications => 'Notifications';

  @override
  String get explore => 'Explore';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profile';

  @override
  String get compose => 'Compose';

  @override
  String get settings => 'Settings';

  @override
  String get emptyTimeline => 'No notes yet';

  @override
  String get emptyNotifications => 'No notifications yet';

  @override
  String get loadFailed => 'Could not load this feed';

  @override
  String get usingCache => 'Showing cached content';

  @override
  String get liveReconnecting => 'Reconnecting…';

  @override
  String get liveOffline => 'Live updates paused';

  @override
  String get sensitiveContent => 'Sensitive content';

  @override
  String get showContent => 'Show';

  @override
  String get reply => 'Reply';

  @override
  String get renote => 'Renote';

  @override
  String get reaction => 'Reaction';

  @override
  String get reactions => 'Reactions';

  @override
  String get react => 'React';

  @override
  String get removeReaction => 'Remove reaction';

  @override
  String get renoted => 'Renoted';

  @override
  String get replySent => 'Reply posted';

  @override
  String get videoUnavailable => 'Video unavailable';

  @override
  String get openExternal => 'Open in browser';

  @override
  String get attachment => 'Attachment';

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get noteCount => 'Notes';

  @override
  String get message => 'Message';

  @override
  String get accountSwitch => 'Switch account';

  @override
  String get noNotes => 'No notes yet';

  @override
  String get userNotFound => 'User not found';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get allRead => 'All notifications marked as read';

  @override
  String get notificationNote => 'posted a note';

  @override
  String get notificationMention => 'mentioned you';

  @override
  String get notificationReply => 'replied to you';

  @override
  String get notificationRenote => 'renoted your note';

  @override
  String get notificationQuote => 'quoted your note';

  @override
  String get notificationReaction => 'reacted to your note';

  @override
  String get notificationPollEnded => 'a poll ended';

  @override
  String get notificationFollow => 'followed you';

  @override
  String get notificationReceiveFollowRequest => 'sent a follow request';

  @override
  String get notificationFollowRequestAccepted =>
      'accepted your follow request';

  @override
  String get notificationRoleAssigned => 'assigned you a role';

  @override
  String get notificationChatRoomInvitation => 'invited you to a chat room';

  @override
  String get notificationAchievement => 'earned an achievement';

  @override
  String get notificationExportCompleted => 'export completed';

  @override
  String get notificationLogin => 'new sign-in';

  @override
  String get notificationCreateToken => 'access token created';

  @override
  String get notificationApp => 'app notification';

  @override
  String get notificationGroupedReaction => 'reacted to your note';

  @override
  String get notificationGroupedRenote => 'renoted your note';

  @override
  String get notificationGeneric => 'notification';

  @override
  String get trends => 'Trends';

  @override
  String get searchHint => 'Search notes and users';

  @override
  String get notesTab => 'Notes';

  @override
  String get usersTab => 'Users';

  @override
  String get noTrends => 'No trends right now';

  @override
  String get noUsers => 'No users found';

  @override
  String get noSearchResults => 'No results';

  @override
  String get newNote => 'New note';

  @override
  String get replyTo => 'Reply';

  @override
  String get contentWarning => 'Content warning';

  @override
  String get contentWarningHint => 'Optional warning';

  @override
  String get visibility => 'Visibility';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityHome => 'Home';

  @override
  String get visibilityFollowers => 'Followers';

  @override
  String get localOnly => 'Local only';

  @override
  String get post => 'Post';

  @override
  String get posting => 'Posting…';

  @override
  String get draftRestored => 'Draft restored';

  @override
  String get deleteDraft => 'Delete draft';

  @override
  String get draftDeleted => 'Draft deleted';

  @override
  String get postFailed => 'Could not post';

  @override
  String get overLimit => 'This note is too long';

  @override
  String get emptyContent => 'Write something first';

  @override
  String get direct => 'Direct';

  @override
  String get rooms => 'Rooms';

  @override
  String get noConversations => 'No conversations yet';

  @override
  String get noRooms => 'No rooms yet';

  @override
  String get send => 'Send';

  @override
  String get messageHint => 'Write a message';

  @override
  String get attach => 'Attach';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get sendFailed => 'Could not send';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get loadOlder => 'Load older';

  @override
  String get roomOwner => 'Owner';

  @override
  String get accounts => 'Accounts';

  @override
  String get navigation => 'Navigation';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get visibleTabs => 'Visible tabs';

  @override
  String get tabOrder => 'Tab order';

  @override
  String get homeLocked => 'Home cannot be hidden';

  @override
  String get removeAccountConfirm => 'Remove this account and its local data?';

  @override
  String get activeAccount => 'Active';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'Version 0.1.0+1';

  @override
  String get noAccounts => 'No accounts';

  @override
  String get confirm => 'Confirm';

  @override
  String get externalLinkFailed => 'Could not open the link';

  @override
  String get copyFailed => 'Could not copy the link';

  @override
  String get searchSubmit => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String characterCount(int count) {
    return '$count characters';
  }

  @override
  String get loadMore => 'Load more';

  @override
  String get serverNameFallback => 'Misskey';

  @override
  String get chatRoom => 'Room';

  @override
  String get chatWith => 'Chat';

  @override
  String get fileTooLarge => 'File is too large';

  @override
  String get noFile => 'No file selected';

  @override
  String get removeAttachment => 'Remove attachment';

  @override
  String get selectFile => 'Select file';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get noteDetail => 'Note';

  @override
  String get removeAccount => 'Remove account';

  @override
  String get signIn => 'Sign in';

  @override
  String get refresh => 'Refresh';

  @override
  String get accentColor => 'Accent color';

  @override
  String get instanceColor => 'Instance color';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorOrange => 'Orange';

  @override
  String get detailBreakpoint => 'Details panel breakpoint';
}
